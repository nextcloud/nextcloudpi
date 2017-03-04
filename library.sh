#!/bin/bash

# Library to install software on Raspbian ARM through QEMU
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!


IMGOUT=$( basename $IMGFILE .img )_$( basename $INSTALL_SCRIPT .sh ).img
CFGOUT=config_$( basename $INSTALL_SCRIPT .sh ).txt

SSH=( ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ServerAliveInterval=5 -o ConnectTimeout=20 -o LogLevel=quiet )

function launch_install_qemu()
{
  local INSTALL_SCRIPT=$1
  local IMG=$2
  local IP=$3
  [[ "$IP" == "" ]] && { echo "usage: launch_install_qemu <script> <img> <IP>"; return 1; }
  test -f $IMG            || { echo "input file $IMG            not found"; return 1; }
  test -f $INSTALL_SCRIPT || { echo "input file $INSTALL_SCRIPT not found"; return 1; }

  # take a copy of the input image for processing ( append "-stage1" )
  local BASE=$( sed 's=-stage[[:digit:]]=='         <<< $IMG )
  local NUM=$(  sed 's=.*-stage\([[:digit:]]\)=\1=' <<< $IMG )
  [[ "$BASE" == "$IMG" ]] && NUM=0
  local IMGFILE="$BASE-stage$(( NUM+1 ))"
  cp -v $IMG $IMGFILE || return 1

  local NUM_REBOOTS=$( grep -c reboot $INSTALL_SCRIPT )
  while [[ $NUM_REBOOTS != -1 ]]; do
    launch_qemu $IMGFILE &
    sleep 10
    wait_SSH $IP
    sleep 120                               # FIXME for some reason, SSH is ready but fails if CPU still busy
    launch_installation $INSTALL_SCRIPT $IP
    wait 
    NUM_REBOOTS=$(( NUM_REBOOTS-1 ))
  done
  echo "$IMGFILE generated successfully"
}

function launch_qemu()
{
  local IMG=$1
  test -f $1 || { echo "Image $IMG not found"; return 1; }
  test -d qemu-raspbian-network || git clone https://github.com/nachoparker/qemu-raspbian-network.git
  sed -i '30s/NO_NETWORK=1/NO_NETWORK=0/' qemu-raspbian-network/qemu-pi.sh
  echo "Starting QEMU image $IMG"
  ( cd qemu-raspbian-network && sudo ./qemu-pi.sh ../$IMG 2>/dev/null )
}

function wait_SSH()
{
  local IP=$1
  echo "Waiting for SSH to be up on $IP..."
  while true; do
    sshpass -praspberry ${SSH[@]} pi@$IP ls &>/dev/null && break
    sleep 1
  done
  echo "SSH is up"
}

function launch_installation()
{
  local INSTALL_SCRIPT=$1
  local IP=$2
  test -f $1 || { echo "File $INSTALL_SCRIPT not found"; return 1; }
  echo "Launching installation"
  config $INSTALL_SCRIPT 4>&1 1>&2 2>&4 4>&- | sshpass -praspberry ${SSH[@]} pi@$IP | sed 1,7d
  echo "configuration saved to $CFGOUT"
}

function config()
{
  local INSTALL_SCRIPT="$1"
  local BACKTITLE="NextCloudPi installer configuration"

  test -f "$INSTALL_SCRIPT" || { echo "file "$INSTALL_SCRIPT" not found"; return 1; }
  local VARS=( $( grep "^[[:alpha:]]\+_=" "$INSTALL_SCRIPT" | cut -d= -f1 | sed 's|_$||' ) )
  local VALS=( $( grep "^[[:alpha:]]\+_=" "$INSTALL_SCRIPT" | cut -d= -f2 ) )

  test ${#VARS[@]} -eq 0 && { echo here; cat "$INSTALL_SCRIPT" >&2; return; }

  for i in `seq 1 1 ${#VARS[@]} `; do
    local PARAM+="${VARS[$((i-1))]} $i 1 ${VALS[$((i-1))]} $i 15 30 0 "
  done

  local DIALOG_OK=0
  local DIALOG_CANCEL=1
  local DIALOG_HELP=2
  local DIALOG_EXTRA=3
  local DIALOG_ITEM_HELP=4
  local DIALOG_ERROR=254
  local DIALOG_ESC=255
  local returncode=0

  while test $returncode != 1 && test $returncode != 250; do
    exec 3>&1
    local value
    value=$( dialog --ok-label "Submit" \
      --backtitle "$BACKTITLE" \
      --form "Enter the desired configuration" \
      20 50 0 $PARAM \
      2>&1 1>&3 )
    returncode=$?
    exec 3>&-

    case $returncode in
      $DIALOG_CANCEL)
        dialog \
          --clear \
          --backtitle "$BACKTITLE" \
          --yesno "Really quit?" 10 30
        case $? in
          $DIALOG_OK)
            break
            ;;
          $DIALOG_CANCEL)
            returncode=99
            ;;
        esac
        ;;
      $DIALOG_OK)
        dialog \
          --clear \
          --backtitle "$BACKTITLE" --no-collapse --cr-wrap \
          --yesno "The following configuration will be used\n\n$value" 10 60
        case $? in
          $DIALOG_OK)
            local RET=( $value )
            for i in `seq 0 1 $(( ${#RET[@]} - 1 )) `; do
              local SEDRULE+="s|^${VARS[$i]}_=.*|${VARS[$i]}_=${RET[$i]}|;"
              local CONFIG+="${VARS[$i]}=${RET[$i]}\n"
            done
            break
            ;;
          $DIALOG_CANCEL)
            returncode=99
            ;;
        esac
        ;;
      $DIALOG_HELP)
        echo "Button 2 (Help) pressed."
        return
        ;;
      $DIALOG_EXTRA)
        echo "Button 3 (Extra) pressed."
        return
        ;;
      $DIALOG_ERROR)
        echo "ERROR!$value"
        return
        ;;
      $DIALOG_ESC)
        echo "ESC pressed."
        return
        ;;
      *)
        echo "Return code was $returncode"
        return
        ;;
    esac
  done

  sed $SEDRULE "$INSTALL_SCRIPT" >&2
  echo -e "$CONFIG" > $CFGOUT
  clear
}

function pack_image()
{
  local IMGFILE="$1"
  local IMGOUT="$2"
  local TARNAME=$( basename $IMGOUT .img ).tar.bz2
  cp -v $( ls -1t $IMGFILE-stage* | head -1 ) $IMGOUT
  tar -I pbzip2 -cvf $TARNAME $IMGOUT &>/dev/null && \
    echo -e "$TARNAME packed successfully"
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

