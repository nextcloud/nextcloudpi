#!/bin/bash

# NextCloudPi function library
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at ownyourbits.com
#

export CFGDIR=/usr/local/etc/ncp-config.d
export BINDIR=/usr/local/bin/ncp
export NCDIR=/var/www/nextcloud
export ncc=/usr/local/bin/ncc
export NCPCFG=${NCPCFG:-etc/ncp.cfg}
export ARCH="$(dpkg --print-architecture)"
[[ "${ARCH}" =~ ^(armhf|arm)$ ]] && ARCH="armv7"
[[ "${ARCH}" == "arm64" ]] && ARCH=aarch64
[[ "${ARCH}" == "amd64" ]] && ARCH=x86_64
# Prevent systemd pager from blocking script execution
export SYSTEMD_PAGER=

[[ -f "$NCPCFG" ]] || export NCPCFG=/usr/local/etc/ncp.cfg
[[ -f "$NCPCFG" ]] || { echo "$NCPCFG not found" >2; exit 1; }

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

command -v jq &>/dev/null || {
  apt-get update
  apt-get install -y --no-install-recommends jq
}

NCLATESTVER=$(jq -r .nextcloud_version < "$NCPCFG")
PHPVER=$(     jq -r .php_version       < "$NCPCFG")
RELEASE=$(    jq -r .release           < "$NCPCFG")
# the default repo in bullseye is bullseye-security
grep -Eh '^deb ' /etc/apt/sources.list | grep "${RELEASE}-security" > /dev/null && RELEASE="${RELEASE}-security"
command -v ncc &>/dev/null && NCVER="$(ncc status 2>/dev/null | grep "version:" | awk '{ print $3 }')"

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
  local parameters=()
  for (( i = 0 ; i < len ; i++ )); do
    local var="$(jq -r ".params[$i].id"    <<<"$cfg")"
    local val="$(jq -r ".params[$i].value" <<<"$cfg")"
    local vars+=("$var")
    local vals+=("$val")
    local idx=$((i+1))
    parameters+=("$var" "$idx" 1 "$val" "$idx" 15 60 120)
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
                     20 70 0 "${parameters[@]}" \
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

function set-nc-domain()
{
  local domain="${1?}"
  domain="$(sed 's|http.\?://||;s|\(/.*\)||' <<<"${domain}")"
  if ! ping -c1 -w1 -q "${domain}" &>/dev/null; then
    unset domain
  fi
  if [[ "${domain}" == "" ]] || is_an_ip "${domain}"; then
    echo "warning: No domain found. Defaulting to '$(hostname)'"
    domain="$(hostname)"
  fi
  local proto
  proto="$(ncc config:system:get overwriteprotocol)" || true
  [[ "${proto}" == "" ]] && proto="https"
  local url="${proto}://${domain%*/}"
  [[ "$2" == "--no-trusted-domain" ]] || ncc config:system:set trusted_domains 3 --value="${domain%*/}"
  ncc config:system:set overwrite.cli.url --value="${url}/"
  if is_ncp_activated && is_app_enabled notify_push; then
    ncc config:system:set trusted_proxies 11 --value="127.0.0.1"
    ncc config:system:set trusted_proxies 12 --value="::1"
    ncc config:system:set trusted_proxies 13 --value="${domain}"
    ncc config:system:set trusted_proxies 14 --value="$(dig +short "${domain}")"
    sleep 5 # this seems to be required in the VM for some reason. We get `http2 error: protocol error` after ncp-upgrade-nc
    for try in {1..5}
    do
      echo "Setup notify_push (attempt ${try}/5)"
      ncc notify_push:setup "${url}/push" && break
      sleep 10
    done
  fi
}

function start_notify_push()
{
    pgrep notify_push &>/dev/null && return
    if [[ -f /.docker-image ]]; then
      NEXTCLOUD_URL=https://localhost sudo -E -u www-data "/var/www/nextcloud/apps/notify_push/bin/${ARCH}/notify_push" --allow-self-signed /var/www/nextcloud/config/config.php &>/dev/null &
    else
      systemctl enable --now notify_push
    fi
    sleep 5 # apparently we need to make sure we wait until the database is written or something
}

function run_app()
{
  local ncp_app=$1
  local script="$(find "$BINDIR" -name $ncp_app.sh | head -1)"

  [[ -f "$script" ]] || { echo "file $script not found"; return 1; }

  run_app_unsafe "$script"
}

