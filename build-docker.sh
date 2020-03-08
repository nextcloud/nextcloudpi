#!/usr/bin/env bash
# Batch-build docker container layers for NextCloudPi
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#

set -xe

version=$(git describe --tags --always)
version=${version%-*-*}
release=$(jq -r .release < etc/ncp.cfg)
registry=${2:-ownyourbits}
# if the 2nd parameter starts with '--' it's not the docker registry
[[ "$registry" =~ --* ]] && registry="ownyourbits"

function show_help() {
  echo "USAGE: build-docker.sh arch [registry] [options]"
  echo ""
  echo "  arch:     The target architecture for the docker images (one of x86, armhf arm64)"
  echo "  registry: The docker registry to use for building and publishing (images will be named registry/image-name:tag)"
  echo ""
  echo "  OPTIONS:"
  echo "    --help Show this message"
  echo "    --push Push images after building"
}

function docker_build() { DOCKER_BUILDKIT=1 docker build --progress=plain . "$@"; }

function build_arch()
{
  local release="${1}"
  local arch="${2}"
  local arch_qemu="${3}"
  local ncp_tag="${4:-$arch}"

  docker_build -f docker/debian-ncp/Dockerfile  -t "${registry}/debian-ncp-${ncp_tag}:latest" --pull --build-arg "release=${release}" --build-arg "arch=${arch}" --build-arg "arch_qemu=${arch_qemu}"
  docker_build -f docker/lamp/Dockerfile        -t "${registry}/lamp-${ncp_tag}:latest"              --build-arg "release=${release}" --build-arg "arch=${ncp_tag}"
  docker_build -f docker/nextcloud/Dockerfile   -t "${registry}/nextcloud-${ncp_tag}:latest"         --build-arg "release=${release}" --build-arg "arch=${ncp_tag}"
  docker_build -f docker/nextcloudpi/Dockerfile -t "${registry}/nextcloudpi-${ncp_tag}:latest"       --build-arg "release=${release}" --build-arg "arch=${ncp_tag}" --build-arg "ncp_ver=${version}"

  docker tag "${registry}/debian-ncp-${ncp_tag}:latest" "${registry}/debian-ncp-${ncp_tag}:${version}"
  docker tag "${registry}/lamp-${ncp_tag}:latest" "${registry}/lamp-${ncp_tag}:${version}"
  docker tag "${registry}/nextcloud-${ncp_tag}:latest" "${registry}/nextcloud-${ncp_tag}:${version}"
  docker tag "${registry}/nextcloudpi-${ncp_tag}:latest" "${registry}/nextcloudpi-${ncp_tag}:${version}"

}

function push_arch() {
  local suffix="${1}"

  docker push "${registry}/debian-ncp-${suffix}"
  docker push "${registry}/lamp-${suffix}"
  docker push "${registry}/nextcloud-${suffix}"
  docker push "${registry}/nextcloudpi-${suffix}"
}

[[ "$@" =~ "--help" ]] && show_help && exit 0

[[ "${1}" == "x86"   ]] && build_arch "${release}" amd64   x86_64  x86   && [[ "$@" =~ "--push" ]] && push_arch "x86"
[[ "${1}" == "armhf" ]] && build_arch "${release}" arm32v7 arm     armhf && [[ "$@" =~ "--push" ]] && push_arch "armhf"
[[ "${1}" == "arm64" ]] && build_arch "${release}" arm64v8 aarch64 arm64 && [[ "$@" =~ "--push" ]] && push_arch "arm64"

exit 0

# License
#
# This script is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This script is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this script; if not, write to the
# Free Software Foundation, Inc., 59 Temple Place, Suite 330,
# Boston, MA  02111-1307  USA
