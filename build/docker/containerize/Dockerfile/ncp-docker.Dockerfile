# syntax=docker.io/dockerfile:1 
ARG OWNER ["nextcloud"]
ARG REPO ["nextcloudpi"]
ARG PATH ["bin/ncp"]
ARG CATEGORY ["BACKUPS"]
ARG SCRIPT ["nc-autobackup.sh"]
ARG URL ["https://raw.githubusercontent.com"]
FROM --platform=$BUILDPLATFORM bash:latest AS bash
ARG OWNER
ARG REPO 
ARG PATH 
ARG URL 
ARG CATEGORY
ARG SCRIPT 
ADD ${URL}/${OWNER}/${REPO}/${PATH}/${CATEGORY}/${SCRIPT} ${PATH}/${CATEGORY}/${SCRIPT}
