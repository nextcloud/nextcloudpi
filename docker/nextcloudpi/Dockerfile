# syntax=docker/dockerfile:experimental

ARG arch=armhf

FROM ownyourbits/nextcloud-${arch}

LABEL maintainer="Ignacio Núñez Hernanz <nacho@ownyourbits.com>"

SHELL ["/bin/bash", "-c"]

ENV DOCKERBUILD 1

RUN mkdir -p /tmp/ncp-build
COPY bin/             /tmp/ncp-build/bin/
COPY etc              /tmp/ncp-build/etc/
COPY ncp.sh update.sh /tmp/ncp-build/
COPY ncp-web          /tmp/ncp-build/ncp-web/
COPY ncp-app          /tmp/ncp-build/ncp-app/
COPY docker           /tmp/ncp-build/docker/

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \

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
set +x; \
cd /tmp/ncp-build/; \
install_app ncp.sh; \

# fix default paths
sed -i 's|/media/USBdrive|/data/backups|' /usr/local/etc/ncp-config.d/nc-backup.cfg; \
sed -i 's|/media/USBdrive|/data/backups|' /usr/local/etc/ncp-config.d/nc-backup-auto.cfg; \

# specific cleanup
cd /; rm -r /tmp/ncp-build; \
rm /.ncp-image; \

# cleanup all NCP extras
source /usr/local/etc/library.sh; \
find /usr/local/bin/ncp -name '*.sh' | while read l; do cleanup_script $l; done; \

# should be cleaned up in no-ip.sh, but breaks udiskie.
# safe to do it here since no automount in docker
apt-get purge -y make gcc libc-dev; \

# package clean up
apt-get autoremove -y; \
apt-get clean; \
find /var/lib/apt/lists -type f | xargs rm; \
find /var/log -type f -exec rm {} \; ; \
rm -rf /usr/share/man/*; \
rm -rf /usr/share/doc/*; \
rm -f /var/log/alternatives.log /var/log/apt/*; \
rm /var/cache/debconf/*-old; 

COPY docker/nextcloudpi/000ncp /etc/services-enabled.d/
COPY bin/ncp/CONFIG/nc-init.sh /
COPY etc/ncp-config.d/nc-init.cfg /usr/local/etc/ncp-config.d/

# 4443 - ncp-web
EXPOSE 80 443 4443
