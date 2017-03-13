#!/bin/bash

# Fail2ban installation script for Raspbian 
# Tested with 2017-03-02-raspbian-jessie-lite.img
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh fail2ban.sh <IP> (<img>)
#
# See installer.sh instructions for details
#

# location of Nextcloud logs
NCLOG_=/var/www/nextcloud/data/nextcloud.log     

# time to ban an IP that exceeded attempts
BANTIME_=600

# cooldown time for incorrect passwords
FINDTIME_=600                                    

# bad attempts before banning an IP
MAXRETRY_=6                                      

DESCRIPTION="Brute force protection"

install()
{
  apt-get update
  apt-get install fail2ban -y
  update-rc.d fail2ban disable
}

configure()
{
  touch /var/www/nextcloud/data/nextcloud.log
  chown -R www-data /var/www/nextcloud/data

  cd /var/www/nextcloud
  sudo -u www-data php occ config:system:set loglevel --value=2
  sudo -u www-data php occ config:system:set log_type --value=file
  sudo -u www-data php occ config:system:set logfile  --value=$NCLOG_

  cat > /etc/fail2ban/filter.d/nextcloud.conf <<'EOF'
[INCLUDES]
before = common.conf

[Definition]
failregex = Login failed.*Remote IP.*'<HOST>'
ignoreregex =
EOF


  cat > /etc/fail2ban/jail.conf <<EOF
# The DEFAULT allows a global definition of the options. They can be overridden
# in each jail afterwards.
[DEFAULT]

# "ignoreip" can be an IP address, a CIDR mask or a DNS host. Fail2ban will not
# ban a host which matches an address in this list. Several addresses can be
# defined using space separator.
ignoreip = 127.0.0.1/8

# "bantime" is the number of seconds that a host is banned.
bantime  = $BANTIME_

# A host is banned if it has generated "maxretry" during the last "findtime"
# seconds.
findtime = $FINDTIME_
maxretry = $MAXRETRY_

#
# ACTIONS
#
banaction = iptables-multiport
protocol = tcp
chain = INPUT
action_ = %(banaction)s[name=%(__name__)s, port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]
action_mw = %(banaction)s[name=%(__name__)s, port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]
action_mwl = %(banaction)s[name=%(__name__)s, port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]
action = %(action_)s

#
# SSH
#

[ssh]

enabled  = true
port     = ssh
filter   = sshd
logpath  = /var/log/auth.log
maxretry = $MAXRETRY_

#
# HTTP servers
#

[nextcloud]

enabled  = true
port     = http,https
filter   = nextcloud
logpath  = $NCLOG_
maxretry = $MAXRETRY_
EOF
  update-rc.d fail2ban defaults
  service fail2ban restart
}

cleanup()
{
  apt-get autoremove -y
  apt-get clean
  rm /var/lib/apt/lists/* -r
  rm -f /home/pi/.bash_history
  systemctl disable ssh
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

