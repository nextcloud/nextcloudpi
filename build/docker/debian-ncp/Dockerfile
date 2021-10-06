ARG arch=armhf
ARG arch_qemu=arm
ARG release=buster
FROM debian:${release}-slim AS qemu

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends qemu-user-static

ARG release
ARG arch_qemu
FROM ${arch}/debian:${release}-slim

ARG arch_qemu

LABEL maintainer="Ignacio Núñez Hernanz <nacho@ownyourbits.com>"

CMD /bin/bash

COPY --from=qemu /usr/bin/qemu-${arch_qemu}-static /usr/bin/

RUN mkdir -p /etc/services-available.d  /etc/services-enabled.d

COPY build/docker/debian-ncp/run-parts.sh /
