#!/bin/bash

# NextloudPi function library
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at ownyourbits.com
#

# A log function that uses log levels for logging different outputs
# Log levels
# -2: Debug
# -1: Info
#  0: Success
#  1: Warning
#  2: Error
function log() {
  if [[ "$#" -gt 0 ]]
  then
    local -r LOGLEVEL="$1" TEXT="${*:2}" Z='\e[0m'
    if [[ "$LOGLEVEL" =~ [(-2)-2] ]]
    then
      case "$LOGLEVEL" in
        -2)
          local -r CYAN='\e[1;36m'
          printf "${CYAN}DEBUG${Z}: %s\n" "$TEXT"
          ;;
        -1)
          local -r BLUE='\e[1;34m'
          printf "${BLUE}INFO${Z}: %s\n" "$TEXT"
          ;;
        0)
          local -r GREEN='\e[1;32m'
          printf "${GREEN}SUCCESS${Z}: %s\n" "$TEXT"
          ;;
        1)
          local -r YELLOW='\e[1;33m'
          printf "${YELLOW}WARNING${Z}: %s\n" "$TEXT"
          ;;
        2)
          local -r RED='\e[1;31m'
          printf "${RED}ERROR${Z}: %s\n" "$TEXT"
          ;;
      esac
    else
      log 2 "Invalid log level: [Debug: -2|Info: -1|Success: 0|Warning: 1|Error: 2]"
    fi
  fi
}

# Tests for nc-config.d directory before export and exits with code 1 if not found
if [[ -d '/usr/local/etc/ncp-config.d' ]]
then
  export CFGDIR='/usr/local/etc/ncp-config.d'
else
  log 2 "Directory not found: ncp-config.d"
  exit 1
fi
# Tests for ncp directory before export and exits with code 1 if not found
if [[ -d '/usr/local/bin/ncp' ]]
then
  export BINDIR='/usr/local/bin/ncp'
else
  log 2 "Directory not found: ncp"
  exit 1
fi
# Tests for nextcloud directory before export and exits with code 1 if not found
if [[ -d '/var/www/nextcloud' ]]
then
  export NCDIR='/var/www/nextcloud'
else
  log 2 "Directory not found: nextcloud"
  exit 1
fi
# Tests for ncc script file before export and exits with code 1 if not found 
if [[ -f '/usr/local/bin/ncc' ]]
then
  export ncc='/usr/local/bin/ncc'
else
  log 2 "File not found: ncc"
  exit 1
fi
# Tests for ncp.cfg file before export and exits with code 1 if not found
if [[ -f 'etc/ncp.cfg' ]]
then
  export NCPCFG='etc/ncp.cfg'
elif [[ -f '/usr/local/etc/ncp.cfg' ]]
then
  export NCPCFG='/usr/local/etc/ncp.cfg'
else
  log 2 "File not found: ncp.cfg"
  exit 1
fi

ARCH="$(dpkg --print-architecture)"
export ARCH
[[ "$ARCH" =~ ^(armhf|arm)$ ]] && ARCH='armv7'
[[ "$ARCH" == "arm64" ]] && ARCH='aarch64'
[[ "$ARCH" == "amd64" ]] && ARCH='x86_64'

# Prevent systemd pager from blocking script execution
export SYSTEMD_PAGER=

if [[ "$(ps -p 1 --no-headers -o "%c")" == "systemd" ]] && ! [[ -d "/run/systemd/system" ]]
then
  INIT_SYSTEM="chroot"
elif [[ -d "/run/systemd/system" ]]
then
  INIT_SYSTEM="systemd"
elif [[ "$(ps -p 1 --no-headers -o "%c")" == "run-parts.sh" ]]
then
  INIT_SYSTEM="docker"
else
  INIT_SYSTEM="unknown"
fi

export INIT_SYSTEM

#unset TRUSTED_DOMAINS
#declare -A TRUSTED_DOMAINS
#export TRUSTED_DOMAINS=(
  #[ip]=1 [dnsmasq]=2 [nc_domain]=3 [nextcloudpi-local]=5 [docker_overwrite]=6
  #[nextcloudpi]=7 [nextcloudpi-lan]=8 [public_ip]=11 [letsencrypt_1]=12
  #[letsencrypt_2]=13 [hostname]=14 [trusted_domain_1]=20 [trusted_domain_2]=21 [trusted_domain_3]=22
