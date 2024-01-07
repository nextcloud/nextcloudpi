cat <<EOF
[Unit]
Description=Redis Server
After=docker.service
Requires=docker.service

[Service]
ExecStart=/usr/bin/docker run --rm -v /etc/redis:/usr/local/etc/redis:Z -p 127.0.0.1:6379:6379 --name ncp-redis docker.io/redis:alpine /usr/local/etc/redis/redis.conf
SyslogIdentifier=ncp-redis
Restart=on-failure
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF

#systemd-analyze verify redis.service >&2
systemctl daemon-reload >&2
