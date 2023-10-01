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

install() {
  curl -s https://kopia.io/signing-key | sudo gpg --dearmor -o /etc/apt/keyrings/kopia-keyring.gpg
  echo "deb [signed-by=/etc/apt/keyrings/kopia-keyring.gpg] http://packages.kopia.io/apt/ stable main" | sudo tee /etc/apt/sources.list.d/kopia.list
  sudo apt update
  sudo apt install kopia
}

configure() {

  set -e

  mkdir -p /usr/local/etc/kopia
  mkdir -p /var/log/kopia
  hostname="$(ncc config:system:get overwrite.cli.url)"

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

  cat > /etc/cron.hourly/ncp-kopia <<EOF
#!/bin/bash
KOPIA_PASSWORD="${REPOSITORY_PASSWORD}" /usr/local/bin/kopia-bkp.sh
EOF
  chmod 0700 /etc/cron.hourly/ncp-kopia
  echo "Repository initialized successfully"

}