#)

# Checks if jq command is not available & installs it using function for package(s) install
if ! hasCMD jq
then
  installPKG jq
fi

NCLATESTVER=$(jq -r '.nextcloud_version' < "$NCPCFG")
PHPVER=$(     jq -r '.php_version'       < "$NCPCFG")
RELEASE=$(    jq -r '.release'           < "$NCPCFG")
export NCLATESTVER PHPVER RELEASE
# the default repo in bullseye is bullseye-security
grep -Eh '^deb ' /etc/apt/sources.list | grep "${RELEASE}-security" > /dev/null && RELEASE="${RELEASE}-security"

# Checks if the ncc command is available
if hasCMD ncc
then
  NCVER="$(ncc status 2>/dev/null | grep "version:" | awk '{ print $3 }')"
  export NCVER
fi

function configure_app() {
  local ncp_app="$1" backtitle="NextcloudPi installer configuration" \
  ret=1 var val vars vals idx cfg len
  local cfg_file="${CFGDIR}/${ncp_app}.cfg"
  # Checks for dialog and installs it if not available
  type dialog &>/dev/null || installPKG dialog
  [[ -f "$cfg_file" ]]    || return 0;
  
  cfg="$( cat "$cfg_file" )"
  len="$(jq  '.params | length' <<<"$cfg")"
  [[ "$len" -eq 0 ]] && return

  # read cfg parameters
  local parameters=()
  for (( i = 0 ; i < len ; i++ ))
  do
    var="$(jq -r ".params[$i].id"    <<<"$cfg")"
    val="$(jq -r ".params[$i].value" <<<"$cfg")"
    vars+=("$var")
    vals+=("$val")
    idx=$((i+1))
    parameters+=("$var" "$idx" 1 "$val" "$idx" 15 60 120)
  done

  # Dialog selection options
  local DIALOG_OK=0 DIALOG_CANCEL=1 DIALOG_ERROR=254 DIALOG_ESC=255
  local res=0 value ret_vals

  while [[ "$res" != 1 && "$res" != 250 ]]
  do
    value="$( dialog --ok-label "Start" \
                     --no-lines --backtitle "$backtitle" \
                     --form "Enter configuration for $ncp_app" \
                     20 70 0 "${parameters[@]}" \
               3>&1 1>&2 2>&3 )"
    res="$?"

    case "$res" in
      "$DIALOG_CANCEL")
        break
        ;;
      "$DIALOG_OK")
        while read -r val; do ret_vals+=("$val"); done <<<"$value"

        for (( i = 0 ; i < len ; i++ )); do
          # check for invalid characters
          grep -q '[\\&#;'"'"'`|*?~<>^"()[{}$&[:space:]]' <<< "${ret_vals[$i]}" && { log 2 "Invalid characters in field ${vars[$i]}"; return 1; }

          cfg="$(jq ".params[$i].value = \"${ret_vals[$i]}\"" <<<"$cfg")"
        done
        ret=0
        break
        ;;
      "$DIALOG_ERROR")
        log 2 "$value"
        break
        ;;
      "$DIALOG_ESC")
        log -1 "ESC was pressed."
        break
        ;;
      *)
        log -1 "Return code was $res"
        break
        ;;
    esac
  done

  echo "$cfg" > "$cfg_file"
  printf '\033[2J' && tput cup 0 0             # clear screen, don't clear scroll, cursor on top
  return "$ret"
}

function set-nc-domain() {
  local domain="${1?}"
  domain="$(sed 's|http.\?://||;s|\(/.*\)||' <<<"$domain")"
  if ! ping -c1 -w1 -q "$domain" &>/dev/null
  then
    unset domain
  fi
  if [[ "$domain" == "" ]] || is_an_ip "$domain"
  then
    # Warning
    log 1 "No domain found. Defaulting to '$(hostname)'"
    domain="$(hostname)"
  fi
  local proto
  proto="$(ncc config:system:get overwriteprotocol)" || true
  [[ "${proto}" == "" ]] && proto="https"
  local url="${proto}://${domain%*/}"
  [[ "$2" == "--no-trusted-domain" ]] || ncc config:system:set trusted_domains 3 --value="${domain%*/}"
  ncc config:system:set overwrite.cli.url --value="${url}/"
  if is_ncp_activated && is_app_enabled notify_push
  then
    ncc config:system:set trusted_proxies 11 --value="127.0.0.1"
    ncc config:system:set trusted_proxies 12 --value="::1"
    ncc config:system:set trusted_proxies 13 --value="$domain"
    ncc config:system:set trusted_proxies 14 --value="$(dig +short "$domain")"
    sleep 5 # this seems to be required in the VM for some reason. We get `http2 error: protocol error` after ncp-upgrade-nc
    for try in {1..3}
    do
      echo "Setup notify_push (attempt ${try}/3)"
      ncc notify_push:setup "${url}/push"
      sleep 5
    done
  fi
}

