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
[[ $( ls -1A /data | wc -l ) -eq 0 ]] && { echo "Initializing empty volume.."; cp -raT /data-ro /data; }

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
