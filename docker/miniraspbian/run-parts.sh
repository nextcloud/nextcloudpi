#!/bin/bash

cleanup()
{
  for file in $( ls -1rv /etc/cont-init.d ); do
    /etc/cont-init.d/$file stop
  done
  exit
}

trap cleanup SIGTERM

for file in $( ls -1v /etc/cont-init.d ); do
  /etc/cont-init.d/$file start
done

echo "Init done"
while true; do sleep 0.5; done # do nothing, just wait for trap from 'docker stop'
