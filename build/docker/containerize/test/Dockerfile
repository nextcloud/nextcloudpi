# syntax=docker/dockerfile:1

FROM --platform=$BUILDPLATFORM bitnami/git:latest AS git
RUN ["git clone https://github.com/nextcloud/nextcloudpi.git --branch master --single-branch --depth 1 ncp; \
mkdir -p ncp-tools; \
cp -R ncp/bin ncp/etc ncp/updates ncp/ncp-app ncp/ncp-web ncp/ncp-activation ncp/tests ncp/ncp-previewgenerator ncp/ncp.sh ncp/lamp.sh ncp/post-inst.sh ncp/update.sh ncp-tools/"]
