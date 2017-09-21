# docker run -d -p 443:443 -p 80:80 -v ncdata:/data --name nextcloud ownyourbits/nextcloud
# docker build . -f nextcloud.dockerfile -t ownyourbits/nextcloud:latest

FROM ownyourbits/lamp-arm

MAINTAINER Ignacio Núñez Hernanz <nacho@ownyourbits.com>

SHELL ["/bin/bash", "-c"]

COPY etc/library.sh etc/nextcloudpi-config.d/nc-init.sh etc/nextcloudpi-config.d/nc-nextcloud.sh /usr/local/etc/

RUN \

# installation
apt-get update; \
apt-get install --no-install-recommends -y wget ca-certificates iputils-ping; \
source /usr/local/etc/library.sh; \
set +x; \
activate_script /usr/local/etc/nc-nextcloud.sh; \

# package cleanup 
apt-get autoremove -y; \
apt-get clean; \
rm /var/lib/apt/lists/* -f; \
rm -rf /usr/share/man/*; \
rm -rf /usr/share/doc/*; \
rm /var/cache/debconf/*-old; \
rm -f /var/log/alternatives.log /var/log/apt/*; \

# specific cleanup
apt-get purge -y wget ca-certificates; \
rm /usr/local/etc/nc-nextcloud.sh

# TODO install make in noip:

# TODO consider pre-populating /data (volume overcopies)
# TODO call cleanup() hooks for extras
# TODO remove packages unneeded from lamp, wget...
# # libudev1 util-linux
# TODO remove mariadb client (reinstall mysqldump later, but that only)
# apt-get purge -y wget ca-certificates libhogweed4 libnettle4 libpsl5
# apt-get purge -y wget ca-certificates libgnutls-deb0-28 libhogweed2 libicu52 libnettle4 libpsl0

COPY docker/nextcloud/020-nextcloud-run.sh /etc/cont-init.d/
