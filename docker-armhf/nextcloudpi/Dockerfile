FROM ownyourbits/nextcloud-armhf

MAINTAINER Ignacio Núñez Hernanz <nacho@ownyourbits.com>

SHELL ["/bin/bash", "-c"]

ENV DOCKERBUILD 1

COPY nextcloudpi.sh /usr/local/etc/

RUN \
# mark as image build
touch /.ncp-image; \

apt-get update; \
apt-get install --no-install-recommends -y wget ca-certificates; \
      
# install nextcloudpi
source /usr/local/etc/library.sh; \
set +x; \
cd /usr/local/etc/; \
install_script nextcloudpi.sh; \

# fix default paths
sed -i 's|/media/USBdrive|/data/backups|' nextcloudpi-config.d/nc-backup.sh; \

# specific cleanup
rm /usr/local/etc/nextcloudpi.sh; \
rm /.ncp-image; \

# remove wizard for now
rm -r /var/www/ncp-web/wizard; \

# cleanup all NCP extras
source /usr/local/etc/library.sh; \
cd /usr/local/etc/nextcloudpi-config.d/; \
for script in *.sh; do cleanup_script $script done; \

# package clean up
apt-get autoremove -y; \
apt-get clean; \
rm -f /var/lib/apt/lists/*; \
rm -rf /usr/share/man/*; \
rm -rf /usr/share/doc/*; \
rm -f /var/log/alternatives.log /var/log/apt/*; \
rm /var/cache/debconf/*-old; 

COPY docker/nextcloudpi/000ncp /etc/services-enabled.d/

# 4443 - ncp-web
EXPOSE 80 443 4443
