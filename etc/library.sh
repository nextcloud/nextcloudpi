#!/bin/bash

# NextCloudPi function library
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at ownyourbits.com
#

CFGDIR=/usr/local/etc/ncp-config.d
BINDIR=/usr/local/bin/ncp

function configure_app()
{
  local ncp_app="$1"
  local cfg_file="$CFGDIR/$ncp_app.cfg"
  local backtitle="NextCloudPi installer configuration"
  local ret=1

  # checks
  type dialog &>/dev/null || { echo "please, install dialog for interactive configuration"; return 1; }
  [[ -f "$cfg_file" ]]    || return 0;

  local cfg="$( cat "$cfg_file" )"
  local len="$(jq  '.params | length' <<<"$cfg")"
  [[ $len -eq 0 ]] && return

  # read cfg parameters
  for (( i = 0 ; i < len ; i++ )); do
    local var="$(jq -r ".params[$i].id"    <<<"$cfg")"
    local val="$(jq -r ".params[$i].value" <<<"$cfg")"
    local vars+=("$var")
    local vals+=("$val")
    local idx=$((i+1))
    [[ "$val" == "" ]] && val=_
    local parameters+="$var $idx 1 $val $idx 15 60 120 "
  done

  # dialog
  local DIALOG_OK=0
  local DIALOG_CANCEL=1
  local DIALOG_ERROR=254
  local DIALOG_ESC=255
  local res=0

  while test $res != 1 && test $res != 250; do
    local value
    value="$( dialog --ok-label "Start" \
                     --no-lines --backtitle "$backtitle" \
                     --form "Enter configuration for $ncp_app" \
                     20 70 0 $parameters \
               3>&1 1>&2 2>&3 )"
    res=$?
 
    case $res in
      $DIALOG_CANCEL)
        break
        ;;
      $DIALOG_OK)
        while read val; do local ret_vals+=("$val"); done <<<"$value"

        for (( i = 0 ; i < len ; i++ )); do
          # check for invalid characters
          grep -q '[\\&#;'"'"'`|*?~<>^"()[{}$&[:space:]]' <<< "${ret_vals[$i]}" && { echo "Invalid characters in field ${vars[$i]}"; return 1; }

          cfg="$(jq ".params[$i].value = \"${ret_vals[$i]}\"" <<<"$cfg")"
        done
        ret=0
        break
        ;;
      $DIALOG_ERROR)
        echo "ERROR!$value"
        break
        ;;
      $DIALOG_ESC)
        echo "ESC pressed."
        break
        ;;
      *)
        echo "Return code was $res"
        break
        ;;
    esac
  done

  echo "$cfg" > "$cfg_file"
  printf '\033[2J' && tput cup 0 0             # clear screen, don't clear scroll, cursor on top
  return $ret
}

function run_app()
{
  local ncp_app=$1
  local script="$(find "$BINDIR" -name $ncp_app.sh)"

  [[ -f "$script" ]] || { echo "file $script not found"; return 1; }

  run_app_unsafe "$script"
}

# receives a script file, no security checks
function run_app_unsafe()
{
  local script=$1
  local ncp_app="$(basename "$script" .sh)"
  local cfg_file="$CFGDIR/$ncp_app.cfg"
  local log=/var/log/ncp.log

  [[ -f "$script" ]] || { echo "file $script not found"; return 1; }

  touch               $log
  chmod 640           $log
  chown root:www-data $log

  echo "Running $ncp_app"
  echo "[ $ncp_app ]" >> $log

  # read script
  unset configure
  source "$script"

  # read cfg parameters
  [[ -f "$cfg_file" ]] && {
    local cfg="$( cat "$cfg_file" )"
    local len="$(jq '.params | length' <<<"$cfg")"
    for (( i = 0 ; i < len ; i++ )); do
      local var="$(jq -r ".params[$i].id"    <<<"$cfg")"
      local val="$(jq -r ".params[$i].value" <<<"$cfg")"
      eval "$var=$val"
    done
  }

  # run
  configure 2>&1 | tee -a $log
  local ret="${PIPESTATUS[0]}"

  echo "" >> $log

  return "$ret"
}

function is_active_app()
{
  local ncp_app=$1
  local bin_dir=${2:-.}
  local script="$bin_dir/$ncp_app.sh"
  local cfg_file="$CFGDIR/$ncp_app.cfg"

  [[ -f "$script" ]] || local script="$(find "$BINDIR" -name $ncp_app.sh)"
  [[ -f "$script" ]] || { echo "file $script not found"; return 1; }

  # function
  unset is_active
  source "$script"
  [[ $( type -t is_active ) == function ]] && { is_active; return $?; }

  # config
  [[ -f "$cfg_file" ]] || return 1

  local cfg="$( cat "$cfg_file" )"
  [[ "$(jq -r ".params[0].id"    <<<"$cfg")" == "ACTIVE" ]] && \
  [[ "$(jq -r ".params[0].value" <<<"$cfg")" == "yes"    ]] && \
  return 0
}

# show an info box for a script if the INFO variable is set in the script
function info_app()
{
  local ncp_app=$1
  local cfg_file="$CFGDIR/$ncp_app.cfg"

  local cfg="$( cat "$cfg_file" 2>/dev/null )"
  local info=$( jq -r .info <<<"$cfg" )
  local infotitle=$( jq -r .infotitle <<<"$cfg" )

  [[ "$info"      == "" ]] || [[ "$info"      == "null" ]] && return 0
  [[ "$infotitle" == "" ]] || [[ "$infotitle" == "null" ]] && infotitle="Info"

  whiptail --yesno \
	  --backtitle "NextCloudPi configuration" \
	  --title "$infotitle" \
	  --yes-button "I understand" \
	  --no-button "Go back" \
	  "$info" 20 90
}

function install_app()
{
  local ncp_app=$1

  # $1 can be either an installed app name or an app script
  if [[ -f "$ncp_app" ]]; then
    local script="$ncp_app"
    local ncp_app="$(basename "$script" .sh)"
  else
    local script="$(find "$BINDIR" -name $ncp_app.sh)"
  fi

  # do it
  unset install
  source "$script"
  echo "Installing $ncp_app"
  (install)
}

function cleanup_script()
{
  local script=$1
  unset cleanup
  source "$script"
  if [[ $( type -t cleanup ) == function ]]; then
    cleanup
    return $?
  fi
  return 0
}

function persistent_cfg()
{
  local SRC="$1"
  local DST="${2:-/data/etc/$( basename "$SRC" )}"
  test -e /changelog.md && return        # trick to disable in dev docker
  mkdir -p "$( dirname "$DST" )"
  test -e "$DST" || {
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

