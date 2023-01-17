#!/usr/bin/env bash
# Victor-ray, S <12261439+ZendaiOwl@users.noreply.github.com>

declare -r CONFIGS_JSON_FILE='configs.json' NCP_CONFIGS_FILE='JSONData/ncp.json' CONFIGURATIONS='JSONData/Configurations'
declare -i CONFIGS_NUMBER CONFIGS_LENGTH

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

# Runs when sourced or executed to set the CONFIGS_LENGTH & CONFIGS_NUMBER variables
if [[ -f "$CONFIGS_JSON_FILE" ]] && hasCMD jq
then
  CONFIGS_LENGTH="$(jq '.configs | length' "$CONFIGS_JSON_FILE")"
  CONFIGS_NUMBER=$(( "$CONFIGS_LENGTH" - 1 ))
else
  echo "Fatal: No config.json file found"
  exit 1
fi

# Unsets the CONFIGS_LENGTH & CONFIGS_NUMBER variables
function cleanupVariables() {
  unset CONFIGS_NUMBER CONFIGS_LENGTH
}

# Sets or updates the CONFIGS_LENGTH & CONFIGS_NUMBER variables
function updateVariables() {
  if [[ -f "$CONFIGS_JSON_FILE" ]] && hasCMD jq
  then
    CONFIGS_LENGTH="$(jq '.configs | length' "$CONFIGS_JSON_FILE")"
    CONFIGS_NUMBER=$(( "$CONFIGS_LENGTH" - 1 ))
  fi
}

# Gets the index number of total app configurations
function getTotal() {
  echo "$CONFIGS_NUMBER"
}

# Gets the total number of app configurations
function getLength() {
  echo "$CONFIGS_LENGTH"
}

# Gets the ID for all app configurations 
function getIDs() {
  if hasCMD jq
  then
    for i in $(seq 0 "$CONFIGS_NUMBER")
    do
      jq -r ".configs[$i].id" "$CONFIGS_JSON_FILE"
    done
  fi
}

# Gets app configuration by ID
function getConfigByID() {
  if hasCMD jq
  then
    if [[ "$1" =~ [0-9*] ]]
    then
      jq -r ".configs[$1]" "$CONFIGS_JSON_FILE"
    fi
  fi
}

# Finds the index number for an app configuration
function findIndexID() {
  local -r ID="$1"
  if hasCMD jq
  then
    local CHECK
    for i in $(seq 0 "$CFG_NR")
    do
      CHECK="$(jq -r ".configs[$i].id" "$CONFIGS_JSON_FILE")"
      if [[ "$CHECK" == "$ID" ]]
      then
        printf 'ID: %s\nIndex: %s\n' "$ID" "$i"
      fi
    done
  fi
}

# Gets nextcloudpi configuration values
function ncpConfigs() {
  if hasCMD jq
  then
    jq -r '.ncp' "$CONFIGS_JSON_FILE"
  fi
}

# Sets the os_release field in the ncp key 
function setVersionNCP() {
  local -r VERSION="$1" CONFIGS_TEMP_FILE="./tmp.json"
  jq -r --arg v "$VERSION" '. as $in |
                             {
                               "ncp": {
                                 "version": $v,
                                 "nextcloud_version": $in.ncp.nextcloud_version,
                                 "php_version": $in.ncp.php_version,
                                 "os_release": $in.ncp.os_release
                                 },
                              "configs": $in.configs
                              }' "$CONFIGS_JSON_FILE" > "$CONFIGS_TEMP_FILE"
  mv "$CONFIGS_TEMP_FILE" "$CONFIGS_JSON_FILE"
}

# Sets the nextcloud_version field in the ncp key 
function setVersionNextcloud() {
  local -r VERSION="$1" CONFIGS_TEMP_FILE="./tmp.json"
  jq -r --arg v "$VERSION" '. as $in |
                             {
                               "ncp": {
                                 "version": $in.ncp.version,
                                 "nextcloud_version": $v,
                                 "php_version": $in.ncp.php_version,
                                 "os_release": $in.ncp.os_release
                                 },
                              "configs": $in.configs
                              }' "$CONFIGS_JSON_FILE" > "$CONFIGS_TEMP_FILE"
  mv "$CONFIGS_TEMP_FILE" "$CONFIGS_JSON_FILE"
}

# Sets the php_version field in the ncp key 
function setVersionPHP() {
  local -r VERSION="$1" CONFIGS_TEMP_FILE="./tmp.json"
  jq -r --arg v "$VERSION" '. as $in |
                             {
                               "ncp": {
                                 "version": $in.ncp.version,
                                 "nextcloud_version": $in.ncp.nextcloud_version,
                                 "php_version": $v,
                                 "os_release": $in.ncp.os_release
                                 },
                              "configs": $in.configs
                              }' "$CONFIGS_JSON_FILE" > "$CONFIGS_TEMP_FILE"
  mv "$CONFIGS_TEMP_FILE" "$CONFIGS_JSON_FILE"
}

