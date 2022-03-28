#!/bin/bash

is_active() {
  systemctl is-active -q prometheus-node-exporter || return 1
  return 0
}

tmpl_metrics_enabled() {
  (
  . /usr/local/etc/library.sh
  local param_active="$(find_app_param metrics.sh ACTIVE)"
  [[ "$param_active" == yes ]] || exit 1
  )
}

install() {

  # Subshell to return on failure  instead of exiting (due to set -e)
  (

  set -e
  cat > /etc/default/prometheus-node-exporter <<'EOF'
ARGS="--collector.filesystem.ignored-mount-points=\"^/(dev|proc|run|sys|mnt|var/log|var/lib/docker)($|/)\""
EOF
  apt_install prometheus-node-exporter

  # TODO: Docker support?
  systemctl disable prometheus-node-exporter
  service prometheus-node-exporter stop

  [[ "$(uname -m)" =~ ("arm"|"aarch").* ]] && arch="armv7" || arch="i686"
  [[ "$arch" == "i686" ]] && apt_install lib32gcc-s1 libc6-i386

  wget -O "/usr/local/bin/ncp-metrics-exporter" \
    "https://github.com/theCalcaholic/ncp-metrics-exporter/releases/download/v1.0.0/${arch}-ncp-metrics-exporter"
  chmod +x /usr/local/bin/ncp-metrics-exporter
  cat <<EOF > /etc/systemd/system/ncp-metrics-exporter.service
[Unit]
Description=NCP Metrics Exporter

[Service]
Environment=NCP_CONFIG_DIR=/usr/local/etc
ExecStart=/usr/local/bin/ncp-metrics-exporter
SyslogIdentifier=ncp-metrics
Restart=on-failure
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload

  )
}

reload_metrics_config() {
  install_template ncp-metrics.cfg.sh "/usr/local/etc/ncp-metrics.cfg" || {
    echo "ERROR while generating ncp-metrics.conf!"
    return 1
  }
  service ncp-metrics-exporter status > /dev/null && {
    service ncp-metrics-exporter restart
    service ncp-metrics-exporter status > /dev/null 2>&1 || {
      rc=$?
      echo -e "WARNING: An error ncp-metrics exporter failed to start (exit-code $rc)!"
      return 1
    }
  }
}

configure() {

  if [[ "$ACTIVE" != yes ]]
  then
    install_template nextcloud.conf.sh /etc/apache2/sites-available/nextcloud.conf

    systemctl disable prometheus-node-exporter
    service prometheus-node-exporter stop

    systemctl disable ncp-metrics-exporter
    service ncp-metrics-exporter stop
  else
    [[ -n "$USER" ]] || {
      echo "ERROR: User can not be empty!" >&2
      return 1
    }

    [[ -n "$PASSWORD" ]] || {
      echo "ERROR: Password can not be empty!" >&2
      return 1
    }

    [[ ${#PASSWORD} -ge 10 ]] || {
      echo "ERROR: Password must be at least 10 characters long!" >&2
      return 1
    }

    local htpasswd_file="/usr/local/etc/metrics.htpasswd"
    rm -f "${htpasswd_file}"
    echo "$PASSWORD" | htpasswd -ciB "${htpasswd_file}" "$USER"

    install_template nextcloud.conf.sh /etc/apache2/sites-available/nextcloud.conf || {
      echo "ERROR while generating nextcloud.conf! Exiting..."
      return 1
    }
    echo "Generate config..."
    reload_metrics_config
    echo "done."

    echo "Starting prometheus node exporter..."
    systemctl enable prometheus-node-exporter
    service prometheus-node-exporter start
    service prometheus-node-exporter status
    echo "done."

    echo "Starting ncp metrics exporter..."
    systemctl enable ncp-metrics-exporter
    service ncp-metrics-exporter start
    service ncp-metrics-exporter status
    echo "done."

    echo "Metrics endpoint enabled. You can test it at https://nextcloudpi.local/metrics/system (or under your NC domain under the same path)"
  fi
  echo "Apache Test:"
  apache2ctl -t
  bash -c "sleep 2 && service apache2 reload" &>/dev/null &

}