function start_notify_push() {
    pgrep notify_push &>/dev/null && return
    if [[ -f /.docker-image ]]; then
      NEXTCLOUD_URL=https://localhost sudo -E -u www-data "/var/www/nextcloud/apps/notify_push/bin/${ARCH}/notify_push" --allow-self-signed /var/www/nextcloud/config/config.php &>/dev/null &
    else
      systemctl enable --now notify_push
    fi
    sleep 5 # apparently we need to make sure we wait until the database is written or something
}

function run_app() {
  local ncp_app="$1" script
  script="$(find "$BINDIR" -name "$ncp_app".sh | head -1)"
  [[ -f "$script" ]] || { log 2 "File not found: $script"; return 1; }
  run_app_unsafe "$script"
}

function find_app_param_num() {
  local script="${1?}" param_id="${2?}" ncp_app cfg len p_id
  ncp_app="$(basename "$script" .sh)"
  local cfg_file="${CFGDIR}/${ncp_app}.cfg"
  if [[ -f "$cfg_file" ]]
  then
    cfg="$( cat "$cfg_file" )"
    len="$(jq '.params | length' <<<"$cfg")"
    for (( i = 0 ; i < len ; i++ ))
    do
      p_id="$(jq -r ".params[$i].id"    <<<"$cfg")"
      if [[ "$param_id" == "$p_id" ]]
      then
        echo "$i"
        return 0
      fi
    done
  else
    return 1
  fi
}

function install_template() {
  local template="${1?}" target="${2?}" bkp
  bkp="$(mktemp)"
  mkdir -p "$(dirname "$target")"
  [[ -f "$target" ]] && cp -a "$target" "$bkp"
  {
    if [[ "${3:-}" == "--defaults" ]]; then
      { bash "/usr/local/etc/ncp-templates/$template" --defaults > "$target"; } 2>&1
    else
      { bash "/usr/local/etc/ncp-templates/$template" > "$target"; } 2>&1 || \
        if [[ "${3:-}" == "--allow-fallback" ]]; then
          { bash "/usr/local/etc/ncp-templates/$template" --defaults > "$target"; } 2>&1
        fi
    fi
  } || {
    log 2 "Could not generate $target from template $template. Rolling back..."
    mv "$bkp" "$target"
    return 1
  }
  rm "$bkp"
}

function find_app_param() {
  local script="${1?}" param_id="${2?}" ncp_app p_num
  ncp_app="$(basename "$script" .sh)"
  local cfg_file="${CFGDIR}/${ncp_app}.cfg"

  p_num="$(find_app_param_num "$script" "$param_id")" || return 1
  jq -r ".params[$p_num].value" < "$cfg_file"
}

set_app_param()
{
  local script="${1?}" param_id="${2?}" param_value="${3?}" ncp_app len param_found
  ncp_app="$(basename "$script" .sh)"
  local cfg_file="${CFGDIR}/${ncp_app}.cfg"

  grep -q '[\\&#;'"'"'`|*?~<>^"()[{}$&[:space:]]' <<< "${param_value}" && { log 2 "Invalid characters in field ${vars[$i]}"; return 1; }

  cfg="$(cat "$cfg_file")"

  len="$(jq  '.params | length' <<<"$cfg")"
  param_found=false

  for (( i = 0 ; i < len ; i++ )); do
    # check for invalid characters
    [[ "$(jq -r ".params[$i].id" <<<"$cfg")" == "$param_id" ]] && {
      cfg="$(jq ".params[$i].value = \"${param_value}\"" <<<"$cfg")"
      param_found=true
    }

  done

  [[ "$param_found" == "true" ]] || {
    echo "Did not find parameter '${param_id}' in configuration of app '$(basename "$script" .sh)'"
    return 1
  }

  echo "$cfg" > "$cfg_file"

}

