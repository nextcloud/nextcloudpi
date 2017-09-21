# docker build . -f Dockerfile.raspbian -t ownyourbits/raspbian:latest

FROM ownyourbits/miniraspbian:raw

MAINTAINER Ignacio Núñez Hernanz <nacho@ownyourbits.com>

CMD /bin/bash

RUN mkdir -p /etc/cont-init.d

COPY docker/miniraspbian/run-parts.sh /
