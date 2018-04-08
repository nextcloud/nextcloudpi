FROM ownyourbits/lamp-armhf

MAINTAINER Ignacio Núñez Hernanz <nacho@ownyourbits.com>

SHELL ["/bin/bash", "-c"]

ENV DOCKERBUILD 1

COPY etc/library.sh /usr/local/etc/
COPY etc/nextcloudpi-config.d/nc-init.sh etc/nextcloudpi-config.d/nc-nextcloud.sh /

RUN \

# installation ( /var/www/nextcloud -> /data/app which will be in a volume )
apt-get update; \
apt-get install --no-install-recommends -y wget ca-certificates sudo; \
source /usr/local/etc/library.sh; \
set +x; \
install_script  /nc-nextcloud.sh; \
activate_script /nc-nextcloud.sh; \
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
rm /nc-nextcloud.sh; \
sed -i -E "s/^requirepass .*/requirepass default/" /etc/redis/redis.conf; \
echo -e "[client]\npassword=default" > /root/.my.cnf; \
chmod 600 /root/.my.cnf

COPY docker-common/nextcloud/020nextcloud /etc/services-enabled.d/
COPY bin/ncp-provisioning.sh /usr/local/bin/