# receives a script file, no security checks
function run_app_unsafe() {
  local script="$1" ncp_app cfg_file
  ncp_app="$(basename "$script" .sh)"
  cfg_file="${CFGDIR}/${ncp_app}.cfg"
  local log='/var/log/ncp.log'

  [[ -f "$script" ]] || { log 2 "File not found: $script"; return 1; }

  touch               "$log"
  chmod 640           "$log"
  chown root:www-data "$log"

  log -1 "Running $ncp_app"
  echo "[ $ncp_app ] ($(date))" >> "$log"

  # read script
  unset configure
  # shellcheck disable=SC1090
  source "$script"

  # read cfg parameters
  [[ -f "$cfg_file" ]] && {
    local cfg len var val
    cfg="$( cat "$cfg_file" )"
    len="$(jq '.params | length' <<<"$cfg")"
    for (( i = 0 ; i < len ; i++ )); do
      var="$(jq -r ".params[$i].id"    <<<"$cfg")"
      val="$(jq -r ".params[$i].value" <<<"$cfg")"
      eval "$var=$val"
    done
  }

  # run
  (configure) 2>&1 | tee -a "$log"
  local ret="${PIPESTATUS[0]}"

  echo "" >> "$log"

  [[ -f "$cfg_file" ]] && clear_password_fields "$cfg_file"
  return "$ret"
}

function is_active_app() {
  local ncp_app="$1" bin_dir="${2:-.}" cfg
  local script="${bin_dir}/${ncp_app}.sh"
  local cfg_file="${CFGDIR}/${ncp_app}.cfg"

  [[ -f "$script" ]] || script="$(find "$BINDIR" -name "$ncp_app".sh | head -1)"
  [[ -f "$script" ]] || { log 2 "File not found: $script"; return 1; }

  # function
  unset is_active
  # shellcheck disable=SC1090
  source "$script"
  [[ "$( type -t is_active )" == function ]] && {
    # read cfg parameters
    [[ -f "$cfg_file" ]] && {
      local cfg len var val
      cfg="$( cat "$cfg_file" )"
      len="$(jq '.params | length' <<<"$cfg")"
      for (( i = 0 ; i < len ; i++ )); do
        var="$(jq -r ".params[$i].id"    <<<"$cfg")"
        val="$(jq -r ".params[$i].value" <<<"$cfg")"
        eval "$var=$val"
      done
    }
    is_active
    return "$?";
  }

  # config
  [[ -f "$cfg_file" ]] || return 1
  cfg="$( cat "$cfg_file" )"
  [[ "$(jq -r ".params[0].id"    <<<"$cfg")" == "ACTIVE" ]] && \
  [[ "$(jq -r ".params[0].value" <<<"$cfg")" == "yes"    ]] && \
  return 0
}

# show an info box for a script if the INFO variable is set in the script
function info_app() {
  local ncp_app="$1" cfg info infotitle
  local cfg_file="${CFGDIR}/${ncp_app}.cfg"

  cfg="$( cat "$cfg_file" 2>/dev/null )"
  info="$( jq -r '.info' <<<"$cfg" )"
  infotitle="$( jq -r '.infotitle' <<<"$cfg" )"

  [[ "$info"      == "" ]] || [[ "$info"      == "null" ]] && return 0
  [[ "$infotitle" == "" ]] || [[ "$infotitle" == "null" ]] && infotitle="Info"

  whiptail --yesno \
	  --backtitle "NextcloudPi configuration" \
	  --title "$infotitle" \
	  --yes-button "I understand" \
	  --no-button "Go back" \
	  "$info" 20 90
}

function install_app() {
  local ncp_app="$1" script script

  # $1 can be either an installed app name or an app script
  if [[ -f "$ncp_app" ]]; then
    script="$ncp_app"
    ncp_app="$(basename "$script" .sh)"
  else
    script="$(find "$BINDIR" -name "$ncp_app".sh | head -1)"
  fi

  # do it
  unset install
  # shellcheck disable=SC1090
  source "$script"
  log -1 "Installing $ncp_app"
  (install)
}

function cleanup_script() {
  local script="$1"
  unset cleanup
  # shellcheck disable=SC1090
  source "$script"
  if [[ "$( type -t cleanup )" == function ]]; then
    cleanup
    return "$?"
  fi
  return 0
}

