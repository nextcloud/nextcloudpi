
# docker images only
[[ -f /.docker-image ]] && {
  cat <<EOF > /etc/cron.daily/refresh_notify_push
#!/usr/bin/env bash
. /usr/local/etc/library.sh
ncc notify_push:self-test || {
  killall notify_push
  sleep 1
  start_notify_push
}"
EOF
  chmod +x /etc/cron.daily/refresh_notify_push
}

# for non docker images
[[ ! -f /.docker-image ]] && {
  cat > /etc/systemd/system/refresh_notify_push.service <<EOF
[Unit]
Description = Restart notify_push service when the NC app is updated

[Service]
Type = oneshot
ExecStart = systemctl restart notify_push.service

[Install]
WantedBy = multi-user.target
EOF
  cat > /etc/systemd/system/refresh_notify_push.path <<EOF
[Unit]
Description = Path watcher component for refresh_notify_push.service

[Path]
PathModified = /var/www/nextcloud/apps/notify_push/

[Install]
WantedBy = multi-user.target
EOF

  systemctl daemon-reload
  systemctl enable refresh_notify_push.{path,service}
  systemctl restart refresh_notify_push.path
}
