#!/bin/bash
# Nextcloud backups
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/
#

tmpl_get_destination() {
  (
  . /usr/local/etc/library.sh
  find_app_param nc-backup DESTDIR
  )
}

install()
{
  apt-get update
  apt-get install -y --no-install-recommends pigz

  cat > /usr/local/bin/ncp-backup <<'EOF'
#!/bin/bash
set -eE
source /usr/local/etc/library.sh

if [ "$1" = "--help" ]; then
 echo "$0 <destdir> <includedata> <compress> <backuplimit>"
 echo " <includedata> and <compress> are 'yes' or 'no'"
 echo " <backuplimit> integer >= 1 or 0 for no limit"
 exit 0
fi

destdir="${1:-/media/USBdrive/ncp-backups}"
includedata="${2:-no}"
compress="${3:-no}"
backuplimit="${4:-0}"

destfile="$destdir"/nextcloud-bkp_$( date +"%Y%m%d_%s" ).tar
dbbackup=nextcloud-sqlbkp_$( date +"%Y%m%d" ).bak
occ="sudo -u www-data php /var/www/nextcloud/occ"
[[ -f /.docker-image ]] && basedir=/data || basedir=/var/www

[[ "$compress" == "yes" ]] && destfile="$destfile".gz

datadir=$( get_nc_config_value datadirectory ) || {
  echo "Error reading data directory. Is NextCloud running and configured?";
  exit 1;
}

cleanup(){ local ret=$?;                    rm -f "${dbbackup}"              ; restore_maintenance_mode; exit $ret; }
fail()   { local ret=$?; echo "Abort..."  ; rm -f "${dbbackup}" "${destfile}"; restore_maintenance_mode; exit $ret; }
trap cleanup EXIT
trap fail INT TERM HUP ERR

echo "check free space..." # allow at least ~500 extra MiB
mkdir -p "$destdir"
nsize=$(du -sb "$basedir/nextcloud" | awk '{ print $1 }')
[[ -d "$basedir/nextcloud"/data ]] && \
  dsize=$(du -sb "$basedir/nextcloud"/data | awk '{ print $1 }')
margin=$((500*1024*1024))                  # safety margin for database and some extra
if [[ "$includedata" == "yes" ]]; then
  datasize=$(du -sb "$datadir" | awk '{ print $1 }')
  size=$((nsize - dsize + margin + datasize))
else
  size=$((nsize - dsize + margin))
fi
free=$( df -B1 "$destdir" | tail -1 | awk '{ print $4 }' )

[ $size -ge $free ] && {
  echo "free space check failed. Need $size Bytes";
  exit 1;
}

# delete older backups
[[ $backuplimit != 0 ]] && {
  numbkps=$( ls "$destdir"/nextcloud-bkp_* 2>/dev/null | wc -l )
  [[ $numbkps -ge $backuplimit ]] && \
    ls -t $destdir/nextcloud-bkp_* | tail -$(( numbkps - backuplimit + 1 )) | while read -r f; do
      echo "clean up old backup $f"
      rm "$f"
    done
}

# database
save_maintenance_mode
cd "$basedir" || exit 1
echo "backup database..."
mysqldump -u root --single-transaction nextcloud > "$dbbackup"

# files
echo "backup files..."
[[ "$includedata" == "yes" ]] && data="$(basename "$datadir")"
[[ "$compress"    == "yes" ]] && compress_arg="-I pigz"
mkdir -p "$destdir"
tar $compress_arg -cf "$destfile" \
\
    "$dbbackup" \
\
    --exclude "$data/.opcache" \
    --exclude "$data/{access,error,nextcloud}.log" \
    --exclude "$data/access.log" \
    --exclude "$data/ncp-update-backups" \
    -C "$(dirname "$datadir"/)" $data \
\
    --exclude "nextcloud/data/*/files/*" \
    --exclude "nextcloud/data/.opcache" \
    --exclude "nextcloud/data/{access,error,nextcloud}.log" \
    --exclude "nextcloud/data/access.log" \
    --exclude "nextcloud/data/appdata_*/preview/*" \
    --exclude "nextcloud/data/*/uploads/*" \
    --exclude "nextcloud/data/*/cache/*" \
    --exclude "nextcloud/data/*/files_trashbin/*" \
    --exclude "nextcloud/data/*/files_versions/*" \
    --exclude "nextcloud/data/ncp-update-backups" \
    --exclude "nextcloud/data/__groupfolders" \
    --exclude "nextcloud/.data_*" \
    -C $basedir nextcloud/ \
  || {
        echo "error generating backup"
        exit 1
      }
rm "$dbbackup"
chmod 640 "$destfile"
chown :www-data "$destfile"

echo "backup $destfile generated"
EOF
  chmod +x /usr/local/bin/ncp-backup
}

configure()
{
  (
    . "${BINDIR}/SYSTEM/metrics.sh"
    reload_metrics_config
  )
  ncp-backup "$DESTDIR" "$INCLUDEDATA" "$COMPRESS" "$BACKUPLIMIT"
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

