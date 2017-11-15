FROM debian:stretch-slim

MAINTAINER Ignacio Núñez Hernanz <nacho@ownyourbits.com>

CMD /bin/bash

RUN mkdir -p /etc/services-available.d  /etc/services-enabled.d

COPY docker/debian-ncp/run-parts.sh /
