# syntax=docker/dockerfile:1
# --platform=$BUILDPLATFORM 
# --platform=$TARGETPLATFORM
ARG DEBIAN_FRONTEND=noninteractive
FROM debian:bullseye-slim AS systemd
ARG DEBIAN_FRONTEND
ENV DOCKERBUILD 1
# ARG BUILDPLATFORM
# --mount=type=cache,target=/var/cache/apt,sharing=private 
RUN --mount=type=cache,target=/var/cache/apt,sharing=private ["/bin/bash", "-c", "apt-get update -qq -y; apt-get install -y -qq --no-install-recommends systemd; rm -rf /var/lib/apt/lists/*;"]
CMD ["/usr/sbin/init"]

ARG DEBIAN_FRONTEND=noninteractive
FROM systemd AS ncp
ARG DEBIAN_FRONTEND
# ARG TARGETPLATFORM
ENV DOCKERBUILD 1
ENV DBADMIN ncadmin
ENV ADMINUSER ncp
ENV ADMINPASS ownyourbits
# COPY --from=qemu /usr/bin/qemu-aarch64-static /usr/bin/
RUN ["/bin/bash", "-c", "mkdir -p /etc/services-available.d /etc/services-enabled.d /tmp/ncp-build /data-ro /data"]
COPY ./install.sh /
COPY ./run-parts.sh /
COPY ./010lamp /etc/services-enabled.d/
COPY ./020nextcloud /etc/services-enabled.d/
COPY ./000ncp /etc/services-enabled.d/
# RUN --mount=type=cache,target=/var/cache/apt apt-get update -qq -y && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends bash && rm -rf /var/lib/apt/lists/*
RUN --mount=type=cache,target=/var/cache/apt,sharing=private ["/bin/bash", "-c", "/install.sh; rm -rf /var/lib/apt/lists/* && rm /install.sh"]
SHELL ["/bin/bash", "-c"]
CMD ["/bin/bash", "-c"]
EXPOSE 80 443
ENTRYPOINT ["/run-parts.sh"]
