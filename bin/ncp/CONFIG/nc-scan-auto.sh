#!/bin/bash

# Periodically synchronize NextCloud for externally modified files
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at: https://ownyourbits.com
#



configure()
{
    [[ $ACTIVE != "yes" ]] && {
    rm -f /etc/cron.d/ncp-scan-auto
    service cron restart
    echo "automatic scans disabled"
    return 0
  }

  # set crontab
  local days hour mins
  days=$(( SCANINTERVAL / 1440 ))
  if [[ "$days" != "0" ]]; then
    days="*/$days" hour="1" mins="15"
  else
    days="*"
    hour=$(( SCANINTERVAL / 60   ))
    mins=$(( SCANINTERVAL % 60   ))
    mins="*/$mins"
    [[ $hour == 0 ]] && hour="*" || { hour="*/$hour" mins="15"; }
  fi

  [[ "$RECURSIVE"   == no  ]] && local recursive=--shallow
  [[ "$NONEXTERNAL" == yes ]] && local non_external=--home-only

  cat > /usr/local/bin/ncp-scan-auto <<EOF
#!/bin/bash
(

  echo -e "\n[ nc-scan-auto ]"

  [[ "$PATH1" != "" ]] && /usr/local/bin/ncc files:scan $recursive $non_external -n -v -p "$PATH1"
  [[ "$PATH2" != "" ]] && /usr/local/bin/ncc files:scan $recursive $non_external -n -v -p "$PATH2"
  [[ "$PATH3" != "" ]] && /usr/local/bin/ncc files:scan $recursive $non_external -n -v -p "$PATH3"

  [[ "${PATH1}${PATH2}${PATH3}" == "" ]] && /usr/local/bin/ncc files:scan $recursive $non_external -n -v --all

) 2>&1 >>/var/log/ncp.log
EOF
chmod +x /usr/local/bin/ncp-scan-auto

  echo "${mins}  ${hour}  ${days}  *  *  root /usr/local/bin/ncp-scan-auto" > /etc/cron.d/ncp-scan-auto
  chmod 644 /etc/cron.d/ncp-scan-auto
  service cron restart

  echo "automatic scans enabled"
}

install() { :; }

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

