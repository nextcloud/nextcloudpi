# syntax=docker.io/dockerfile:1
ARG PATH_BASH ["/usr/local/bin/bash"]
FROM --platform=$BUILDPLATFORM bash:latest AS bash
ARG PATH_BASH 
CMD ["$PATH_BASH","-c"]
COPY ["/","/"]

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
ADD ["${URL}/${OWNER}/${REPO}/${BRANCH}/${PATH}/${CATEGORY}/${SCRIPT}", "${PATH}/${CATEGORY}/${SCRIPT}"]
COPY --from=bash ["$PATH_BASH", "$PATH_BASH"]
RUN ["$PATH_BASH","-c","chmod","+x","${PATH}/${CATEGORY}/${SCRIPT}"]
SHELL ["$PATH_BASH"]
ENTRYPOINT ["$PATH_BASH","-c","${PATH}/${CATEGORY}/${SCRIPT}"]