function find_app_param_num()
{
  local script="${1?}"
  local param_id="${2?}"
  local ncp_app="$(basename "$script" .sh)"
  local cfg_file="$CFGDIR/$ncp_app.cfg"
  [[ -f "$cfg_file" ]] && {
    local cfg="$( cat "$cfg_file" )"
    local len="$(jq '.params | length' <<<"$cfg")"
    for (( i = 0 ; i < len ; i++ )); do
      local p_id="$(jq -r ".params[$i].id"    <<<"$cfg")"
      if [[ "${param_id}" == "${p_id}" ]]
      then
        echo "$i"
        return 0
      fi
    done
  }

  return 1

}

function get_app_params() {
  local script="${1?}"
  local cfg_file="${CFGDIR}/${script%.sh}.cfg"
  [[ -f "$cfg_file" ]] && {
    local cfg="$( cat "$cfg_file" )"
    local param_count="$(jq ".params | length" <<<"$cfg")"
    local i=0
    local json="{"
    while [[ $i -lt $param_count ]]
    do
      param_id="$(jq -r ".params[$i].id" <<<"$cfg")"
      param_val="$(jq -r ".params[$i].value" <<<"$cfg")"
      json="${json}"$'\n'"  \"${param_id}\": \"${param_val}\""
      i=$((i+1))
      [[ $i -lt $param_count ]] && json="${json},"
    done
    json="${json}"$'\n'"}"
    echo "$json"
    return 0
  }

  return 1
}

install_template() {
  local template="${1?}"
  local target="${2?}"
  local bkp="$(mktemp)"

  echo "Installing template '$template'..."

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
    echo "ERROR: Could not generate $target from template $template. Rolling back..."
    mv "$bkp" "$target"
    return 1
  }
  rm "$bkp"
}

find_app_param()
{
  local script="${1?}"
  local param_id="${2?}"
  local ncp_app="$(basename "$script" .sh)"
  local cfg_file="$CFGDIR/$ncp_app.cfg"

  local p_num="$(find_app_param_num "$script" "$param_id")" || return 1
  jq -r ".params[$p_num].value" < "$cfg_file"
}

set_app_param()
{
  local script="${1?}"
  local param_id="${2?}"
  local param_value="${3?}"
  local ncp_app="$(basename "$script" .sh)"
  local cfg_file="$CFGDIR/$ncp_app.cfg"

  grep -q '[\\&#;'"'"'`|*?~<>^"()[{}$&[:space:]]' <<< "${param_value}" && { echo "Invalid characters in field ${vars[$i]}"; return 1; }

  cfg="$(cat "$cfg_file")"

  local len="$(jq  '.params | length' <<<"$cfg")"
  local param_found=false

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
  echo "[ $ncp_app ] ($(date))" >> $log

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
  (configure) 2>&1 | tee -a $log
  local ret="${PIPESTATUS[0]}"

  echo "" >> $log

  [[ -f "$cfg_file" ]] && clear_password_fields "$cfg_file"
  return "$ret"
}

