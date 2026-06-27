#!/bin/bash

# systemd drop-in for php-fpm to allow write access to NCP paths
# that are otherwise blocked by ProtectSystem=full in the upstream
# php-fpm service unit (introduced in php8.x Debian packages).
#
# ProtectSystem=full creates a private mount namespace to make /usr,
# /boot and /etc read-only for the php-fpm process.
#
# In unprivileged LXC containers, non-root users cannot create mount
# namespaces (unshare CLONE_NEWNS is blocked by the kernel), so
# ProtectSystem=full causes php-fpm to fail with status=226/NAMESPACE.
# In that case we disable ProtectSystem entirely. Security is still
# provided by Unix file permissions (cfg files are root:www-data 660)
# and LXC container isolation.
#
# On bare-metal, VMs, and privileged LXC, ReadWritePaths is used to
# carve out targeted exceptions while keeping the rest of the
# hardening intact.

set -e
source /usr/local/etc/library.sh

if is_lxc && ! sudo -u www-data unshare --mount true 2>/dev/null; then
  # Unprivileged LXC: namespace operations not permitted for non-root.
  # Disable ProtectSystem to prevent php-fpm failing with 226/NAMESPACE.
  cat <<EOF
[Service]
ProtectSystem=false
EOF
else
  # Bare-metal, VM, or privileged/nested LXC:
  # Keep ProtectSystem=full but allow writes to NCP-specific paths.
  cat <<EOF
[Service]
ReadWritePaths=/usr/local/etc/ncp-config.d
ReadWritePaths=/var/www/ncp-web
ProtectSystem=yes
EOF
fi
