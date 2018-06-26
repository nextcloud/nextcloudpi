FROM arm32v7/debian:stretch-slim

MAINTAINER Ignacio Núñez Hernanz <nacho@ownyourbits.com>

CMD /bin/bash

COPY qemu-arm-static /usr/bin

RUN mkdir -p /etc/services-available.d  /etc/services-enabled.d

COPY docker-common/debian-ncp/run-parts.sh /
