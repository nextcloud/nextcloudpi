#!/bin/bash

# Generate previews for the gallery
#
# Copyleft 2018 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at nextcloudpi.com
#


configure()
{
  # Disable during build
  ! [[ -f /.ncp-image ]] || return 0

  pgrep -af preview:pre-generate &>/dev/null || pgrep -af preview:generate-all &>/dev/null && {
    echo "nc-previews is already running"
    return 1
  }

  if ! [[ -f /.ncp-image ]]
  then
    ncc app:getpath previewgenerator > /dev/null || ncc app:install previewgenerator
    is_app_enabled previewgenerator || ncc app:enable previewgenerator
    ncc config:app:set --value="64 256" previewgenerator squareSizes
    ncc config:app:set --value="256 4096" previewgenerator fillWidthHeightSizes
    ncc config:app:set --value="64 256 1024" previewgenerator widthSizes
    ncc config:app:set --value="64 256 1024" previewgenerator heightSizes
    if is_app_enabled memories
    then
      ncc config:app:set --value="256 4096" previewgenerator coverWidthHeightSizes
    else
      ncc config:app:set --value="" previewgenerator coverWidthHeightSizes
    fi
  fi


  [[ "$CLEAN" == "yes" ]] && {
    if [[ "$(nc_version)" -lt 31 ]]
    then
      echo "ERROR: CLEAN not supported for Nextcloud < 31"
    else
      ncc preview:cleanup
    fi
  }

  [[ "$INCREMENTAL" == "yes" ]] && {
    for _ in $(seq 1 $(nproc)); do
      ncc preview:pre-generate -n -vvv &
    done
    wait
    return
  }

  for _ in $(seq 1 $(nproc)); do
    [[ "$PATH1" != "" ]] && PATH_ARG=(-p "$PATH1")
    ncc preview:generate-all -n -v "${PATH_ARG[@]}" &
  done
  wait

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