function is_active_app()
{
  local ncp_app=$1
  local bin_dir=${2:-.}
  local script="$bin_dir/$ncp_app.sh"
  local cfg_file="$CFGDIR/$ncp_app.cfg"

  [[ -f "$script" ]] || local script="$(find "$BINDIR" -name $ncp_app.sh | head -1)"
  [[ -f "$script" ]] || { echo "file $script not found"; return 1; }

  # function
  unset is_active
  source "$script"
  [[ $( type -t is_active ) == function ]] && {
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
    is_active
    return $?;
  }

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
    local script="$(find "$BINDIR" -name $ncp_app.sh | head -1)"
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

function install_with_shadow_workaround()
{
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

function is_more_recent_than()
{
  local version_A="$1"
  local version_B="$2"

  local major_a=$( cut -d. -f1 <<<"$version_A" )
  local minor_a=$( cut -d. -f2 <<<"$version_A" )
  local patch_a=$( cut -d. -f3 <<<"$version_A" )

  local major_b=$( cut -d. -f1 <<<"$version_B" )
  local minor_b=$( cut -d. -f2 <<<"$version_B" )
  local patch_b=$( cut -d. -f3 <<<"$version_B" )

  # Compare version A with version B
  # Return true if A is more recent than B

  if [ "$major_b" -gt "$major_a" ]; then
    return 1
  elif [ "$major_b" -eq "$major_a" ] && [ "$minor_b" -gt "$minor_a" ]; then
    return 1
  elif [ "$major_b" -eq "$major_a" ] && [ "$minor_b" -eq "$minor_a" ] && [ "$patch_b" -ge "$patch_a" ]; then
    return 1
  fi

  return 0
}

function is_app_enabled()
{
  local app="$1"
   ncc app:list | sed '0,/Disabled/!d' | grep -q "${app}"
}

function check_distro()
{
  local cfg="${1:-$NCPCFG}"
  local supported=$(jq -r .release "$cfg")
  grep -q "$supported" <(lsb_release -sc) && return 0
  return 1
}

function nc_version()
{
  ncc status | grep "version:" | awk '{ print $3 }'
}

function get_ip()
{
  local iface
  iface="$( ip r | grep "default via" | awk '{ print $5 }' | head -1 )"
  ip a show dev "$iface" | grep global | grep -oP '\d{1,3}(.\d{1,3}){3}' | head -1
}

function is_an_ip()
{
  local ip_or_domain="${1}"
  grep -oPq '\d{1,3}(.\d{1,3}){3}' <<<"${ip_or_domain}"
}

function is_ncp_activated()
{
  ! a2query -s ncp-activation -q
}

function clear_password_fields()
{
  local cfg_file="$1"
  local cfg="$(cat "$cfg_file")"
  local len="$(jq '.params | length' <<<"$cfg")"
  for (( i = 0 ; i < len ; i++ )); do
    local type="$(jq -r ".params[$i].type"  <<<"$cfg")"
    local val="$( jq -r ".params[$i].value" <<<"$cfg")"
    [[ "$type" == "password" ]] && val=""
    cfg="$(jq -r ".params[$i].value=\"$val\"" <<<"$cfg")"
  done
  echo "$cfg" > "$cfg_file"
}

function apt_install()
{
  apt-get update --allow-releaseinfo-change
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends -o Dpkg::Options::=--force-confdef -o Dpkg::Options::="--force-confold" "$@"
}

function is_docker() {
  [[ -f /.dockerenv ]] || [[ -f /.docker-image ]] || [[ "$DOCKERBUILD" == 1 ]]
}

function is_lxc() {
  grep -q container=lxc /proc/1/environ &>/dev/null
}

function notify_admin()
{
  local header="$1"
  local msg="$2"
  local admins=$(mysql -u root nextcloud -Nse "select uid from oc_group_user where gid='admin';")
  [[ "${admins}" == "" ]] && { echo "admin user not found" >&2; return 0; }
  while read -r admin
  do
    ncc notification:generate "${admin}" "${header}" -l "${msg}" || true
  done <<<"$admins"
}

function save_maintenance_mode()
{
  unset NCP_MAINTENANCE_MODE
  grep -q enabled <("${ncc}" maintenance:mode) && export NCP_MAINTENANCE_MODE="on" || true
  "${ncc}" maintenance:mode --on
}

function restore_maintenance_mode()
{
  if [[ "${NCP_MAINTENANCE_MODE:-}" != "" ]]; then
    "${ncc}" maintenance:mode --on
  else
    "${ncc}" maintenance:mode --off
  fi
}

function needs_decrypt()
{
  local active
  active="$(find_app_param nc-encrypt ACTIVE)"
  (! is_active_app nc-encrypt) && [[ "${active}" == "yes" ]]
}

function set_ncpcfg()
{
  local name="${1}"
  local value="${2}"
  local cfg
  cfg="$(jq '.' "${NCPCFG}")"
  cfg="$(jq ".${name} = \"${value}\"" <<<"${cfg}")"
  echo "$cfg" > "${NCPCFG}"
}

function get_ncpcfg()
{
  local name="${1}"
  jq -r ".${name}" < "${NCPCFG}"
}

function get_nc_config_value() {
  sudo -u www-data php -r "include(\"/var/www/nextcloud/config/config.php\"); echo(\$CONFIG[\"${1?Missing required argument: config key}\"]);"
  #ncc config:system:get "${1?Missing required argument: config key}"
}

function clear_opcache() {
  # shellcheck disable=SC2155
  local data_dir="$(get_nc_config_value datadirectory)"
  ! [[ -d "${data_dir:-/var/www/nextcloud/data}/.opcache" ]] || {
    echo "Clearing opcache..."
    echo "This can take some time. Please don't interrupt the process/close your browser tab."
    rm -rf "${data_dir:-/var/www/nextcloud/data}/.opcache"/* "${data_dir:-/var/www/nextcloud/data}/.opcache"/.[!.]*
    echo "Done."
  }
  service php${PHPVER}-fpm reload
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

