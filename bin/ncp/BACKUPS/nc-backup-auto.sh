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
  find_app_param nc-backup-auto DESTDIR
  )
}

configure()
{
  [[ $ACTIVE != "yes" ]] && {
    rm -f /etc/cron.d/ncp-backup-auto
    service cron restart
    echo "automatic backups disabled"
    return 0
  }

  cat > /usr/local/bin/ncp-backup-auto <<EOF
#!/bin/bash
source /usr/local/etc/library.sh
failed=
run_script()
{
        if [ -x /usr/local/bin/ncp-backup-auto-\$1 ]
        then
                /usr/local/bin/ncp-backup-auto-\$1 || failed="\$failed\${failed:+, } \$1"
        fi
}

run_script before
save_maintenance_mode
/usr/local/bin/ncp-backup "$DESTDIR" "$INCLUDEDATA" "$COMPRESS" "$BACKUPLIMIT" || failed="\$failed\${failed:+, } main"
restore_maintenance_mode
run_script after
if [[ -n "\$failed" ]]
then
  notify_admin "Auto-backup failed" "The \$failed backup script(s) failed"
fi
EOF
  chmod +x /usr/local/bin/ncp-backup-auto

  echo "0  3  */${BACKUPDAYS}  *  *  root  /usr/local/bin/ncp-backup-auto >> /var/log/ncp.log 2>&1" > /etc/cron.d/ncp-backup-auto
  chmod 644 /etc/cron.d/ncp-backup-auto
  service cron restart

  (
    . "${BINDIR}/SYSTEM/metrics.sh"
    reload_metrics_config
  )

  echo "automatic backups enabled"
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
