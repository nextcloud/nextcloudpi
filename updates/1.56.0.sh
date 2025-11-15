#!/usr/bin/env bash

if ncc app_api:daemon:list | grep 'No registered daemon configs.' > /dev/null 2>&1
then
  ncc app:disable app_api
fi

cat > /etc/systemd/system/nextcloud-ai-worker@.service <<'EOF'
[Unit]
Description=Nextcloud AI worker %i
After=network.target

[Service]
ExecStart=php occ background-job:worker -t 60 'OC\\TaskProcessing\\SynchronousBackgroundJob'
Restart=always
StartLimitInterval=60
StartLimitBurst=10
WorkingDirectory=/var/www/nextcloud
User=www-data

[Install]
WantedBy=multi-user.target
EOF
max="$(nproc || echo '2')"
max="$((max-1))"
for i in $(seq 1 "$max")
do
  systemctl enable --now "nextcloud-ai-worker@${i}.service"
done

exit 0