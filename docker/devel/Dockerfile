FROM ownyourbits/nextcloudpi-x86

MAINTAINER Ignacio Núñez Hernanz <nacho@ownyourbits.com>

SHELL ["/bin/bash", "-c"]

ENV DOCKERBUILD 1

COPY build-devel.sh /usr/local/etc/

RUN \
apt-get update; \
apt-get install --no-install-recommends -y wget ca-certificates git; \

# install nextcloudpi devel
source /usr/local/etc/library.sh; \
set +x; \
cd /usr/local/etc/; \
install_script build-devel.sh; \

# specific cleanup
rm /usr/local/etc/build-devel.sh; \
apt-get purge -y wget ca-certificates git; \

# package clean up
apt-get autoremove -y; \
apt-get clean; \
rm -f /var/lib/apt/lists/*; \
rm -rf /usr/share/man/*; \
rm -rf /usr/share/doc/*; \
rm -f /var/log/alternatives.log /var/log/apt/*; \
rm /var/cache/debconf/*-old; 
