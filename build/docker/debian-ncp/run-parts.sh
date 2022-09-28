#!/bin/bash

cleanup()
{
  if [[ -z "$NOBACKUP" ]] || [[ "$NOBACKUP" != "true" ]]
  then
    BKPDIR=/data/docker-shutdown-backups/
    WITH_DATA=no
    COMPRESSED=yes
    LIMIT=0
    mkdir -p "$BKPDIR"
    echo "Cleanup old shutdown backups..."
    skip_bkp_cleanup=0
    BKPS="$(ls -1t "$BKPDIR"/nextcloud-bkp_*.tar.gz 2>/dev/null || skip_bkp_cleanup=1)"
    if [[ "$skip_bkp_cleanup" == 0 ]]
    then
      while read -r bkp
      do
        rm -f "$BKPDIR/$bkp"
      done <"$(echo "$BKPS" | tail -n +5)"
    fi
    echo "Back up current instance..."
    set +eE
    if ncp-backup "$BKPDIR" "$WITH_DATA" "$COMPRESSED" "$LIMIT"
    then
      echo "Backup stored at '$BKPDIR/$(ls -1t "$BKPDIR"/nextcloud-bkp_*.tar.gz 2>/dev/null | head -n1)'"
    else
      echo 'WARN: Backup creation failed'
    fi
  fi

  for file in $( ls -1rv /etc/services-enabled.d ); do
    /etc/services-enabled.d/"$file" stop "$1"
  done
  exit
}

grep '/data-ro' /etc/mysql/mariadb.conf.d/90-ncp.cnf > /dev/null 2>&1 && {
  echo "WARNING: Looks like you have been affected by a critical bug in NCP that can cause data loss. We're trying" \
     "to fix this now, but if you encounter any issues, please check" \
     "https://github.com/nextcloud/nextcloudpi/issues/1577#issuecomment-1260830341" \
     "It is likely that you will have to restore a backup"
  chown -R mysql: /data/database || true
}
sed -i 's|/data-ro|/data|' "/etc/mysql/mariadb.conf.d/90-ncp.cnf" || true

trap cleanup SIGTERM

# if an empty volume is mounted to /data, pre-populate it
if [[ $( ls -1A /data | wc -l ) -eq 0 ]]
then
  echo "Initializing empty volume.."
  cp -raT /data-ro /data
fi

# wrapper to simulate update-rc.d
cat > /usr/local/sbin/update-rc.d <<'EOF'
#!/bin/bash
FILE=/etc/services-available.d/???"$1"

test -f $FILE || {
  echo "$1 doesn't exist"
  exit 0
}

[[ "$2" == "enable" ]] && {
  ln -sf $FILE /etc/services-enabled.d/$( basename $FILE )
  echo "enabled $1"
  exit 0
}

[[ "$2" == "disable" ]] && {
  rm -f /etc/services-enabled.d/$( basename $FILE )
  echo "disabled $1"
  exit 0
}
EOF
chmod +x /usr/local/sbin/update-rc.d

# Iterate only over 000* entries which might setup environment
for file in $( ls -1v /etc/services-enabled.d | grep ^000.* ); do
  /etc/services-enabled.d/"$file" start "$1"
done

# Iterate over remaining entries
for file in $( ls -1v /etc/services-enabled.d | grep -v ^000.* ); do
  /etc/services-enabled.d/"$file" start "$1"
done

# wait for trap from 'docker stop'
echo "Init done"
while true; do sleep 0.5; done

}
