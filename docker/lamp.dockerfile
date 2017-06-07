# docker run -d -p 443:443 -p 80:80 -v ncdata:/data --name lamp ownyourbits/lamp
# docker build . -f lamp.dockerfile -t ownyourbits/lamp-arm:latest

FROM ownyourbits/miniraspbian

MAINTAINER Ignacio Núñez Hernanz <nacho@ownyourbits.com>

SHELL ["/bin/bash", "-c"]

COPY etc/library.sh lamp.sh /usr/local/etc/

# NOTE: move database to /data, which will be in a persistent volume
RUN source /usr/local/etc/library.sh; set +x; install_script /usr/local/etc/lamp.sh; \
     apt-get autoremove -y; apt-get clean; rm /var/lib/apt/lists/* -f; rm -rf /usr/share/man/*; rm -rf /usr/share/doc/*; \
     mkdir -p /data/; \
     mv /var/lib/mysql /data/database; \
     sed -i "s|^datadir.*|datadir = /data/database|" /etc/mysql/mariadb.conf.d/50-server.cnf; \
     rm /data/database/ib_logfile*; \
     rm /var/cache/debconf/*-old; \
     rm /var/log/alternatives.log /var/log/apt/* ; \
     rm /usr/local/etc/{lamp.sh,library.sh}

COPY docker/run-lamp.sh /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/run.sh"]

EXPOSE 80 443
