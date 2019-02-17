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
LOCK_FILE=/usr/local/etc/ncp.lock

function configure_app()
{
  local ncp_app="$1"
  local cfg_file="$CFGDIR/$ncp_app.cfg"
  local backtitle="NextCloudPi installer configuration"
  local ret=1

  # checks
  type dialog &>/dev/null || { echo "please, install dialog for interactive configuration"; return 1; }
  [[ -f "$cfg_file" ]]    || return 0;

  local cfg len
  cfg="$( cat "$cfg_file" )"
  len="$(jq  '.params | length' <<<"$cfg")"
  [[ $len -eq 0 ]] && return

  # read cfg parameters
  for (( i = 0 ; i < len ; i++ )); do
    local var val
    var="$(jq -r ".params[$i].id"    <<<"$cfg")"
    val="$(jq -r ".params[$i].value" <<<"$cfg")"
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
          grep -q '[\\&#;`|*?~<>^()[{}$&[:space:]]' <<< "${ret_vals[$i]}" && { echo "Invalid characters in field ${vars[$i]}"; return 1; }

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
  local script ncp_app
  ncp_app=$1
  script="$(find "$BINDIR" -name "$ncp_app.sh")"

  [[ -f "$script" ]] || { echo "file $script not found"; return 1; }

  run_app_unsafe "$script"
}

# receives a script file, no security checks
function run_app_unsafe()
{
  local script ncp_app
  script=$1
  ncp_app="$(basename "$script" .sh)"
  local cfg_file="$CFGDIR/$ncp_app.cfg"
  local log=/var/log/ncp/ncp.log

  [[ -f "$script" ]] || { echo "file $script not found"; return 1; }

  touch               $log
  chmod 640           $log
  chown root:www-data $log

  echo "Running $ncp_app"

  # Check if app is already running in tmux
  running_app=$( [[ -f "$LOCK_FILE" ]] && cat "$LOCK_FILE" || echo "" )
  [[ ! -z $running_app ]] && which tmux > /dev/null && tmux has-session -t="$running_app" > /dev/null 2>&1 && {
    #echo "Already running. Attaching to output..." | tee -a $log
    
    local choice
    [[ $ATTACH_TO_RUNNING == "1" ]] && choice="y"
    [[ $ATTACH_TO_RUNNING == "0" ]] && choice="n"
    question="An app ($running_app) is already running. Do you want to attach to it's output? <y/n>"
    if [[ $choice == "y" ]] || [[ $choice == "n" ]]
    then
      echo "$question"
      echo "Choice: <y>"
    else
      read -rp "$question" choice
      while [[ "$choice" != "y" ]] && [[ "$choice" != "n" ]]
      do
        echo "choice was '$choice'"
        read -rp "Invalid choice. y or n expected." choice
      done
    fi

    if [[ "$choice" == "y" ]]
    then
      attach_to_app "$running_app"
    fi
    return $?
  }

  unset configure
  (
    # read cfg parameters
    [[ -f "$cfg_file" ]] && {
      local len cfg
      cfg="$( cat "$cfg_file" )"
      jq -e '.tmux' <<<"$cfg" > /dev/null 2>&1
      use_tmux="$?"
      len="$(jq '.params | length' <<<"$cfg")"
      for (( i = 0 ; i < len ; i++ )); do
        local var val
        var="$(jq -r ".params[$i].id"    <<<"$cfg")"
        val="$(jq -r ".params[$i].value" <<<"$cfg")"
        eval "export $var=$val"
      done
    }
 
    echo "$ncp_app" > "$LOCK_FILE"
    if which tmux > /dev/null && [[ $use_tmux == 0 ]]
    then
      echo "Running $ncp_app in tmux..." | tee -a $log
      # Run app in tmux
      local tmux_log_file tmux_status_file LIBPATH
      tmux_log_file="/var/log/ncp/tmux.${ncp_app}.log"
      tmux_status_file="/var/log/ncp/tmux.${ncp_app}.status"
      LIBPATH="$(dirname $CFGDIR)/library.sh"
      
      # Reset tmux output
      echo "[ $ncp_app ]" | tee -a $log
      echo "[ $ncp_app ]" > "$tmux_log_file"
      echo "" > "$tmux_status_file"
      chmod 640           "$tmux_log_file" "$tmux_status_file"
      chown root:www-data "$tmux_log_file" "$tmux_status_file"

      tmux new-session -d -s "$ncp_app" "bash -c '(
        trap \"echo \\\$? > $tmux_status_file && rm $LOCK_FILE\" 1 2 3 4 6 9 11 15 19 29
        source \"$LIBPATH\"
        source \"$script\"
        configure 2>&1 | tee -a $log
        echo \"\${PIPESTATUS[0]}\" > $tmux_status_file
        rm $LOCK_FILE
      )' 2>&1 | tee -a $tmux_log_file"

      attach_to_app "$ncp_app"
      exit

    else
      trap "rm '$LOCK_FILE'" 0 1 2 3 4 6 11 15 19 29
      echo "[ $ncp_app ]" | tee -a $log
      echo "Running $ncp_app directly..." | tee -a $log
      # read script
      # shellcheck source=/dev/null
      source "$script"
      # run
      configure 2>&1 | tee -a $log
      local ret="${PIPESTATUS[0]}"
      exit "$ret"
    fi
  )
  ret="$?"
  echo "" >> $log

  return "$ret"
}

