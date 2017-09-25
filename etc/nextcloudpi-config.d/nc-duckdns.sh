#!/bin/bash

# DuckDNS installation on Raspbian for NextcloudPi
#
#
# Copyleft 2017 by Courtney Hicks
# GPL licensed (see end of file) * Use at your own risk!
#

ACTIVE_=no
DOMAIN_=yourduckdnsdomain
TOKEN_=your-duckdns-token
INSTALLDIR=duckdns
INSTALLPATH=/etc/$INSTALLDIR
CRONFILE=/etc/cron.d/duckdns
DESCRIPTION="Free Dynamic DNS provider (need account from https://duckdns.org)"

install() { :; }


configure() 
{

   if [[ $ACTIVE_ == "yes" ]]; then
      mkdir $INSTALLPATH 2> /dev/null
      # Creates duck.sh script that checks for updates to DNS records
      touch $INSTALLPATH/duck.sh
      touch $INSTALLPATH/duck.log
      echo -e "echo url=\"https://www.duckdns.org/update?domains=$DOMAIN_&token=$TOKEN_&ip=\" | curl -k -o $INSTALLPATH/duck.log -K -" > $INSTALLPATH/duck.sh
      
      # Adds file to cron to run script for DNS record updates and change permissions 
      touch $CRONFILE
      echo "*/5 * * * * $INSTALLPATH/duck.sh >/dev/null 2>&1" > $CRONFILE
      chmod 700 $INSTALLPATH/duck.sh
      chmod +x $CRONFILE
      
      # First-time execution of duck script
      $INSTALLPATH/duck.sh > /dev/null 2>&1
      
      SUCCESS=`cat $INSTALLPATH/duck.log`
      
      # Checks for successful run of duck.sh
      if [[ $SUCCESS == "OK" ]]; then
         echo "DuckDNS is enabled"
      elif [[ $SUCCESS == "KO" ]]; then
         echo "DuckDNS install failed, is your information correct?"
      fi
	
	# Removes config files and cron job if ACTIVE_ is set to no
   elif [[ $ACTIVE_ == "no" ]]; then
      rm $CRONFILE 2> /dev/null
      rm $INSTALLPATH/duck.sh 2> /dev/null
      rm $INSTALLPATH/duck.log 2> /dev/null
      rmdir $INSTALLPATH 2> /dev/null
      echo "DuckDNS is now disabled"
	fi
}


cleanup() { :; }

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
