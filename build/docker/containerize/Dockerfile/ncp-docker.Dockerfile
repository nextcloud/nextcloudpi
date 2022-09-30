# syntax=docker.io/dockerfile:1 
FROM --platform=$BUILDPLATFORM bash:latest AS bash

ARG OWNER ["nextcloud"]
ARG REPO ["nextcloudpi"]
ARG BRANCH ["master"]
ARG PATH ["bin/ncp"]
ARG CATEGORY ["BACKUPS"]
ARG SCRIPT ["nc-backup-auto.sh"]
ARG URL ["https://raw.githubusercontent.com"]
ARG PATH_BASH ["/usr/local/bin/bash"]
FROM --platform=$BUILDPLATFORM ["scratch"]
ARG OWNER
ARG REPO 
ARG BRANCH 
ARG PATH 
ARG URL 
ARG CATEGORY
ARG SCRIPT 
ARG PATH_BASH 
ADD ["${URL}/${OWNER}/${REPO}/${PATH}/${CATEGORY}/${SCRIPT}", "${PATH}/${CATEGORY}/${SCRIPT}"]
COPY --from=bash ["$PATH_BASH", "$PATH_BASH"]
SHELL ["$PATH_BASH"]
CMD ["$PATH_BASH","-c"]
ENTRYPOINT ["$PATH_BASH","-c","${PATH}/${CATEGORY}/${SCRIPT"]
