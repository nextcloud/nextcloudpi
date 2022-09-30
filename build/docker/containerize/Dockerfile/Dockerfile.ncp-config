# syntax=docker.io/dockerfile:1 
FROM bash:latest AS bash
COPY --from=bash / /
ADD https://raw.githubusercontent.com/nextcloud/nextcloudpi/master/bin/ncp-config 
SHELL ["/usr/local/bin/bash"]
CMD ["/usr/local/bin/bash","-c"]
ENTRYPOINT ["/usr/local/bin/bash","-c"]
