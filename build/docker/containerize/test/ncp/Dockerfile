# syntax=docker/dockerfile:1
# FROM bitnami/git:latest AS git
# RUN --mount=type=cache,target=/usr/local/bin,sharing=shared git clone https://github.com/nextcloud/nextcloudpi.git --branch master --single-branch --depth 1 ncp; \
# mkdir -p /mnt/nextcloudpi; \
# cp -R ncp/bin ncp/etc ncp/updates ncp/ncp-app ncp/ncp-web ncp/ncp-activation ncp/tests ncp/ncp-previewgenerator ncp/ncp.sh ncp/lamp.sh ncp/post-inst.sh ncp/update.sh /mnt/nextcloudpi; \
# rm -R ncp
FROM alpine:3.16.2 AS builder
WORKDIR /workdir
RUN apk update && apk add --no-cache git==2.36.2-r0
RUN git clone https://github.com/nextcloud/nextcloudpi.git
WORKDIR /workdir/nextcloudpi
RUN mkdir -p /mnt/nextcloudpi; cp -R bin etc updates ncp-app ncp-web ncp-activation tests ncp-previewgenerator ncp.sh lamp.sh post-inst.sh update.sh /mnt/nextcloudpi
VOLUME /mnt/nextcloudpi

#--chown=ncp:ncp
#FROM --platform=$BUILDPLATFORM debian:bullseye-slim AS base
#FROM nextcloud/all-in-one:latest AS base
FROM debian:bullseye-slim AS base
#COPY --from=nextcloud/all-in-one:latest --link ["/mnt/docker-aio-config","/mnt/docker-aio-config"]
#COPY --from=nextcloud/all-in-one:latest --link ["/var/www/*","/var/www/"]
#COPY --from=bash:latest --link ["/usr/local/bin/bash","/usr/local/bin/"]
COPY --from=builder --link ["/mnt/nextcloudpi","/mnt/nextcloudpi"]
VOLUME /mnt/nextcloudpi
USER root
