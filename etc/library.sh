#!/bin/bash

# NextCloudPi function library
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at ownyourbits.com
#


# Initializes $INSTALLATION_CODE
function config()
{
  local INSTALL_SCRIPT="$1"
  local BACKTITLE="NextCloudPi installer configuration"

  type dialog &>/dev/null || { echo "please, install dialog for interactive configuration"; return 1; }

  test -f "$INSTALL_SCRIPT" || { echo "file $INSTALL_SCRIPT not found"; return 1; }
  local VARS=( $( grep "^[[:alpha:]]\+_=" "$INSTALL_SCRIPT" | cut -d= -f1 | sed 's|_$||' ) )
  local VALS=( $( grep "^[[:alpha:]]\+_=" "$INSTALL_SCRIPT" | cut -d= -f2 ) )

  [[ "$NO_CONFIG" == "1" ]] || test ${#VARS[@]} -eq 0 && { INSTALLATION_CODE="$( cat "$INSTALL_SCRIPT" )"; return; }

  for i in $( seq 1 1 ${#VARS[@]} ); do
    local PARAM+="${VARS[$((i-1))]} $i 1 ${VALS[$((i-1))]} $i 15 60 0 "
  done

  local DIALOG_OK=0
  local DIALOG_CANCEL=1
  local DIALOG_ERROR=254
  local DIALOG_ESC=255
  local RET=0

  while test $RET != 1 && test $RET != 250; do
    local value
    value=$( dialog --ok-label "Start" \
                    --no-lines --backtitle "$BACKTITLE" \
                    --form "Enter configuration for $( basename "$INSTALL_SCRIPT" .sh )" \
                    20 70 0 $PARAM \
             3>&1 1>&2 2>&3 )
    RET=$?

    case $RET in
      $DIALOG_CANCEL)
        return 1
        ;;
      $DIALOG_OK)
        local RET=( $value )
        for i in $( seq 0 1 $(( ${#RET[@]} - 1 )) ); do
          local SEDRULE+="s|^${VARS[$i]}_=.*|${VARS[$i]}_=${RET[$i]}|;"
          local CONFIG+="${VARS[$i]}=${RET[$i]}\n"
        done
        break
        ;;
      $DIALOG_ERROR)
        echo "ERROR!$value"
        return 1
        ;;
      $DIALOG_ESC)
        echo "ESC pressed."
        return 1
        ;;
      *)
        echo "Return code was $RET"
        return 1
        ;;
    esac
  done

  INSTALLATION_CODE="$( sed "$SEDRULE" "$INSTALL_SCRIPT" )"
}

function install_script()
{
  (
    local SCRIPT=$1
    source ./"$SCRIPT"
    echo -e "Installing $( basename "$SCRIPT" .sh )"
    set +x
    install
  )
}

function activate_script()
{
  local SCRIPT=$1
  echo -e "Activating $( basename "$SCRIPT" .sh )"
  launch_script "$SCRIPT"
}

function is_active_script()
{
  (
    local SCRIPT=$1
    unset is_active
    source "$SCRIPT"
    [[ $( type -t is_active ) == function ]] && {
      is_active
      return $?
    }
    grep -q "^ACTIVE_=yes" "$SCRIPT" && return 0
  )
}

function launch_script()
{
  (
    local SCRIPT=$1
    source ./"$SCRIPT"
    set +x
    configure
  )
}

# show an info box for a script if the INFO variable is set in the script
function info_script()
{
  (
    local SCRIPT=$1
    cd /usr/local/etc/nextcloudpi-config.d/ || return 1
    unset show_info INFO INFOTITLE
    source ./"$SCRIPT"
    local INFOTITLE="${INFOTITLE:-Info}"
    [[ "$INFO" == "" ]] && return 0
    whiptail --yesno --backtitle "NextCloudPi configuration" --title "$INFOTITLE" "$INFO" 20 90
  )
}

function configure_script()
{
  (
    local SCRIPT=$1
    cd /usr/local/etc/nextcloudpi-config.d/ || return 1
    config "$SCRIPT" || return 1                 # writes "$INSTALLATION_CODE"
    echo -e "$INSTALLATION_CODE" > "$SCRIPT"     # save configuration
    source ./"$SCRIPT"                           # load configuration
    printf '\033[2J' && tput cup 0 0             # clear screen, don't clear scroll, cursor on top
    echo -e "Launching $( basename "$SCRIPT" .sh )"
    set +x
    configure
    return 0
  )
}

function cleanup_script()
{
  (
    local SCRIPT=$1
    cd /usr/local/etc/nextcloudpi-config.d/ || return 1
    unset cleanup
    source ./"$SCRIPT"
    [[ $( type -t cleanup ) == function ]] && {
      cleanup
      return $?
    }
  )
}

function persistent_cfg()
{
  local SRC="$1"
  local DST="${2:-/data/etc/$( basename "$SRC" )}"
  mkdir -p "$( dirname "$DST" )"
  test -d "$DST" || {
    echo "Making $SRC persistent ..."
    mv    "$SRC" "$DST"
  }
  rm -rf "$SRC"
  ln -s "$DST" "$SRC"
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

