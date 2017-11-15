FROM ownyourbits/lamp-x86

MAINTAINER Ignacio Núñez Hernanz <nacho@ownyourbits.com>

SHELL ["/bin/bash", "-c"]

ENV DOCKERBUILD 1

COPY etc/library.sh etc/nextcloudpi-config.d/nc-init.sh etc/nextcloudpi-config.d/nc-nextcloud.sh /usr/local/etc/

RUN \

# installation ( /var/www/nextcloud -> /data/app which will be in a volume )
apt-get update; \
apt-get install --no-install-recommends -y wget ca-certificates sudo; \
source /usr/local/etc/library.sh; \
set +x; \
install_script  /usr/local/etc/nc-nextcloud.sh; \
activate_script /usr/local/etc/nc-nextcloud.sh; \
mv /var/www/nextcloud /data/app; \
ln -s /data/app /var/www/nextcloud; \

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

COPY docker/nextcloud/020nextcloud /etc/services-enabled.d/
