#!/bin/bash

# Updaterfor  NextCloudPi
# Tested with 2017-03-02-raspbian-jessie-lite.img
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at https://ownyourbits.com/
#

cp etc/library.sh /usr/local/etc/

source /usr/local/etc/library.sh

# copy all files in bin and etc
for file in bin/* etc/*; do
  [ -f $file ] || continue;
  cp $file /usr/local/$file
done

# install new entries of nextcloudpi-config and update others
for file in etc/nextcloudpi-config.d/*; do
  [ -f $file ] || continue;    # skip dirs
  [ -f /usr/local/$file ] || { # new entry
    install_script $file       # install

    # configure if active by default
    grep -q '^ACTIVE_=yes$' $file && activate_script $file 
  }

  # save current configuration to (possibly) updated script
  [ -f /usr/local/$file ] && {
    VARS=( $( grep "^[[:alpha:]]\+_=" /usr/local/$file | cut -d= -f1 ) )
    VALS=( $( grep "^[[:alpha:]]\+_=" /usr/local/$file | cut -d= -f2 ) )
    for i in `seq 0 1 ${#VARS[@]} `; do
      sed -i "s|^${VARS[$i]}=.*|${VARS[$i]}=${VALS[$i]}|" $file
    done
  }

  cp $file /usr/local/$file
done

# these files can contain sensitive information, such as passwords
chmod 700 /usr/local/etc/nextcloudpi-config.d/*

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

