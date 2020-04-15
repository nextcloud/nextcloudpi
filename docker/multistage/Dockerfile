# syntax=docker/dockerfile:experimental

ARG arch=armhf
ARG arch_qemu=arm
ARG debian_release_qemu=bullseye
ARG release=buster
ARG ncp_ver=v0.0.0

FROM debian:${debian_release_qemu}-slim AS qemu

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends qemu-user-static

ARG release
ARG arch_qemu
FROM ${arch}/debian:${release}-slim AS debian-ncp

ARG arch_qemu

LABEL maintainer="Ignacio Núñez Hernanz <nacho@ownyourbits.com>"

CMD /bin/bash

COPY --from=qemu /usr/bin/qemu-${arch_qemu}-static /usr/bin/

RUN mkdir -p /etc/services-available.d  /etc/services-enabled.d

COPY docker/debian-ncp/run-parts.sh /

#############################################################################

FROM debian-ncp as lamp

LABEL maintainer="Ignacio Núñez Hernanz <nacho@ownyourbits.com>"

SHELL ["/bin/bash", "-c"]

ENV DOCKERBUILD 1

COPY etc/ncp.cfg etc/library.sh lamp.sh /usr/local/etc/

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \

# installation
apt-get update; \
apt-get install --no-install-recommends -y jq; \

source /usr/local/etc/library.sh; \
set +x; \
install_app /usr/local/etc/lamp.sh; \

# stop mysqld
mysqladmin -u root shutdown; \

# mariaDB fixups (move database to /data-ro, which will be in a persistent volume)
mkdir -p /data-ro /data; \
mv /var/lib/mysql /data-ro/database; \
sed -i "s|^datadir.*|datadir = /data-ro/database|" /etc/mysql/mariadb.conf.d/90-ncp.cnf; \

# package cleanup
apt-get autoremove -y; \
apt-get clean; \
find /var/lib/apt/lists -type f | xargs rm; \
rm -rf /usr/share/man/*; \
rm -rf /usr/share/doc/*; \
rm /var/cache/debconf/*-old; \
rm -f /var/log/alternatives.log /var/log/apt/*; \

# specific cleanup
rm /data-ro/database/ib_logfile*; \
rm /usr/local/etc/lamp.sh

COPY docker/lamp/010lamp /etc/services-enabled.d/

ENTRYPOINT ["/run-parts.sh"]

EXPOSE 80 443

#############################################################################

FROM lamp as nextcloud

LABEL maintainer="Ignacio Núñez Hernanz <nacho@ownyourbits.com>"

SHELL ["/bin/bash", "-c"]

ENV DOCKERBUILD 1

COPY etc/library.sh /usr/local/etc/
COPY bin/ncp/CONFIG/nc-nextcloud.sh /
COPY etc/ncp-config.d/nc-nextcloud.cfg /usr/local/etc/ncp-config.d/

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \

set -x; \

# mark as image build
touch /.ncp-image; \

# installation ( /var/www/nextcloud -> /data/app which will be in a volume )
apt-get update; \
apt-get install --no-install-recommends -y wget ca-certificates sudo jq; \
source /usr/local/etc/library.sh; \
install_app /nc-nextcloud.sh; \
run_app_unsafe /nc-nextcloud.sh; \
mv /var/www/nextcloud /data-ro/nextcloud; \
ln -s /data-ro/nextcloud /var/www/nextcloud; \

# stop mysqld
mysqladmin -u root shutdown; \

# package cleanup 
apt-get autoremove -y; \
apt-get clean; \
find /var/lib/apt/lists -type f | xargs rm; \
rm -rf /usr/share/man/*; \
rm -rf /usr/share/doc/*; \
rm /var/cache/debconf/*-old; \
rm -f /var/log/alternatives.log /var/log/apt/*; \

# specific cleanup
apt-get purge -y wget ca-certificates; \
rm /nc-nextcloud.sh /usr/local/etc/ncp-config.d/nc-nextcloud.cfg; \
rm /.ncp-image; 

COPY docker/nextcloud/020nextcloud /etc/services-enabled.d/
COPY bin/ncp-provisioning.sh /usr/local/bin/

# display message until first run initialization is complete
COPY docker/nextcloud/ncp-wait-msg.html /data-ro/nextcloud
RUN \
mv /data-ro/nextcloud/index.php /; \
mv /data-ro/nextcloud/ncp-wait-msg.html /data-ro/nextcloud/index.php;

#############################################################################

FROM nextcloud as nextcloudpi

ARG ncp_ver

LABEL maintainer="Ignacio Núñez Hernanz <nacho@ownyourbits.com>"

SHELL ["/bin/bash", "-c"]

ENV DOCKERBUILD 1

RUN mkdir -p /tmp/ncp-build
COPY bin/                 /tmp/ncp-build/bin/
COPY etc                  /tmp/ncp-build/etc/
COPY ncp.sh update.sh     /tmp/ncp-build/
COPY ncp-web              /tmp/ncp-build/ncp-web/
COPY ncp-app              /tmp/ncp-build/ncp-app/
COPY ncp-previewgenerator /tmp/ncp-build/ncp-previewgenerator/
COPY docker               /tmp/ncp-build/docker/

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

# package clean up
apt-get autoremove -y; \
apt-get clean; \
find /var/lib/apt/lists -type f | xargs rm; \
find /var/log -type f -exec rm {} \; ; \
rm -rf /usr/share/man/*; \
rm -rf /usr/share/doc/*; \
rm -f /var/log/alternatives.log /var/log/apt/*; \
rm /var/cache/debconf/*-old; \

# set version
echo "${ncp_ver}" > /usr/local/etc/ncp-version

COPY docker/nextcloudpi/000ncp /etc/services-enabled.d/
COPY bin/ncp/CONFIG/nc-init.sh /
COPY etc/ncp-config.d/nc-init.cfg /usr/local/etc/ncp-config.d/

EXPOSE 4443
EXPOSE 80
EXPOSE 443