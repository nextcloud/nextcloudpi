# syntax=docker/dockerfile:experimental

ARG arch=armhf

FROM ownyourbits/nextcloud-${arch}

ARG ncp_ver=v0.0.0

LABEL maintainer="Ignacio Núñez Hernanz <nacho@ownyourbits.com>"

SHELL ["/bin/bash", "-c"]

ENV DOCKERBUILD 1

RUN mkdir -p /tmp/ncp-build
COPY bin/                          /tmp/ncp-build/bin/
COPY etc                           /tmp/ncp-build/etc/
COPY ncp-web                       /tmp/ncp-build/ncp-web/
COPY ncp-app                       /tmp/ncp-build/ncp-app/
COPY ncp-previewgenerator          /tmp/ncp-build/ncp-previewgenerator/
COPY build/docker                  /tmp/ncp-build/build/docker/
COPY ncp.sh update.sh post-inst.sh /tmp/ncp-build/
COPY etc/ncp-config.d/nc-init.cfg /usr/local/etc/ncp-config.d/nc-init-copy.cfg

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
set -e; \

# make sure we don't accidentally disable first run wizard
rm -f ncp-web/{wizard.cfg,ncp-web.cfg}; \

# mark as image build
touch /.ncp-image; \

# mark as docker image
touch /.docker-image; \

apt-get update; \
apt-get install --no-install-recommends -y wget ca-certificates; \

# install nextcloudpi
source /usr/local/etc/library.sh; \
cd /tmp/ncp-build/; \
install_app ncp.sh; \

mv /usr/local/etc/ncp-config.d/nc-init-copy.cfg /usr/local/etc/ncp-config.d/nc-init.cfg; \
run_app_unsafe bin/ncp/CONFIG/nc-init.sh; \
sed -i 's|data-ro|data|' /data-ro/nextcloud/config/config.php; \

# fix default paths
sed -i 's|/media/USBdrive|/data/backups|' /usr/local/etc/ncp-config.d/nc-backup.cfg; \
sed -i 's|/media/USBdrive|/data/backups|' /usr/local/etc/ncp-config.d/nc-backup-auto.cfg; \

# cleanup all NCP extras
run_app_unsafe post-inst.sh; \

# specific cleanup
cd /; rm -r /tmp/ncp-build; \
rm /usr/local/etc/ncp-config.d/nc-init.cfg; \

# package installation clean up
rm -rf /usr/share/man/*; \
rm -rf /usr/share/doc/*; \
rm -f /var/log/alternatives.log /var/log/apt/*; \
rm /var/cache/debconf/*-old; \

# set version
echo "${ncp_ver}" > /usr/local/etc/ncp-version

COPY build/docker/nextcloudpi/000ncp /etc/services-enabled.d/
