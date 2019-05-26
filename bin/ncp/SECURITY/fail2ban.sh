#!/bin/bash

# Fail2ban for NextCloudPi
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at: https://ownyourbits.com/2017/02/24/nextcloudpi-fail2ban-installer/
#


# time to ban an IP that exceeded attempts

# cooldown time for incorrect passwords

# bad attempts before banning an IP


# Option to activate email notifications

# email to send notifications to


install()
{
  apt-get update
  apt-get install --no-install-recommends -y fail2ban whois
  update-rc.d fail2ban disable
  rm -f /etc/fail2ban/jail.d/defaults-debian.conf

  [[ "$DOCKERBUILD" == 1 ]] && {
    cat > /etc/services-available.d/100fail2ban <<EOF
#!/bin/bash

source /usr/local/etc/library.sh

[[ "\$1" == "stop" ]] && {
  echo "stopping fail2ban..."
  service fail2ban stop
  exit 0
}

persistent_cfg /etc/fail2ban

echo "Starting fail2ban..."
service fail2ban start

exit 0
EOF

  cat > /etc/fail2ban/filter.d/ufwban.conf <<'EOF'
[INCLUDES]
before = common.conf
[Definition]
failregex = UFW BLOCK.* SRC=
ignoreregex =
EOF
    chmod +x /etc/services-available.d/100fail2ban
  }

  # tweak fail2ban email
  local F=/etc/fail2ban/action.d/sendmail-common.conf
  sed -i 's|Fail2Ban|NextCloudPi|' /etc/fail2ban/action.d/sendmail-whois-lines.conf
  grep -q actionstart_ "$F" || sed -i 's|actionstart|actionstart_|' "$F"
  grep -q actionstop_  "$F" || sed -i 's|actionstop|actionstop_|'   "$F"

}

configure()
{
  [[ $ACTIVE != "yes" ]] && {
    service fail2ban stop
    update-rc.d fail2ban disable
    echo "fail2ban disabled"
    return
  }

  local NCLOG="/var/www/nextcloud/data/nextcloud.log"
  local NCLOG1="$( sudo -u www-data php /var/www/nextcloud/occ config:system:get logfile )"

  [[ "$NCLOG1" != "" ]] && NCLOG="$NCLOG1"

  local BASEDIR=$( dirname "$NCLOG" )
  [ -d "$BASEDIR" ] || { echo -e "directory $BASEDIR not found"; return 1; }

  sudo -u www-data touch "$NCLOG" || { echo -e "ERROR: user www-data does not have write permissions on $NCLOG"; return 1; }

  cd /var/www/nextcloud
  sudo -u www-data php occ config:system:set loglevel --value=2
  sudo -u www-data php occ config:system:set log_type --value=file

  cat > /etc/fail2ban/filter.d/nextcloud.conf <<'EOF'
[INCLUDES]
before = common.conf

[Definition]
failregex = Login failed.*Remote IP.*'<HOST>'
ignoreregex =
EOF

  [[ "$MAILALERTS" == "yes" ]] && local ACTION=action_mwl || local ACTION=action_

  cat > /etc/fail2ban/jail.conf <<EOF
# The DEFAULT allows a global definition of the options. They can be overridden
# in each jail afterwards.
[DEFAULT]

# "ignoreip" can be an IP address, a CIDR mask or a DNS host. Fail2ban will not
# ban a host which matches an address in this list. Several addresses can be
# defined using space separator.
ignoreip = 127.0.0.1/8

# "bantime" is the number of seconds that a host is banned.
bantime  = $BANTIME

# A host is banned if it has generated "maxretry" during the last "findtime"
# seconds.
findtime = $FINDTIME
maxretry = $MAXRETRY

#
# ACTIONS
#
banaction  = iptables-multiport
protocol   = tcp
chain      = INPUT
action_    = %(banaction)s[name=%(__name__)s, port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]
action_mwl = %(banaction)s[name=%(__name__)s, port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]
           sendmail-whois-lines[name=%(__name__)s, dest=$EMAIL, sender=ncp-fail2ban@ownyourbits.com]
action = %($ACTION)s

#
# SSH
#

[ssh]

enabled  = true
port     = ssh
filter   = sshd
logpath  = /var/log/auth.log
maxretry = $MAXRETRY

#
# HTTP servers
#

[nextcloud]

enabled  = true
port     = http,https
filter   = nextcloud
logpath  = $NCLOG
maxretry = $MAXRETRY

[ufwban]
enabled = true
port = ssh, http, https
filter = ufwban
logpath = /var/log/ufw.log
action = ufw
EOF
  cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
  update-rc.d fail2ban defaults
  update-rc.d fail2ban enable
  service fail2ban restart
  echo "fail2ban enabled"
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

