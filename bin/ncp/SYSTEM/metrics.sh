#!/bin/bash

is_active() {
  return 1
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
  cp /usr/local/etc/ncp-templates/prometheus-node-exporter.defaults /etc/default/prometheus-node-exporter
  apt-get update && apt-get install -y --no-install-recommends prometheus-node-exporter
    service prometheus-node-exporter disable
    service prometheus-node-exporter stop

  a2enmod proxy_http
  service apache2 restart

  )
}

configure() {

  if [[ "$ACTIVE" != yes ]]
  then
    bash /usr/local/etc/ncp-templates/nextcloud.conf.sh --defaults > /etc/apache2/sites-available/nextcloud.conf

    service prometheus-node-exporter disable
    service prometheus-node-exporter stop
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
    [[ -f "${htpasswd_file}" ]] && rm "${htpasswd_file}"
    echo "$PASSWORD" | htpasswd -ciB "${htpasswd_file}" metrics

    bash /usr/local/etc/ncp-templates/nextcloud.conf.sh > /etc/apache2/sites-available/nextcloud.conf || {
      echo "An unexpected error occurred while configuring apache. Rolling back..." >&2
      bash /usr/local/etc/ncp-templates/nextcloud.conf.sh --defaults > /etc/apache2/sites-available/nextcloud.conf
      return 1
    }

    service prometheus-node-exporter enable
    service prometheus-node-exporter start

    echo "Metric endpoint enabled. You can test it at https://nextcloudpi.local/metrics/system (or under your NC domain under the same path)"
  fi
  service apache2 reload


}
