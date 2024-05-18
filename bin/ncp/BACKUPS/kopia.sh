#!/bin/bash
# Nextcloud backups
#
# Copyleft 2023 by Tobias Knöppler
# GPL licensed (see end of file) * Use at your own risk!
#

tmpl_repository_local_path() {
  repo="$(find_app_param kopia REPOSITORY)"
  if [[ "${repo}" =~ ^"file://" ]] || ! [[ "${repo}" =~ ^.*"://" ]]
  then
    echo "${repo#file://}"
    return
  fi

  echo ''
}

tmpl_repository_type() {
  repo="$(find_app_param kopia REPOSITORY)"
  get_repository_type "$repo"
}

tmpl_repository_password() {
  get_repository_password
}

get_repository_password() {
  pw_param="${1:-$(find_app_param kopia REPOSITORY_PASSWORD)}"
  pw_file="$([[ -f /usr/local/etc/kopia/password ]] && cat /usr/local/etc/kopia/password || echo '')"
  echo "${pw_param:-${pw_file}}"
}

get_repository_type() {
  local repo="${1}"
  [[ -z "${repo}" ]] && {
    [[ -f /usr/local/etc/kopia/repository.config ]] && {
      repo_type="$(jq -er '.storage.type' /usr/local/etc/kopia/repository.config)"
      if [[ -n "$repo_type" ]] && [[ "$repo_type" != "null" ]]
      then
        echo "$repo_type"
        return
      fi
    }
    echo ''
    return
  }
  if [[ "${repo}" =~ ^"file://" ]] || ! [[ "${repo}" =~ ^.*"://" ]]; then
    echo 'filesystem'
  elif [[ "${repo}" =~ ^"sftp://" ]]; then
    echo 'sftp'
  elif [[ "${repo}" =~ ^"s3://" ]]; then
    echo 's3'
  elif [[ "${repo}" =~ ^"b2://" ]]; then
    echo 'b2'
  else
    echo "unsupported repository type: '${repo}'" >&2
    return 1
  fi
}

is_active() {
  [[ -f /usr/local/etc/kopia/repository.config ]] && [[ -f /etc/cron.hourly/ncp-kopia ]]
}

setup_repository() {

  set -e

  local repo_definition="${1}"
  local storage_key="${2}"
  local repository_password="${3}"
  local hostname="${4?}"

  mkdir -p /usr/local/etc/kopia
  mkdir -p /var/log/kopia

  kopia_flags=(--config-file=/usr/local/etc/kopia/repository.config --log-dir="/var/log/kopia" --no-persist-credentials)
  kopia_repo_args=()

  repo_type="$(get_repository_type "${repo_definition}")"
  repo="${repo_definition#*://}"
  storage_key="$(echo -n "${storage_key}" | base64 -d)"

  [[ -z "$repo_definition" ]] && ! [[ -f /usr/local/etc/kopia/repository.config ]] && {
    echo "REPOSITORY not set and no repository config found!"
    return 1
  }

  if [[ -z "${repo_defintion}" ]]
  then
    repo_type=from-config
    kopia_repo_args=(--file="/usr/local/etc/kopia/repository.config")
  else
    if [[ "${repo_type}" == "filesystem" ]]; then
      repo_path="$(tmpl_repository_local_path)"
      kopia_repo_args=(--path "${repo_path}")
    elif [[ "${repo_type}" == "sftp" ]]; then
      sftp_user="${repo%@*}"
      sftp_host="${repo#*@}"
      sftp_host="${sftp_host%:*}"
      repo_path="${repo#*:}"
      if [[ -n "${storage_key}" ]]
      then
        echo "Installing STORAGE_KEY as ssh private key..."
        mkdir -p ~root/.ssh
        touch ~root/.ssh/kopia_key
        chmod 0600 ~root/.ssh/kopia_key
        echo "${storage_key}" > ~root/.ssh/kopia_key
        eval "$(ssh-agent)"
        ssh-add ~root/.ssh/kopia_key
        kopia_repo_args+=("--key-data=$(cat ~root/.ssh/kopia_key)")
      fi
      ssh -o "BatchMode=yes" -o "StrictHostKeyChecking=no" "${sftp_user}@${sftp_host}" || { echo "SSH non-interactive not properly configured"; return 1; }
      rm ~root/.ssh/kopia_key
      kopia_repo_args+=(--host="${sftp_host}" --username="${sftp_user}" --path="${repo_path}" --known-hosts-data="$(cat ~root/.ssh/known_hosts)")
    elif [[ "${repo_type}" == "b2" ]]; then
      if [[ -z "$storage_key" ]]; then
        echo "Key is required for b2 backend, but was not provided"
        return 1
      fi
      key_id="${storage_key%:*}"
      key_value="${storage_key#*:}"
      kopia_repo_args+=(--bucket="${repo}" --key-id="${key_id}" --key="${key_value}")
    elif [[ "${repo_type}" == "s3" ]]; then
        if [[ -z "$storage_key" ]]; then
          echo "Key is required for s3 backend, but was not provided"
          return 1
        fi
        key_id="${storage_key%:*}"
        key_value="${storage_key#*:}"
        kopia_repo_args+=(--bucket="${repo}" --access-key="${key_id}" --secret-access-key="${key_value}")
    else
      echo "Invalid repository type '${repo_type}'"
      return 1
    fi
  fi

  export KOPIA_PASSWORD="$(get_repository_password "${repository_password}")"

  echo "Attempting to connect to existing repository first..."
  kopia "${kopia_flags[@]}" \
    repository connect "${repo_type}" \
      "${kopia_repo_args[@]}" \
      --override-username nextcloudpi \
      --override-hostname "$hostname" || {
    echo "Creating new repository..."
    kopia "${kopia_flags[@]}" \
      repository create "${repo_type}" \
        "${kopia_repo_args[@]}" \
        --override-username ncp \
        --override-hostname "$hostname"
  }

  kopia "${kopia_flags[@]}" cache set --cache-directory="${DESTINATION?DESTINATION must not be empty}/.kopia_cache"

  chmod 0600 /usr/local/etc/kopia/repository.config
  touch /usr/local/etc/kopia/password
  chmod 0600 /usr/local/etc/kopia/password
  chown root: /usr/local/etc/kopia/password
  echo "${KOPIA_PASSWORD}" > /usr/local/etc/kopia/password
  echo "Repository initialized successfully"
}

