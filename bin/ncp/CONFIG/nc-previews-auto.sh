#!/bin/bash

# Periodically generate previews for the gallery
#
# Copyleft 2019 by Timo Stiefel and Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#

isactive()
{
  [[ -f "/etc/cron.hourly/ncp-previewgenerator" ]]
}

configure()
{
  # Disable during build
  ! [[ -f /.ncp-image ]] || return 0

  [[ "$ACTIVE" != "yes" ]] && {
    rm -f "/etc/cron.hourly/ncp-previewgenerator"
    echo "Automatic preview generation disabled"
    return 0
  }

  ncc app:getpath previewgenerator > /dev/null || ncc app:install previewgenerator
  is_app_enabled previewgenerator || ncc app:enable previewgenerator
  ncc config:app:set --value="64 256" previewgenerator squareSizes
  ncc config:app:set --value="256 4096" previewgenerator fillWidthHeightSizes
  ncc config:app:set --value="64 256 1024" previewgenerator widthSizes
  ncc config:app:set --value="64 256 1024" previewgenerator heightSizes
  ncc config:app:set --value=false --type=boolean previewgenerator job_disabled
  ncc config:app:set --value=3000 --type=integer previewgenerator job_max_execution_time
  ncc config:app:set --value=0 --type=integer previewgenerator job_max_previews

  mkdir -p /etc/cron.hourly
  install_template cron.hourly/ncp-previewgenerator.sh /etc/cron.hourly/ncp-previewgenerator
  chmod +x /etc/cron.hourly/ncp-previewgenerator
  echo "Automatic preview generation enabled"
  return 0
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
