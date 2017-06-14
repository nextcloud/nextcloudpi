# docker run -d -p 443:443 -p 80:80 -v ncdata:/data --name nextcloudpi ownyourbits/nextcloudpi
# docker build . -f nextcloud.dockerfile -t ownyourbits/nextcloudpi:latest

FROM ownyourbits/lamp-arm

MAINTAINER Ignacio Núñez Hernanz <nacho@ownyourbits.com>

SHELL ["/bin/bash", "-c"]

COPY etc/library.sh etc/nextcloudpi-config.d/nc-init.sh etc/nextcloudpi-config.d/nc-nextcloud.sh /usr/local/etc/

RUN apt-get update; apt-get install --no-install-recommends -y wget ca-certificates; \
    source /usr/local/etc/library.sh; set +x; activate_script /usr/local/etc/nc-nextcloud.sh; \
    apt-get purge -y wget ca-certificates libgnutls-deb0-28 libhogweed2 libicu52 libnettle4 libpsl0; \
    apt-get autoremove -y; apt-get clean; rm /var/lib/apt/lists/* -f; rm -rf /usr/share/man/*; rm -rf /usr/share/doc/*; \
    rm /var/log/apt/* ; \
    rm /var/cache/debconf/*-old; \
    rm /usr/local/etc/nc-nextcloud.sh

COPY docker/run-nc.sh /usr/local/bin/run.sh
