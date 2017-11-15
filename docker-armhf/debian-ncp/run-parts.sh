#!/bin/bash

cleanup()
{
  for file in $( ls -1rv /etc/services-enabled.d ); do
    /etc/services-enabled.d/"$file" stop "$1"
  done
  exit
}

trap cleanup SIGTERM

cat > /usr/local/sbin/update-rc.d <<'EOF'
#!/bin/bash
FILE=/etc/services-available.d/???"$1"

test -f $FILE || {
  echo "$1 doesn't exist"
  exit 1
}

[[ "$2" == "enable" ]] && {
  ln -s $FILE /etc/services-enabled.d/$( basename $FILE )
  echo "enabled $1"
  exit 0
}

rm -f /etc/services-enabled.d/$( basename $FILE )
echo "disabled $1"
EOF
chmod +x /usr/local/sbin/update-rc.d

for file in $( ls -1v /etc/services-enabled.d ); do
  /etc/services-enabled.d/"$file" start "$1"
done

echo "Init done"
while true; do sleep 0.5; done # do nothing, just wait for trap from 'docker stop'