function attach_to_app()
{
  local tmux_log_file tmux_status_file
  tmux_log_file="/var/log/ncp/tmux.${ncp_app}.log"
  tmux_status_file="/var/log/ncp/tmux.${ncp_app}.status"

  if [[ "$ATTACH_NO_FOLLOW" == "1" ]]
  then
    cat "$tmux_log_file"
    return 0
  else
    (while tmux has-session -t="$ncp_app" > /dev/null 2>&1 
    do
      sleep 1
    done) &

    # Follow log file until tmux session has terminated
    tail --lines=+0 -f "$tmux_log_file" --pid="$!"
  fi

  # Read return value from tmux log file
  ret="$(tail -n 1 "$tmux_status_file")"
  #rm "$tmux_log_file"
  #rm "$tmux_status_file"

  [[ $ret =~ ^[0-9]+$ ]] && return $ret
  return 1
}

function is_active_app()
{
  local ncp_app=$1
  local bin_dir=${2:-.}
  local script="$bin_dir/$ncp_app.sh"
  local cfg_file="$CFGDIR/$ncp_app.cfg"

  [[ -f "$script" ]] || script="$(find "$BINDIR" -name $ncp_app.sh)"
  [[ -f "$script" ]] || { echo "file $script not found"; return 1; }

  # function
  unset is_active
  # shellcheck source=/dev/null
  source "$script"
  [[ $( type -t is_active ) == function ]] && { is_active; return $?; }

  # config
  [[ -f "$cfg_file" ]] || return 1

  local cfg
  cfg="$( cat "$cfg_file" )"
  [[ "$(jq -r ".params[0].id"    <<<"$cfg")" == "ACTIVE" ]] && \
  [[ "$(jq -r ".params[0].value" <<<"$cfg")" == "yes"    ]] && \
  return 0
}

# show an info box for a script if the INFO variable is set in the script
function info_app()
{
  local ncp_app=$1
  local cfg_file="$CFGDIR/$ncp_app.cfg"

  local cfg info infotitle
  cfg="$( cat "$cfg_file" 2>/dev/null )"
  info=$( jq -r .info <<<"$cfg" )
  infotitle=$( jq -r .infotitle <<<"$cfg" )

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
  local script
  local ncp_app=$1

  # $1 can be either an installed app name or an app script
  if [[ -f "$ncp_app" ]]; then
    script="$ncp_app"
    ncp_app="$(basename "$script" .sh)"
  else
    script="$(find "$BINDIR" -name $ncp_app.sh)"
  fi

  # do it
  unset install
  # shellcheck source=/dev/null
  source "$script"
  echo "Installing $ncp_app"
  (install)
}

function cleanup_script()
{
  local script=$1
  unset cleanup
  # shellcheck source=/dev/null
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