install() {
  curl -s https://kopia.io/signing-key | sudo gpg --dearmor -o /etc/apt/keyrings/kopia-keyring.gpg
  echo "deb [signed-by=/etc/apt/keyrings/kopia-keyring.gpg] http://packages.kopia.io/apt/ stable main" | sudo tee /etc/apt/sources.list.d/kopia.list
  sudo apt update
  sudo apt install kopia

  WEBADMIN=ncp

  cat > /etc/apache2/sites-available/kopia.conf <<EOF
Listen 51000
<VirtualHost _default_:51000>
  DocumentRoot /dev/null
  SSLEngine on
  SSLCertificateFile      /etc/ssl/certs/ssl-cert-snakeoil.pem
  SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key
  <IfModule mod_headers.c>
    Header always set Strict-Transport-Security "max-age=15768000; includeSubDomains"
  </IfModule>

  # 2 days to avoid very big backups requests to timeout
  TimeOut 172800

  <IfModule mod_authnz_external.c>
    DefineExternalAuth pwauth pipe /usr/sbin/pwauth
  </IfModule>


  ProxyPass / http://127.0.0.1:51515/
  ProxyPassReverse / http://127.0.0.1:51515/

  <Location />
    AuthType Basic
    AuthName "ncp-web login"
    AuthBasicProvider external
    AuthExternal pwauth

    <RequireAll>

     <RequireAny>
        Require host localhost
        Require local
        Require ip 192.168
        Require ip 172
        Require ip 10
        Require ip fe80::/10
        Require ip fd00::/8
     </RequireAny>

     <RequireAny>
        Require env noauth
        Require user $WEBADMIN
     </RequireAny>

    </RequireAll>
    RequestHeader set Authorization "null"
  </Location>

</VirtualHost>
EOF
  cat > /etc/systemd/system/kopia-ui.service <<EOF
[Unit]
Description=Kopia web UI
After=docker.service
Requires=docker.service

[Service]
ExecStart=/usr/local/bin/kopia-ui --attach
ExecStop=/usr/local/bin/kopia-ui --stop
SyslogIdentifier=ncp-kopia-ui
Restart=on-failure
RestartSec=120

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
}

configure() {

  set -e

  hostname="$(ncc config:system:get overwrite.cli.url)"
  hostname="${hostname##http*:\/\/}}"
  hostname="${hostname%%/*}"

  kopia_flags=(--config-file=/usr/local/etc/kopia/repository.config --log-dir="/var/log/kopia" --no-persist-credentials)

  setup_repository "${REPOSITORY}" "${STORAGE_KEY}" "${REPOSITORY_PASSWORD}" "${hostname}"

  echo "Configuring backup policy..."
  kopia "${kopia_flags[@]}" \
    policy set --global \
      --keep-annual 2 --keep-monthly 12 --keep-weekly 4 --keep-daily 7 --keep-hourly 24 \
      --add-ignore '/ncdata/.opcache' \
      --add-ignore '/ncdata/.kopia' \
      --add-ignore '/ncdata/nextcloud.log' \
      --add-ignore '/ncdata/ncp-update-backups' \
      --add-ignore '/ncdata/appdata_*/preview/*' \
      --add-ignore '/ncdata/*/cache' \
      --add-ignore '/ncdata/*/uploads' \
      --add-ignore '/ncdata/.data_*'

  if [[ "${RUN_BACKUP}" == "yes" ]]
  then
    echo "Running manual backup"
    /usr/local/bin/kopia-backup
  fi

  if [[ "${AUTOMATIC_BACKUPS}" == "yes" ]]
  then
    echo "Enabling automatic backups"
    cat > /etc/cron.hourly/ncp-kopia <<EOF
#!/bin/bash
/usr/local/bin/kopia-backup
EOF
    chmod +x /etc/cron.hourly/ncp-kopia
  else
    rm -f /etc/cron.hourly/ncp-kopia
  fi

  if [[ "${ENABLE_WEB_UI}" == "yes" ]]
  then
    systemctl enable kopia-ui
    systemctl restart kopia-ui
    echo "The kopia web UI has been enabled. To access it, go to https://nextcloudpi.local:51000 and login with the same credentials as on the NCP admin interface."
  else
    systemctl disable kopia-ui
    systemctl stop kopia-ui
    echo "The kopia web UI has been disabled."
  fi

  echo "Done."
}
