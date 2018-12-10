FROM ownyourbits/lamp-armhf

MAINTAINER Ignacio Núñez Hernanz <nacho@ownyourbits.com>

SHELL ["/bin/bash", "-c"]

ENV DOCKERBUILD 1

COPY etc/library.sh /usr/local/etc/
COPY bin/ncp/CONFIG/nc-nextcloud.sh /
COPY etc/ncp-config.d/nc-nextcloud.cfg /usr/local/etc/ncp-config.d/

RUN \

# mark as image build
touch /.ncp-image; \

# installation ( /var/www/nextcloud -> /data/app which will be in a volume )
apt-get update; \
apt-get install --no-install-recommends -y wget ca-certificates sudo jq; \
source /usr/local/etc/library.sh; \
set +x; \
install_app /nc-nextcloud.sh; \
run_app_unsafe /nc-nextcloud.sh; \
mv /var/www/nextcloud /data-ro/app; \
ln -s /data-ro/app /var/www/nextcloud; \

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

COPY docker-common/nextcloud/020nextcloud /etc/services-enabled.d/
COPY bin/ncp-provisioning.sh /usr/local/bin/

# display message until first run initialization is complete
COPY docker-common/nextcloud/ncp-wait-msg.html /data-ro/app
RUN \
mv /data-ro/app/index.php /; \
mv /data-ro/app/ncp-wait-msg.html /data-ro/app/index.php;
