#!/bin/bash

# spDYN setup for NextcloudPi
#
#
# Copyleft 2017 by Timm Goldenstein
# https://github.com/TimmThaler/spdnsUpdater
#
# GPL licensed (see end of file) * Use at your own risk!
#

ACTIVE_=no
DOMAIN_=mycloud.spdns.de
TOKEN_=your-spdns-token

INSTALLDIR=spdnsupdater
INSTALLPATH=/usr/local/etc/$INSTALLDIR
CRONFILE=/etc/cron.d/spdnsupdater
DESCRIPTION="Free Dynamic DNS provider (need account from https://spdyn.de)"

install() {

  # Create the spdnsUpdater.sh
  mkdir -p "$INSTALLPATH"
  # Write the script to file
  cat > "$INSTALLPATH"/spdnsUpdater.sh <<'EOF' 
#!/bin/bash

### Usage
#
#	Recommended usage:	./spdnsUpdater.sh <hostname> <token>
#	Alternative usage:	./spdnsUpdater.sh <hostname> <user> <passwd>
#


### Configuration

# Get current IP address from
get_ip_url="https://api.ipify.org/"
update_url="https://update.spdyn.de/nic/update"


### Update procedure
function spdnsUpdater { 
	# Send the current IP address to spdyn.de
	# and show the response
	
	params=$1
	updater=$(curl -s $update_url $params)
	updater=$(echo $updater | grep -o '^[a-z]*')
	
	case "$updater" in
		abuse) echo "[$updater] Der Host kann nicht aktualisiert werden, da er aufgrund vorheriger fehlerhafter Updateversuche gesperrt ist."
			;;
		badauth) echo "[$updater] Ein ungültiger Benutzername und / oder ein ungültiges Kennwort wurde eingegeben."
			;;
		good) echo "[$updater] Die Hostname wurde erfolgreich auf die neue IP aktualisiert."
			;;
		yours) echo "[$updater] Der angegebene Host kann nicht unter diesem Benutzer-Account verwendet werden."
			;;
		notfqdn) echo "[$updater] Der angegebene Host ist kein FQDN."
			;;
		numhost) echo "[$updater] Es wurde versucht, mehr als 20 Hosts in einer Anfrage zu aktualisieren."
			;;
		nochg) echo "[$updater] Die IP hat sich zum letzten Update nicht geändert."
			;;
		nohost) echo "[$updater] Der angegebene Host existiert nicht oder wurde gelöscht."
			;;
		fatal) echo "[$updater] Der angegebene Host wurde manuell deaktiviert."
			;;
		*) echo "[$updater]"
			;;
	esac

}


if [ $# -eq 2 ]
  	then
  		# if hostname and token
  		# Get current IP address
		currip=$(curl -s "$get_ip_url");
		host=$1
		token=$2
    	params="-d hostname=$host -d myip=$currip -d user=$host -d pass=$token"
    	spdnsUpdater "$params"
	elif [ $# -eq 3 ]
		then
			# if hostname and user and passwd
			# Get current IP address
			currip=$(curl -s "$get_ip_url");
			host=$1
			user=$2
			pass=$3
			params="-d hostname=$host -d myip=$currip -d user=$user -d pass=$pass"
			spdnsUpdater "$params"
	else
		echo
		echo "Updater for Dynamic DNS at spdns.de"
		echo "==================================="
		echo
		echo "Usage:"
		echo "------"
		echo
		echo "Recommended:	./spdnsUpdater.sh <hostname> <token>"
		echo "Alternative:	./spdnsUpdater.sh <hostname> <user> <password>"
		echo
fi
EOF

    chmod 700 "$INSTALLPATH"/spdnsUpdater.sh
    chmod a+x "$INSTALLPATH"/spdnsUpdater.sh

}

configure() 
{
  if [[ $ACTIVE_ == "yes" ]]; then
    
    # Adds file to cron to run script for DNS record updates and change permissions 
    touch $CRONFILE
    echo "0 * * * * root $INSTALLPATH/spdnsUpdater.sh $DOMAIN_ $TOKEN_ >/dev/null 2>&1" > "$CRONFILE"
    chmod +x "$CRONFILE"

    # First-time execution of update script and print response from spdns.de server
    "$INSTALLPATH"/spdnsUpdater.sh "$DOMAIN_" "$TOKEN_"

    # Removes config files and cron job if ACTIVE_ is set to no
  elif [[ $ACTIVE_ == "no" ]]; then
    echo "... removing cronfile: $CRONFILE"
    rm -f "$CRONFILE"
    echo "spdnsUpdater is now disabled"
  fi
}

# License
#
# This script is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This script is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this script; if not, write to the
# Free Software Foundation, Inc., 59 Temple Place, Suite 330,
# Boston, MA  02111-1307  USA
