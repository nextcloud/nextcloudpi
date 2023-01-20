ARG arch=arm32v7
ARG arch_qemu=arm
ARG release=bullseye
FROM --platform=linux/amd64 debian:${release}-slim AS qemu

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends qemu-user-static

FROM ${arch}/debian:${release}-slim as debian-ncp

ARG arch_qemu

LABEL maintainer="Tobias Knöppler"

CMD /bin/bash

COPY --from=qemu /usr/bin/qemu-${arch_qemu}-static /usr/bin/

RUN mkdir -p /etc/services-available.d  /etc/services-enabled.d

COPY build/docker/debian-ncp/run-parts.sh /

# syntax=docker/dockerfile:experimental

FROM --platform=linux/${arch} debian-ncp as lamp

LABEL maintainer="Ignacio Núñez Hernanz <nacho@ownyourbits.com>"

SHELL ["/bin/bash", "-c"]

ENV DOCKERBUILD 1
ENV APACHE_RUN_USER=www-data
ENV APACHE_RUN_GROUP=www-data
ENV APACHE_LOG_DIR=/var/log/apache2
ENV APACHE_LOCK_DIR=/var/lock/apache2
ENV APACHE_PID_FILE=/var/run/apache2.pid
ENV APACHE_RUN_DIR=/var/run/apache2

COPY etc/ncp.cfg etc/library.sh lamp.sh /usr/local/etc/
COPY etc/ncp-templates /usr/local/etc/ncp-templates

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
set -e; \

# mark as image build
touch /.ncp-image; \

# installation
apt-get update; \
apt-get install --no-install-recommends -y jq wget procps ca-certificates lsb-release; \

source /usr/local/etc/library.sh; \
set +x; \
install_app /usr/local/etc/lamp.sh; \

# stop mysqld
mysqladmin -u root shutdown; \

# mariaDB fixups (move database to /data-ro, which will be in a persistent volume)
mkdir -p /data-ro /data; \
mv /var/lib/mysql /data-ro/database; \
install_template "mysql/90-ncp.cnf.sh" "/etc/mysql/mariadb.conf.d/90-ncp.cnf" \

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
rm /usr/local/etc/lamp.sh; \
rm /.ncp-image;

COPY build/docker/lamp/010lamp /etc/services-enabled.d/

ENTRYPOINT ["/run-parts.sh"]

EXPOSE 80 443

FROM --platform=linux/${arch} lamp as nextcloud
# syntax=docker/dockerfile:experimental

ARG arch_qemu

LABEL maintainer="Ignacio Núñez Hernanz <nacho@ownyourbits.com>"

SHELL ["/bin/bash", "-c"]

ENV DOCKERBUILD 1

COPY etc/library.sh /usr/local/etc/
COPY bin/ncp/CONFIG/nc-nextcloud.sh /
COPY etc/ncp-config.d/nc-nextcloud.cfg /usr/local/etc/ncp-config.d/

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
set -e; \

# mark as image build
touch /.ncp-image; \

# mark as docker image
touch /.docker-image; \

# installation ( /var/www/nextcloud -> /data/app which will be in a volume )
apt-get update; \
apt-get install --no-install-recommends -y sudo jq; \
source /usr/local/etc/library.sh; \
install_app /nc-nextcloud.sh; \
run_app_unsafe /nc-nextcloud.sh; \
mv /var/www/nextcloud /data-ro/nextcloud; \
ln -s /data-ro/nextcloud /var/www/nextcloud; \

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

COPY build/docker/nextcloud/020nextcloud /etc/services-enabled.d/
COPY bin/ncp-provisioning.sh /usr/local/bin/
# syntax=docker/dockerfile:experimental

FROM --platform=linux/${arch} nextcloud as nextcloudpi

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
COPY etc/ncp-config.d/nc-datadir.cfg /usr/local/etc/ncp-config.d/nc-datadir-copy.cfg

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
set -ex; \

# make sure we don't accidentally disable first run wizard
rm -f ncp-web/{wizard.cfg,ncp-web.cfg}; \

# mark as image build
touch /.ncp-image; \

# mark as docker image
touch /.docker-image; \

apt-get update; \
apt-get install --no-install-recommends -y wget ca-certificates; \

# install nextcloudpiset_app_param nc-datadir.sh DATADIR '/data-ro/ncdata' \
source /usr/local/etc/library.sh; \
cd /tmp/ncp-build/; \
install_app ncp.sh; \

mv /usr/local/etc/ncp-config.d/nc-init-copy.cfg /usr/local/etc/ncp-config.d/nc-init.cfg; \
run_app_unsafe bin/ncp/CONFIG/nc-init.sh; \
echo 'Moving data directory to a more sensible location'; \
mv /usr/local/etc/ncp-config.d/nc-datadir-copy.cfg /usr/local/etc/ncp-config.d/nc-datadir.cfg; \
mkdir -p /data-ro/ncdata; \
set_app_param nc-datadir.sh DATADIR '/data-ro/ncdata'; \
BUILD_MODE=1 DISABLE_FS_CHECK=1  run_app_unsafe bin/ncp/CONFIG/nc-datadir.sh; \
set_app_param nc-datadir.sh DATADIR '/data/ncdata'; \
# Remove nc-datadir.cfg as it's disabled in docker
rm /usr/local/etc/ncp-config.d/nc-datadir.cfg; \
sed -i 's|data-ro|data|' /data-ro/nextcloud/config/config.php; \

# fix default paths
echo "Update data-ro"; \
sed -i 's|/media/USBdrive|/data/backups|' /usr/local/etc/ncp-config.d/nc-backup.cfg; \
sed -i 's|/media/USBdrive|/data/backups|' /usr/local/etc/ncp-config.d/nc-backup-auto.cfg; \
sed -i 's|/data-ro|/data|' /etc/mysql/mariadb.conf.d/90-ncp.cnf; \

echo "DEBUGGING:"; \
cat /etc/mysql/mariadb.conf.d/90-ncp.cnf; \
ls -l /usr/local/bin/; \

# cleanup all NCP extras
run_app_unsafe post-inst.sh; \

echo "DEBUGGING:"; \
cat /etc/mysql/mariadb.conf.d/90-ncp.cnf; \
ls -l /usr/local/bin/; \

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

FROM --platform=linux/${arch} nextcloudpi as ncp-qemu-fix

RUN echo 'Mutex posixsem' >> /etc/apache2/mods-available/ssl.conf
