#!/bin/bash

APTINSTALL="apt-get install -y --no-install-recommends"
export DEBIAN_FRONTEND=noninteractive

install() {
  apt-get update
  local pre_reqs=(apt-transport-https ca-certificates curl)
  command -v gpg || pre_reqs+=(gnupg)
  $APTINSTALL "${pre_reqs[@]}"
  local lsb_dist=debian
  test -f /usr/bin/raspi-config && lsb_dist=raspbian
  local dist_version=bullseye
  mkdir -p /etc/apt/keyrings && chmod -R 0755 /etc/apt/keyrings
  curl -fsSL "https://download.docker.com/linux/$lsb_dist/gpg" | gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$lsb_dist $dist_version stable" > /etc/apt/sources.list.d/docker.list
  apt-get update
  $APTINSTALL docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-ce-rootless-extras docker-buildx-plugin
}

configure() { :; }