function persistent_cfg() {
  local SRC="$1" DST="${2:-/data/etc/$( basename "$SRC" )}"
  [[ -e /changelog.md ]] && return        # trick to disable in dev docker
  mkdir -p "$( dirname "$DST" )"
  [[ -e "$DST" ]] || {
    log -1 "Making $SRC persistent ..."
    mv    "$SRC" "$DST"
  }
  rm -rf "$SRC"
  ln -s "$DST" "$SRC"
}

function install_with_shadow_workaround() {
  # Subshell to trap trap :P
  (
    restore_shadow=true
    [[ -L /etc/shadow ]] || restore_shadow=false
    [[ "$restore_shadow" == "false" ]] || {
      trap "mv /etc/shadow /data/etc/shadow; ln -s /data/etc/shadow /etc/shadow" EXIT
      rm /etc/shadow
      cp /data/etc/shadow /etc/shadow
    }
    DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"
    [[ "$restore_shadow" == "false" ]] || {
      mv /etc/shadow /data/etc/shadow
      ln -s /data/etc/shadow /etc/shadow
    }
    trap - EXIT
  )
}

function is_more_recent_than() {
  local version_A="$1" version_B="$2" \
        major_a minor_a patch_a major_b minor_b patch_b

  major_a=$( cut -d. -f1 <<<"$version_A" )
  minor_a=$( cut -d. -f2 <<<"$version_A" )
  patch_a=$( cut -d. -f3 <<<"$version_A" )

  major_b=$( cut -d. -f1 <<<"$version_B" )
  minor_b=$( cut -d. -f2 <<<"$version_B" )
  patch_b=$( cut -d. -f3 <<<"$version_B" )

  # Compare version A with version B
  # Return true if A is more recent than B
  if [ "$major_b" -gt "$major_a" ]; then
    return 1
  elif [ "$major_b" -eq "$major_a" ] \
    && [ "$minor_b" -gt "$minor_a" ]; then
    return 1
  elif [ "$major_b" -eq "$major_a" ] \
    && [ "$minor_b" -eq "$minor_a" ] \
    && [ "$patch_b" -ge "$patch_a" ]; then
    return 1
  fi
  return 0
}

function is_app_enabled() {
  local app="$1"
   ncc app:list | sed '0,/Disabled/!d' | grep -q "$app"
}

function check_distro() {
  local cfg="${1:-$NCPCFG}" supported
  supported=$(jq -r '.release' "$cfg")
  grep -q "$supported" <(lsb_release -sc) && return 0
  return 1
}

function nc_version() {
  ncc status | grep "version:" | awk '{ print $3 }'
}

function get_ip() {
  local iface
  iface="$( ip r | grep "default via" | awk '{ print $5 }' | head -1 )"
  ip a show dev "$iface" | grep global | grep -oP '\d{1,3}(.\d{1,3}){3}' | head -1
}

function is_an_ip() {
  local ip_or_domain="$1"
  grep -oPq '\d{1,3}(.\d{1,3}){3}' <<<"$ip_or_domain"
}

function is_ncp_activated() {
  ! a2query -s ncp-activation -q
}

function clear_password_fields() {
  local cfg_file="$1" cfg len type val
  cfg="$(cat "$cfg_file")"
  len="$(jq '.params | length' <<<"$cfg")"
  for (( i = 0 ; i < len ; i++ )); do
    type="$(jq -r ".params[$i].type"  <<<"$cfg")"
    val="$( jq -r ".params[$i].value" <<<"$cfg")"
    [[ "$type" == "password" ]] && val=""
    cfg="$(jq -r ".params[$i].value=\"$val\"" <<<"$cfg")"
  done
  echo "$cfg" > "$cfg_file"
}

# Checks if a command exists on the system
# Return status codes
# 0: Command exists on the system
# 1: Command is unavailable on the system
# 2: Missing command argument to check
function hasCMD() {
  if [[ "$#" -eq 1 ]]
  then
    local -r CHECK="$1"
    if command -v "$CHECK" &>/dev/null
    then
      return 0
    else
      return 1
    fi
  else
    return 2
  fi
}

# Checks if a package exists on the system
# Return status codes
# 0: Package is installed
# 1: Package is not installed but is available in apt
# 2: Package is not installed and is not available in apt
# 3: Missing package argument to check
function hasPKG() {
  if [[ "$#" -eq 1 ]]
  then
    local -r CHECK="$1"
    if dpkg-query --status "$CHECK" &>/dev/null
    then
      return 0
    elif apt-cache show "$CHECK" &>/dev/null
    then
      return 1
    else
      return 2
    fi
  else
    return 3
  fi
}

