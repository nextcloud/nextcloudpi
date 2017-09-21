# docker run -d -p 4443:4443 -p 443:443 -p 80:80 -v ncdata:/data --name nextcloudpi ownyourbits/nextcloudpi
# docker build . -f nextcloud.dockerfile -t ownyourbits/nextcloudpi:latest

FROM ownyourbits/nextcloudpi

MAINTAINER Ignacio Núñez Hernanz <nacho@ownyourbits.com>

SHELL ["/bin/bash", "-c"]

ENV DOCKERBUILD 1

COPY nextcloudpi.sh /usr/local/etc/

RUN \
apt-get update; \
apt-get install --no-install-recommends -y wget ca-certificates; \
      
# install nextcloudpi
source /usr/local/etc/library.sh; \
set +x; \
cd /usr/local/etc/; \
install_script nextcloudpi.sh; \

# specific cleanup
rm /usr/local/etc/nextcloudpi.sh; \
apt-get purge -y wget ca-certificates; \

# package clean up
apt-get autoremove -y; \
apt-get clean; \
rm -f /var/lib/apt/lists/*; \
rm -rf /usr/share/man/*; \
rm -rf /usr/share/doc/*; \
rm -f /var/log/alternatives.log /var/log/apt/*; \
rm /var/cache/debconf/*-old; 

COPY docker/nextcloudpi/000-ncp-run.sh /etc/cont-init.d/

# 4443 - ncp-web
EXPOSE 80 443 4443
