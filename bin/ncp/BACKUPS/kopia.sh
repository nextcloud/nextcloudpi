#!/bin/bash
# Nextcloud backups
#
# Copyleft 2023 by Tobias Knöppler
# GPL licensed (see end of file) * Use at your own risk!
#

tmpl_destination() {
  find_app_param kopia DESTINATION
}

tmpl_repository_type() {
  [[ "$DESTINATION" =~ .*'@'.*':'.* ]] && echo "sftp" || echo "filesystem"
}

is_active() {
  [[ -f /usr/local/etc/kopia/repository.config ]] && [[ -f /etc/cron.hourly/ncp-kopia ]]
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

  mkdir -p /usr/local/etc/kopia
  mkdir -p /var/log/kopia
  hostname="$(ncc config:system:get overwrite.cli.url)"
  hostname="${hostname##http*:\/\/}}"
  hostname="${hostname%%/*}"

  kopia_flags=(--config-file=/usr/local/etc/kopia/repository.config --log-dir="/var/log/kopia" --no-persist-credentials)
  kopia "${kopia_flags[@]}" cache set --cache-directory="${DESTINATION?DESTINATION must not be empty}/.kopia_cache"
  kopia_repo_args=()
  if [[ "$DESTINATION" =~ .*'@'.*':'.* ]]
  then
    repo_type="sftp"
    sftp_user="${DESTINATION%@*}"
    sftp_host="${DESTINATION#*@}"
    sftp_host="${sftp_host%:*}"
    repo_path="${DESTINATION#*:}"
    ssh -o "BatchMode=yes" "${sftp_user}@${sftp_host}" || { echo "SSH non-interactive not properly configured"; return 1; }
    kopia_repo_args=(--host "${sftp_host}" --user "${sftp_user}" --path "${repo_path}")
  else
    repo_type="filesystem"
    repo_path="${DESTINATION}/ncp-kopia"
    kopia_repo_args=(--path "${repo_path}")
  fi

  export KOPIA_PASSWORD="${REPOSITORY_PASSWORD?}"

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

  touch /usr/local/etc/kopia/password
  chmod 0600 /usr/local/etc/kopia/password
  chown root: /usr/local/etc/kopia/password
  echo "${REPOSITORY_PASSWORD}" > /usr/local/etc/kopia/password
  echo "Repository initialized successfully"

  if [[ "${AUTOMATIC_BACKUPS}" == "yes" ]]
  then
    echo "Enabling automatic backups"
    cat > /etc/cron.hourly/ncp-kopia <<EOF
#!/bin/bash
KOPIA_PASSWORD="$(cat /usr/local/etc/kopia/password)" /usr/local/bin/kopia-backup
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
