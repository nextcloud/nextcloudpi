#!/usr/bin/env bash
declare -r FILE='./configs.json' TMPFILE="./tmp.json"
declare -i CFG_NR CONFIG_LENGTH
declare -f hasCMD getTotal getLength getIDs getID


# Config structure
# [
#   "description",
#   "id",
#   "info",
#   "infotitle",
#   "name",
#   "params",
#   "title"
# ]

# Params structure
# id
# name
# type
# value
# suggest
# default
# 
# [
#   "id",
#   "name",
#   "type",
#   "value"
# ]
# [
#   "default",
#   "id",
#   "name",
#   "suggest",
#   "value"
# ]
# 
# [
#   "id",
#   "name",
#   "suggest",
#   "value"
# ]
# [
#   "id",
#   "name",
#   "suggest",
#   "type",
#   "value"
# ]



# Checks if a command exists on the system
# Return status codes
# 0: Command exists on the system
# 1: Command is unavailable on the system
# 2: Missing command argument to check
hasCMD() {
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

if [[ -f "$FILE" ]] && hasCMD jq
then
  CONFIG_LENGTH="$(jq '.configs | length' "$FILE")"
  CFG_NR=$(( "$CONFIG_LENGTH" - 1 ))
else
  echo "Fatal: No config.json file found"
  exit 1
fi

function updateTotal() {
  if [[ -f "$FILE" ]] && hasCMD jq
  then
    CONFIG_LENGTH="$(jq '.configs | length' "$FILE")"
    CFG_NR=$(( "$LENGTH" - 1 ))
  fi
}

function getTotal() {
  echo "$CFG_NR"
}

function getLength() {
  echo "$CONFIG_LENGTH"
}

function getIDs() {
  if hasCMD jq
  then
    for i in $(seq 0 "$CFG_NR")
    do
      jq -r ".configs[$i].id" "$FILE"
    done
  fi
}

function getID() {
  if hasCMD jq
  then
    if [[ "$1" =~ [0-9*] ]]
    then
      jq -r ".configs[$1]" "$FILE"
    fi
  fi
}

function findIndexID() {
  local -r ID="$1"
  if hasCMD jq
  then
    local CHECK
    for i in $(seq 0 "$CFG_NR")
    do
      CHECK="$(jq -r ".configs[$i].id" "$FILE")"
      if [[ "$CHECK" == "$ID" ]]
      then
        printf 'ID: %s\nIndex: %s\n' "$ID" "$i"
      fi
    done
  fi
}

function configsNCP() {
  if hasCMD jq
  then
    jq -r '.ncp' "$FILE"
  fi
}

function versionNextcloud() {
  if hasCMD jq
  then
    jq -r '.ncp.nextcloud_version' "$FILE"
  fi
}

function versionNextcloudpi() {
  if hasCMD jq
  then
    jq -r '.ncp.version' "$FILE"
  fi
}

function versionPHP() {
  if hasCMD jq
  then
    jq -r '.ncp.php_version' "$FILE"
  fi
}

function versionOS() {
  if hasCMD jq
  then
    jq -r '.ncp.os_release' "$FILE"
  fi
}

function setVersionNCP() {
  local -r VERSION="$1"
  jq -r --arg v "$VERSION" '. as $in |
                             {
                               "ncp": {
                                 "version": $v,
                                 "nextcloud_version": $in.ncp.nextcloud_version,
                                 "php_version": $in.ncp.php_version,
                                 "os_release": $in.ncp.os_release
                                 },
                              "configs": $in.configs
                              }' "$FILE" > "$TMPFILE"
  mv "$TMPFILE" "$FILE"
}

function setVersionNextcloud() {
  local -r VERSION="$1"
  jq -r --arg v "$VERSION" '. as $in |
                             {
                               "ncp": {
                                 "version": $in.ncp.version,
                                 "nextcloud_version": $v,
                                 "php_version": $in.ncp.php_version,
                                 "os_release": $in.ncp.os_release
                                 },
                              "configs": $in.configs
                              }' "$FILE" > "$TMPFILE"
  mv "$TMPFILE" "$FILE"
}

function setVersionPHP() {
  local -r VERSION="$1"
  jq -r --arg v "$VERSION" '. as $in |
                             {
                               "ncp": {
                                 "version": $in.ncp.version,
                                 "nextcloud_version": $in.ncp.nextcloud_version,
                                 "php_version": $v,
                                 "os_release": $in.ncp.os_release
                                 },
                              "configs": $in.configs
                              }' "$FILE" > "$TMPFILE"
  mv "$TMPFILE" "$FILE"
}

function setVersionOS() {
  local -r VERSION="$1"
  jq -r --arg v "$VERSION" '. as $in |
                             {
                               "ncp": {
                                 "version": $in.ncp.version,
                                 "nextcloud_version": $in.ncp.nextcloud_version,
                                 "php_version": $in.ncp.php_version,
                                 "os_release": $v
                                 },
                              "configs": $in.configs
                              }' "$FILE" > "$TMPFILE"
  mv "$TMPFILE" "$FILE"
}

function updateVersion() {
  local -r FIELD="$1" VERSION="$2"
  if hasCMD jq
  then
    case "$FIELD" in
      'ncp') setVersionNCP "$VERSION" ;;
      'nextcloud') setVersionNextcloud "$VERSION" ;;
      'php') setVersionPHP "$VERSION" ;;
      'os') setVersionOS "$VERSION" ;;
    esac
  fi
}


# Params structure
# id
# name
# type
# value
# suggest
# default
function setParameters() {
  echo "TODO"
}

#getTotal
#getLength
#getID 12
#getIDs
#findIndexID 'nc-autoupdate-ncp'
configsNCP
versionNextcloudpi
versionNextcloud
versionPHP
versionOS
updateVersion 'ncp' '2.0.0'
versionNextcloudpi
updateVersion 'nextcloud' '25.0.2'
versionNextcloud
updateVersion 'php' '8.1'
versionPHP
updateVersion 'os' 'bullseye'
versionOS
