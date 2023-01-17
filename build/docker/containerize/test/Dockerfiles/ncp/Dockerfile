# syntax=docker/dockerfile:1
# --mount=type=cache,target=/usr/local/bin,sharing=shared 
FROM alpine:3.16.2 AS builder
WORKDIR /workdir
RUN apk update && apk add --no-cache git==2.36.2-r0
RUN git clone https://github.com/nextcloud/nextcloudpi.git
WORKDIR /workdir/nextcloudpi
RUN mkdir -p /mnt/nextcloudpi; cp -R bin etc updates ncp-app ncp-web ncp-activation tests ncp-previewgenerator ncp.sh lamp.sh post-inst.sh update.sh /mnt/nextcloudpi
VOLUME /mnt/nextcloudpi

FROM debian:bullseye-slim AS base
COPY --from=builder --link ["/mnt/nextcloudpi","/mnt/nextcloudpi"]
VOLUME /mnt/nextcloudpi
USER root
