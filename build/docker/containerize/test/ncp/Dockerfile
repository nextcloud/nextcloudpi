# syntax=docker/dockerfile:1
FROM --platform=$BUILDPLATFORM bitnami/git:latest AS git
WORKDIR /
RUN git clone https://github.com/nextcloud/nextcloudpi.git --branch master --single-branch --depth 1 ncp; \
mkdir -p ncp-tools; \
cp -R ncp/bin ncp/etc ncp/updates ncp/ncp-app ncp/ncp-web ncp/ncp-activation ncp/tests ncp/ncp-previewgenerator ncp/ncp.sh ncp/lamp.sh ncp/post-inst.sh ncp/update.sh ncp-tools/; \
rm -R ncp

# --chown=ncp:ncp
FROM --platform=$BUILDPLATFORM alpine:latest AS base
COPY --from=bash:latest --link ["/","/"]
COPY --from=git --link ["/ncp-tools","/usr/local/"]
SHELL ["/usr/local/bin/bash","-c"]
ENTRYPOINT ["bash"]