# Sets the os_release field in the ncp key 
function setVersionOS() {
  local -r VERSION="$1" CONFIGS_TEMP_FILE="./tmp.json"
  jq -r --arg v "$VERSION" '. as $in |
                             {
                               "ncp": {
                                 "version": $in.ncp.version,
                                 "nextcloud_version": $in.ncp.nextcloud_version,
                                 "php_version": $in.ncp.php_version,
                                 "os_release": $v
                                 },
                              "configs": $in.configs
                              }' "$CONFIGS_JSON_FILE" > "$CONFIGS_TEMP_FILE"
  mv "$CONFIGS_TEMP_FILE" "$CONFIGS_JSON_FILE"
}

# Sets the version fields in the ncp key 
function setVersion() {
  local -r FIELD="$1" VERSION="$2"
  if hasCMD jq
  then
    case "$FIELD" in
      'ncp'|'nextcloudpi'|'version')        setVersionNCP       "$VERSION" ;;
      'nc'|'nextcloud'|'nextcloud_version') setVersionNextcloud "$VERSION" ;;
      'php'|'php_version')                  setVersionPHP       "$VERSION" ;;
      'os'|'release'|'os_release')          setVersionOS        "$VERSION" ;;
    esac
  fi
}

# Gets the specified version field of the ncp key
function getVersion() {
  if hasCMD jq
  then
    local -r FIELD="$1"
    case "$FIELD" in
      'ncp'|'nextcloudpi'|'version')        jq -r '.ncp.version'           "$CONFIGS_JSON_FILE" ;;
      'nc'|'nextcloud'|'nextcloud_version') jq -r '.ncp.nextcloud_version' "$CONFIGS_JSON_FILE" ;;
      'php'|'php_version')                  jq -r '.ncp.php_version'       "$CONFIGS_JSON_FILE" ;;
      'os'|'release'|'os_release')          jq -r '.ncp.os_release'        "$CONFIGS_JSON_FILE" ;;
      *)                                    printf '%s\n'                  "Invalid field" ;;
    esac
  fi
}


# # # # # # # # # #
# Config Keys
# # # # # # # # # #
# id
# info
# infotitle
# description
# name
# params
# title
# # # # # # # # # #
# Params Keys
# # # # # # # # # #
# id
# name
# value
# type
# suggest
# default
# # # # # # # # # #
# Creates json configuration files for each entry in configs.json
function createConfigFiles() {
  if hasCMD jq
  then
    local ID
    for i in $(seq 0 "$CONFIGS_NUMBER")
    do
      ID="$(jq -r ".configs[$i].id" "$CONFIGS_JSON_FILE")"
      echo "ID: ${ID%*.json}"
      jq '.configs as $in |
            {
              "id": $in['"$i"'].id,
              "info": $in['"$i"'].info,
              "infotitle": $in['"$i"'].infotitle,
              "description": $in['"$i"'].description,
              "name": $in['"$i"'].name,
              "title": $in['"$i"'].title,
              "params": $in['"$i"'].params
            }' "$CONFIGS_JSON_FILE" > JSONData/Configurations/"$ID".json
    done
    jq '.ncp' "$CONFIGS_JSON_FILE" > "$NCP_CONFIGS_FILE"
    echo "ID: ncp"
  fi
}

# Recreates the configs.json file using the json config files available in JSONData/Configurations/ & JSONData/ncp
function createJSONConfigFile() {
  if hasCMD jq
  then
    local CONFIGS_TEMP_FILE="./tmp.json" TEMP_FILE="./temporary.json" NRFILES="$(ls "$CONFIGURATIONS" | wc -l)" NRCONF=$(( "$NRFILES" - 1 ))
    # $(seq 0 "$NRCONF")
    touch "$CONFIGS_TEMP_FILE"
    for CFG in "$CONFIGURATIONS"/*
    do
      ID="${CFG##*/}"
      echo "ID: ${ID%*.json}"
      jq -jc '. as $in |
            {
              "id": $in.id,
              "info": $in.info,
              "infotitle": $in.infotitle,
              "description": $in.description,
              "name": $in.name,
              "title": $in.title,
              "params": $in.params
            }' "$CFG" >> "$CONFIGS_TEMP_FILE"
    done
    jq -sjc '.[0] as $ncp | {"ncp": $ncp, "configs": .[1:]}' "$NCP_CONFIGS_FILE" "$CONFIGS_TEMP_FILE" > "$TEMP_FILE"
    mv "$TEMP_FILE" "$CONFIGS_JSON_FILE"
    rm "$CONFIGS_TEMP_FILE"
  fi
}

#getTotal
#getLength
#getConfigByID 12
#getIDs
#findIndexID 'nc-autoupdate-ncp'
#ncpConfigs
#getVersion 'ncp'
#getVersion 'nc'
#getVersion 'php'
#getVersion 'os'
#setVersion 'ncp' '2.0.0'
#getVersion 'nextcloudpi'
#setVersion 'nextcloud' '25.0.2'
#getVersion 'nextcloud'
#setVersion 'php' '8.1'
#getVersion 'php'
#setVersion 'os' 'bullseye'
#getVersion 'release'
#cleanupVariables
#createConfigFiles
createJSONConfigFile
