#!/bin/bash

cleanup()
{
  for file in $( ls -1rv /etc/services.d ); do
    /etc/services.d/"$file" stop "$1"
  done
  exit
}

trap cleanup SIGTERM

for file in $( ls -1v /etc/services.d ); do
  /etc/services.d/"$file" start "$1"
done

echo "Init done"
while true; do sleep 0.5; done # do nothing, just wait for trap from 'docker stop'
