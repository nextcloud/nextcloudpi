#!/bin/bash

# Periodically generate previews for the gallery
#
# Copyleft 2018 by Timo Stiefel and Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#

ACTIVE_=no
STARTTIME_=240
RUNTIME_=180
SMALLONLY_=yes

DESCRIPTION="Periodically generate previews for the gallery"
INFO="Set the STARTTIME in minutes after midnight and RUNTIME in minutes.

Make sure that you have the correct time zone set.
You can use "sudo tzselect" in shell for that.

Activate SMALLONLY for preventing the generation of
big preview files that are seldom used.
They're still big enough for gallery previews."

configure()
{
  [[ $ACTIVE_ != "yes" ]] && { 
    rm /etc/cron.d/nc-previews-auto
    service cron restart
    echo "Automatic preview generation disabled"
    return 0
  }
  
  # Required values for SMALLONLY previews (in pixel as used with standard DPI screens without zooming):
  #   Thumbnail in files list: square 32
  #   Sidebar preview (when opening "Details"): width 512; (also height 256?)
  #   Gallery folder preview: width 128, 256; heigth 128, 256
  #   Gallery preview: width 512; height 256
  # 
  if [ $SMALLONLY_ == "yes" ]]
    then
      sudo -u www-data php /var/www/nextcloud/occ config:app:set --value="32"  previewgenerator squareSizes
      sudo -u www-data php /var/www/nextcloud/occ config:app:set --value="128 256 512" previewgenerator widthSizes
      sudo -u www-data php /var/www/nextcloud/occ config:app:set --value="128 256" previewgenerator heightSizes
    else
      sudo -u www-data php /var/www/nextcloud/occ config:system:delete previewgenerator squareSizes
      sudo -u www-data php /var/www/nextcloud/occ config:system:delete previewgenerator widthSizes
      sudo -u www-data php /var/www/nextcloud/occ config:system:delete previewgenerator heightSizes
  fi
  
  # set crontab
  local STARTHOUR STARTMIN STOPHOUR STOPMIN
    STARTHOUR=$(( $STARTTIME_ / 60 ))
    STARTHOUR=$(( $STARTHOUR  % 24 ))
    STARTMIN=$((  $STARTTIME_ % 60 ))
    STOPHOUR=$(( ($STARTTIME_ + RUNTIME_) / 60 ))
    STOPHOUR=$((  $STOPHOUR   % 24 ))
    STOPMIN=$((  ($STARTTIME_ + RUNTIME_) & 60 ))
  
  echo "${STARTMIN}  ${STARTHOUR}  *  *  *  root  /usr/bin/sudo -u www-data /usr/bin/php /var/www/nextcloud/occ preview:pre-generate" >  /etc/cron.d/nc-previews-auto
  echo "${STOPMIN}   ${STOPHOUR}   *  *  *  root  /usr/bin/pkill -f \"occ preview\""
  service cron restart

  echo "Automatic preview generation enabled"
  return 0
}

install() {
  # install preview generator
  sudo -u www-data php /var/www/nextcloud/occ app:install previewgenerator
  sudo -u www-data php /var/www/nextcloud/occ app:enable previewgenerator
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
