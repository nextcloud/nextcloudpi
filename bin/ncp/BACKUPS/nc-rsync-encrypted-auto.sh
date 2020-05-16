#!/bin/bash

# Periodically sync Nextcloud datafolder through rsync, encrypted via duplicity
#
# Copyleft 2020 by Daniel Ploeger
# 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/
#

install()
{
  apt-get update
  apt-get install --no-install-recommends -y rsync
  apt-get install --no-install-recommends -y duplicity
}

configure()
{
  [[ $ACTIVE != "yes" || ( $INCLUDEDB != "yes" && $INCLUDEDATA != "yes" ) ]] && { 
	rm -f /root/.passphrase
    rm -f /etc/cron.d/ncp-rsync-encrypted-auto
	rm -f /usr/local/bin/ncp-rsync-encrypted-full
	rm -f /usr/local/bin/ncp-rsync-encrypted-incr
    echo "automatic encrypted rsync disabled"
    return 0
  }

  local DATADIR
  DATADIR=$( ncc config:system:get datadirectory ) || {
    echo -e "Error reading data directory. Is NextCloud running and configured?";
    return 1;
  }

  # Check if the ssh access is properly configured. For this purpose the command : or echo is called remotely.
  # If one of the commands works, the test is successful.
  [[ "$DESTINATION" =~ : ]] && {
    local NET="$( sed 's|:.*||' <<<"$DESTINATION" )"
    local SSH=( ssh -o "BatchMode=yes" -p "$PORTNUMBER" "$NET" )
    ${SSH[@]} echo || { echo "SSH non-interactive not properly configured"; return 1; }
  }
  
  # Create hidden file with passphrase in root home directory
  echo "PASSPHRASE="$GPGPASSPHRASE"" > /root/.passphrase
  chmod 700 /root/.passphrase
  
  # Create file containing full sync commands
  cat > /usr/local/bin/ncp-rsync-encrypted-full <<'EOF'
#!/bin/bash
while getopts p:k:s:d:D:B: option
do
case "${option}"
in
p) PORTNUMBER=${OPTARG};;
k) GPGKEY=${OPTARG};;
s) DATADIR=${OPTARG};;
d) DESTINATION=${OPTARG};;
D) INCLUDEDATA=${OPTARG};;
B) INCLUDEDB=${OPTARG};;
esac
done

. /root/.passphrase
export PASSPHRASE
sudo -u www-data php /var/www/nextcloud/occ maintenance:mode --on
[[ "$INCLUDEDB" == "yes" ]] && { 
  dbdestination="/$( sed 's|.*//||' <<<$DESTINATION )"/database
  dbbackup=nextcloud-sqlbkp_$( date +"%Y%m%d" ).bak
  mysqldump --single-transaction nextcloud > /var/www/"$dbbackup"
  duplicity full --rsync-options="-ax --rsync-path=\"mkdir -p \"$dbdestination\" && rsync\"" --ssh-options="-p $PORTNUMBER" --encrypt-key "$GPGKEY" /var/www/"$dbbackup" rsync://"$DESTINATION"database
  duplicity remove-all-but-n-full 1 --ssh-options="-p $PORTNUMBER" --encrypt-key="$GPGKEY" --force rsync://"$DESTINATION"database
  rm /var/www/"$dbbackup"
}
[[ "$INCLUDEDATA" == "yes" ]] && { 
  datadestination="/$( sed 's|.*//||' <<<$DESTINATION )"/data
  duplicity full --rsync-options="-ax --rsync-path=\"mkdir -p \"$datadestination\" && rsync\"" --ssh-options="-p $PORTNUMBER" --encrypt-key "$GPGKEY" "$DATADIR" rsync://"$DESTINATION"data
  duplicity remove-all-but-n-full 1 --ssh-options="-p $PORTNUMBER" --encrypt-key="$GPGKEY" --force rsync://$"DESTINATION"data
}
sudo -u www-data php /var/www/nextcloud/occ maintenance:mode --off
unset PASSPHRASE
EOF
  chmod 755 /usr/local/bin/ncp-rsync-encrypted-full
  
  # Create file containing incremental sync commands
  cat > /usr/local/bin/ncp-rsync-encrypted-incr <<'EOF'
#!/bin/bash
while getopts p:k:s:d:D:B: option
do
case "${option}"
in
p) PORTNUMBER=${OPTARG};;
k) GPGKEY=${OPTARG};;
s) DATADIR=${OPTARG};;
d) DESTINATION=${OPTARG};;
D) INCLUDEDATA=${OPTARG};;
B) INCLUDEDB=${OPTARG};;
esac
done

. /root/.passphrase
export PASSPHRASE
sudo -u www-data php /var/www/nextcloud/occ maintenance:mode --on
[[ "$INCLUDEDB" == "yes" ]] && { 
  dbdestination="/$( sed 's|.*//||' <<<$DESTINATION )"/database
  dbbackup=nextcloud-sqlbkp_$( date +"%Y%m%d" ).bak
  mysqldump --single-transaction nextcloud > /var/www/"$dbbackup"
  duplicity --rsync-options="-ax --rsync-path=\"mkdir -p \"$dbdestination\" && rsync\"" --ssh-options="-p $PORTNUMBER" --encrypt-key "$GPGKEY" /var/www/"$dbbackup" rsync://"$DESTINATION"database
  rm /var/www/"$dbbackup"
}
[[ "$INCLUDEDATA" == "yes" ]] && { 
  datadestination="/$( sed 's|.*//||' <<<$DESTINATION )"/data
  duplicity --rsync-options="-ax --rsync-path=\"mkdir -p \"$datadestination\" && rsync\"" --ssh-options="-p $PORTNUMBER" --encrypt-key "$GPGKEY" "$DATADIR" rsync://"$DESTINATION"data
}
sudo -u www-data php /var/www/nextcloud/occ maintenance:mode --off
unset PASSPHRASE
EOF
  chmod 755 /usr/local/bin/ncp-rsync-encrypted-incr
  
  # Create cron entry to call sync files
  echo -e "0  5  */${SYNCDAYSFULL}  *  *  root /usr/local/bin/ncp-rsync-encrypted-full -p $PORTNUMBER -k $GPGKEY -s $DATADIR -d $DESTINATION -D $INCLUDEDATA -B $INCLUDEDB\n0  4  */${SYNCDAYSINCR}  *  *  root /usr/local/bin/ncp-rsync-encrypted-incr -p $PORTNUMBER -k $GPGKEY -s $DATADIR -d $DESTINATION -D $INCLUDEDATA -B $INCLUDEDB" > /etc/cron.d/ncp-rsync-encrypted-auto
  chmod 644 /etc/cron.d/ncp-rsync-encrypted-auto
  service cron restart

  echo "automatic encrypted rsync enabled"
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

