#!/bin/bish

# TODO

STATE_FILE=/home/pi/.installation_state
APTINSTALL="apt-get install -y --no-install-recommends"

install()
{
  test -f $STATE_FILE && STATE=$( cat $STATE_FILE 2>/dev/null )
  if [ "$STATE" == "" ]; then

    # RESIZE IMAGE
    ##########################################

    SECTOR=$( fdisk -l /dev/sda | grep Linux | awk '{ print $2 }' )
    echo -e "d\n2\nn\np\n2\n$SECTOR\n\nw\n" | fdisk /dev/sda || true

    echo 0 > $STATE_FILE 
    nohup reboot &>/dev/null &
  elif [ "$STATE" == "0" ]; then

    # UPDATE EVERYTHING
    ##########################################
    resize2fs /dev/sda2

    apt-get update
    apt-get upgrade -y
    apt-get dist-upgrade -y
    $APTINSTALL rpi-update 
    echo -e "y\n" | PRUNE_MODULES=1 rpi-update

    echo 1 > $STATE_FILE 
    nohup reboot &>/dev/null &
  elif [ "$STATE" == "1" ]; then
