# syntax=docker/dockerfile:1
FROM --platform=$BUILDPLATFORM bitnami/git:latest AS git
RUN --mount=type=cache,target=/usr/local/bin,sharing=shared git clone https://github.com/nextcloud/nextcloudpi.git --branch master --single-branch --depth 1 ncp; \
mkdir -p /mnt/nextcloudpi; \
cp -R ncp/bin ncp/etc ncp/updates ncp/ncp-app ncp/ncp-web ncp/ncp-activation ncp/tests ncp/ncp-previewgenerator ncp/ncp.sh ncp/lamp.sh ncp/post-inst.sh ncp/update.sh /mnt/nextcloudpi; \
rm -R ncp


#--chown=ncp:ncp
#FROM --platform=$BUILDPLATFORM debian:bullseye-slim AS base
FROM --platform=$BUILDPLATFORM nextcloud/all-in-one:latest AS base
USER root
#COPY --from=nextcloud/all-in-one:latest --link ["/mnt/docker-aio-config","/mnt/docker-aio-config"]
#COPY --from=nextcloud/all-in-one:latest --link ["/var/www/*","/var/www/"]
COPY --from=bash:latest --link ["/usr/local/bin/bash","/usr/local/bin/"]
COPY --from=git --link ["/mnt/nextcloudpi","/mnt/nextcloudpi"]
VOLUME /mnt/nextcloudpi
ENTRYPOINT ["start.sh"]
CMD ["/usr/bin/supervisord", "-c", "/supervisord.conf"]

HEALTHCHECK CMD /healthcheck.sh