function apt_install() {
  apt-get update --allow-releaseinfo-change
  DEBIAN_FRONTEND=noninteractive apt-get install --assume-yes --no-install-recommends --option Dpkg::Options::='--force-confdef' --option Dpkg::Options::='--force-confold' "$@"
}

# Installs package(s) using the package manager and pre-configured options
# Return codes
# 1: Missing package argument
# 0: Install completed
installPKG() {
  if [[ ! "$#" -eq 1 ]]
  then
    log 2 "Requires 1 argument: [PKG(s) to install]"
    return 1
  else
    local -r PKG="$1" OPTIONS='--quiet --assume-yes --no-show-upgraded --auto-remove=true --no-install-recommends'
    local -r SUDOUPDATE="sudo apt-get $OPTIONS update" \
             SUDOINSTALL="sudo apt-get $OPTIONS install" \
             ROOTUPDATE="apt-get $OPTIONS update" \
             ROOTINSTALL="apt-get $OPTIONS install"
    if [[ ! "$EUID" -eq 0 ]]
    then
      # Do not double-quote $SUDOUPDATE
      $SUDOUPDATE &>/dev/null
      log -1 "Installing $PKG"
      # Do not double-quote $SUDOINSTALL or $PKG
      DEBIAN_FRONTEND=noninteractive $SUDOINSTALL $PKG
      log 0 "Completed"
      return 0
    else
      # Do not double-quote $ROOTUPDATE
      $ROOTUPDATE &>/dev/null
      log -1 "Installing $PKG"
      # Do not double-quote $ROOTINSTALL or $PKG
      DEBIAN_FRONTEND=noninteractive $ROOTINSTALL $PKG
      log 0 "Completed"
      return 0
    fi
  fi
}

function is_docker() {
  [[ -f /.dockerenv ]] || [[ -f /.docker-image ]] || [[ "$DOCKERBUILD" == 1 ]]
}

function is_lxc() {
  grep -q container=lxc /proc/1/environ &>/dev/null
}

function notify_admin() {
  local header="$1" msg="$2" admin
  admin=$(mysql -u root nextcloud -Nse "select uid from oc_group_user where gid='admin' limit 1;")
  [[ "$admin" == "" ]] && { echo "admin user not found" >&2; return 0; }
  ncc notification:generate "$admin" "$header" -l "$msg" || true
}

function save_maintenance_mode() {
  unset NCP_MAINTENANCE_MODE
  if grep -q enabled <("$ncc" maintenance:mode)
  then
    export NCP_MAINTENANCE_MODE="on"
  else
    true
  fi
  "$ncc" maintenance:mode --on
}

function restore_maintenance_mode() {
  if [[ "${NCP_MAINTENANCE_MODE:-}" != "" ]]; then
    "$ncc" maintenance:mode --on
  else
    "$ncc" maintenance:mode --off
  fi
}

function needs_decrypt() {
  local active
  active="$(find_app_param nc-encrypt ACTIVE)"
  (! is_active_app nc-encrypt) && [[ "$active" == "yes" ]]
}

function set_ncpcfg() {
  local name="$1" value="$2" cfg
  cfg="$(jq '.' "$NCPCFG")"
  cfg="$(jq ".$name = \"$value\"" <<<"$cfg")"
  echo "$cfg" > "$NCPCFG"
}

function get_ncpcfg() {
  local name="$1"
  jq -r ".$name" < "$NCPCFG"
}

function get_nc_config_value() {
  sudo -u www-data php -r "include(\"/var/www/nextcloud/config/config.php\"); echo(\$CONFIG[\"${1?Missing required argument: config key}\"]);"
  #ncc config:system:get "${1?Missing required argument: config key}"
}

function clear_opcache() {
  local data_dir
  data_dir="$(get_nc_config_value datadirectory)"
  ! [[ -d "${data_dir:-/var/www/data}/.opcache" ]] || {
    echo "Clearing opcache..."
    echo "This can take some time. Please don't interrupt the process/close your browser tab."
    rm -rf "${data_dir:-/var/www/data}/.opcache"/*
    echo "Done."
  }
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
