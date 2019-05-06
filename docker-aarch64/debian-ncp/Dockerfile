FROM arm64v8/debian:stretch-slim

MAINTAINER Ignacio Núñez Hernanz <nacho@ownyourbits.com>

CMD /bin/bash

COPY docker-aarch64/qemu-aarch64-static /usr/bin

RUN mkdir -p /etc/services-available.d  /etc/services-enabled.d

COPY docker-common/debian-ncp/run-parts.sh /
