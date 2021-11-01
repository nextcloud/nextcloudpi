#!/bin/bash

# Restore Nextcloud data from S3-compatible storage via restic
#
# Copyleft 2021 by Thomas Heller
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at: https://ownyourbits.com
#

install()
{
  apt-get update
  apt-get install --no-install-recommends -y restic
}

configure()
{
  local start=$(date +%s)

  [[ "$S3_BUCKET_URL" == "" ]] && {
    echo "error: please specify S3 bucket URL"
    return 1
  }

  [[ "$S3_KEY_ID" == "" ]] && {
    echo "error: please specify S3 key ID"
    return 2
  }

  [[ "$S3_SECRET_KEY" == "" ]] && {
    echo "error: please specify S3 secret key"
    return 3
  }

  [[ "$RESTIC_PASSWORD" == "" ]] && {
    echo "error: please specify restic password"
    return 4
  }

  save_maintenance_mode || {
    echo "error: failed to activate Nextcloud maintenance mode"
    return 5
  }

  local DATADIR
  DATADIR=$( sudo -u www-data php /var/www/nextcloud/occ config:system:get datadirectory ) || {
    echo -e "Error reading data directory. Is NextCloud running and configured?"
    return 6
  }

  echo "restoring to $DATADIR"

  AWS_ACCESS_KEY_ID="$S3_KEY_ID" AWS_SECRET_ACCESS_KEY="$S3_SECRET_KEY" RESTIC_PASSWORD="$RESTIC_PASSWORD" restic -r "s3:$S3_BUCKET_URL/ncp-backup" --verbose restore latest --target "$DATADIR" || {
    echo "error: restic restore failed"
    return 7
  }

  echo "successfully restored backup"

  restore_maintenance_mode || {
    echo "error: failed to disabled Nextcloud maintenance mode"
    echo "notice: backup has been restored anyways"
    return 8
  }

  local end=$(date +%s)

  echo "restore complete after $((($end-$start)/60)) minute(s)"
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
