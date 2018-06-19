FROM ownyourbits/lamp-x86

MAINTAINER Ignacio Núñez Hernanz <nacho@ownyourbits.com>

SHELL ["/bin/bash", "-c"]

ENV DOCKERBUILD 1

COPY etc/library.sh /usr/local/etc/
COPY etc/ncp-config.d/nc-init.sh etc/ncp-config.d/nc-nextcloud.sh /

RUN \

# mark as image build
touch /.ncp-image; \

# installation ( /var/www/nextcloud -> /data/app which will be in a volume )
apt-get update; \
apt-get install --no-install-recommends -y wget ca-certificates sudo; \
source /usr/local/etc/library.sh; \
set +x; \
install_script  /nc-nextcloud.sh; \
activate_script /nc-nextcloud.sh; \
mv /var/www/nextcloud /data-ro/app; \
ln -s /data-ro/app /var/www/nextcloud; \

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
rm /nc-nextcloud.sh; \
rm /.ncp-image; 

COPY docker-common/nextcloud/020nextcloud /etc/services-enabled.d/
COPY bin/ncp-provisioning.sh /usr/local/bin/

# display message until first run initialization is complete
COPY docker-common/nextcloud/ncp-wait-msg.html /data-ro/app
RUN \
mv /data-ro/app/index.php /; \
mv /data-ro/app/ncp-wait-msg.html /data-ro/app/index.php;
