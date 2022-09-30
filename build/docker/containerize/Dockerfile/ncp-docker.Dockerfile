# syntax=docker.io/dockerfile:1 
ARG OWNER nextcloud
ARG REPO nextcloudpi
ARG PATH /bin/ncp
ARG URL https://raw.githubusercontent.com/
FROM --platform=$BUILDPLATFORM bash:latest AS bash
ARG OWNER
ARG REPO 
ARG PATH 
ARG URL 
