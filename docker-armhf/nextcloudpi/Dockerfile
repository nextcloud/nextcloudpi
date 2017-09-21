FROM ownyourbits/nextcloud-armhf

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

# fix default paths
sed -i 's|/media/USBdrive|/data/backups|' nextcloudpi-config.d/nc-backup.sh; \

# specific cleanup
rm /usr/local/etc/nextcloudpi.sh; \
apt-get purge -y wget ca-certificates; \

# letsencrypt build artifacts cleanup
apt-get purge -y \
    make \
    git \
    augeas-lenses \
    binutils \
    cpp \
    cpp-6 \
    gcc \
    gcc-6 \
    libasan3 \
    libaugeas0 \
    libc-dev-bin \
    libc6-dev \
    libcc1-0 \
    libexpat1-dev \
    libffi-dev \
    libgcc-6-dev \
    libgomp1 \
    libisl15 \
    libmpc3 \
    libpython-dev \
    libpython2.7-dev \
    libssl-dev \
    libubsan0 \
    linux-libc-dev \
    python-dev \
    python-virtualenv \
    python2.7-dev \
    python-pkg-resources \
    python3-pkg-resources \
    python3-virtualenv \
    virtualenv \
    python-pip-whl; \

# package clean up
apt-get autoremove -y; \
apt-get clean; \
rm -f /var/lib/apt/lists/*; \
rm -rf /usr/share/man/*; \
rm -rf /usr/share/doc/*; \
rm -f /var/log/alternatives.log /var/log/apt/*; \
rm /var/cache/debconf/*-old; 

COPY docker/nextcloudpi/000-ncp-run.sh /etc/services.d/

# 4443 - ncp-web
EXPOSE 80 443 4443
