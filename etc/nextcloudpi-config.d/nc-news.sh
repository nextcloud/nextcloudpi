#!/bin/bash

# Install the latest News third party app
# Tested with 2017-03-02-raspbian-jessie-lite.img
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh nc-news.sh <IP> (<img>)
#
# See installer.sh instructions for details
# More at: https://ownyourbits.com
#

NCDIR_=/var/www/nextcloud
DESCRIPTION="Install the latest News third party app"

configure() 
{
  test -d $NCDIR_/apps/news && { echo "The news directory already exists"; return 1; }
  local URL=$( curl -s https://api.github.com/repos/nextcloud/news/releases | \
    grep browser_download_url | head -1 | cut -d '"' -f 4 )
  cd $NCDIR_/apps/

  echo "Downloading..."
  wget $URL           || return 1

  echo "Installing..."
  tar -xf news.tar.gz || return 1
  rm *.tar.gz
  cd $NCDIR_
  sudo -u www-data php "$NCDIR_"/occ app:enable news
}

install() { :; }
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

