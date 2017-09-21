FROM ownyourbits/debian-ncp-armhf

MAINTAINER Ignacio Núñez Hernanz <nacho@ownyourbits.com>

SHELL ["/bin/bash", "-c"]

ENV DOCKERBUILD 1

COPY etc/library.sh lamp.sh /usr/local/etc/

RUN \

# installation
source /usr/local/etc/library.sh; \
set +x; \
install_script /usr/local/etc/lamp.sh; \

# mariaDB fixups (move database to /data, which will be in a persistent volume)
mkdir -p /data/; \
mv /var/lib/mysql /data/database; \
sed -i "s|^datadir.*|datadir = /data/database|" /etc/mysql/mariadb.conf.d/50-server.cnf; \

# package cleanup 
apt-get autoremove -y; \
apt-get clean; \
rm /var/lib/apt/lists/* -f; \
rm -rf /usr/share/man/*; \
rm -rf /usr/share/doc/*; \
rm /var/cache/debconf/*-old; \
rm -f /var/log/alternatives.log /var/log/apt/*; \

# specific cleanup
rm /data/database/ib_logfile*; \
rm /usr/local/etc/lamp.sh

COPY docker/lamp/010-lamp-run.sh /etc/services.d/

ENTRYPOINT ["/run-parts.sh"]

EXPOSE 80 443
