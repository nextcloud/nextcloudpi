#!/bin/bash

cleanup()
{

  for file in $( ls -1rv /etc/services-enabled.d ); do
    /etc/services-enabled.d/"$file" stop "$1"
  done
  exit
}

trap cleanup SIGTERM

# if an empty volume is mounted to /data, pre-populate it
if [[ $( ls -1A /data | wc -l ) -eq 0 ]]
then
  echo "Initializing empty volume.."
  cp -raT /data-ro /data
fi

CURRENT_NC_VERSION="$(sudo -u www-data php -r "include(\"/data/nextcloud/config/config.php\"); echo(\$CONFIG[\"version\"]);")"
CURRENT_NC_MAJ="${CURRENT_NC_VERSION%%.*}"
[[ "$CURRENT_NC_MAJ" -ge "$MINIMUM_NC_VERSION" ]] || {
  echo "This image of NCP requires at least Nextcloud version ${MINIMUM_NC_VERSION} but you have ${CURRENT_NC_VERSION} installed. " \
    "Please upgrade your Nextcloud first (using the web UI on an older NCP image), before upgrading to this NCP version."
  exit 1
}


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


if [[ "$NOBACKUP" != "true" ]] && ! a2query -s ncp-activation -q
then
  BKPDIR=/data/docker-startup-backups
  WITH_DATA=no
  COMPRESSED=yes
  LIMIT=5
  mkdir -p "$BKPDIR"
  echo "Back up current instance..."
  ncp-backup "$BKPDIR" "$WITH_DATA" "$COMPRESSED" "$LIMIT" || echo 'WARN: Backup creation failed'
fi

# wait for trap from 'docker stop'
echo "Init done"
while true; do sleep 0.5; done


