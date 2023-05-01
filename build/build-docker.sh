# Batch-build docker container layers for NextCloudPi
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#

set -e

source build/buildlib.sh
release=$(jq -r .release < etc/ncp.cfg)

function docker_build() { DOCKER_BUILDKIT=1 docker build --progress=plain . "$@"; }

build_arch() {
  local target="${1?}"
  local release="${2?}"
  local arch="${3?}"
  local arch_qemu="${4?}"
  local suffix="${5:-$arch}"

  echo -e "\e[1m\n[ Build NCP Docker ${arch} ]\e[0m"
  version="${version?}"
  DOCKER_BUILDKIT=1 docker build --pull --progress=plain . -f build/docker/Dockerfile \
    --target "$target" -t "ownyourbits/$target-${suffix}:latest" \
    --cache-from "ownyourbits/nextcloudpi-${suffix}" --build-arg "release=$release" --build-arg "arch=${arch}" \
    --build-arg "arch_qemu=$arch_qemu" --build-arg "ncp_ver=${version#docker-}"

  docker tag "ownyourbits/${target}-${suffix}:latest" "ownyourbits/${target}-${suffix}:${version#docker-}"
}

get_arch_args() {
  # 1) arch 2) arch_qemu 3) suffix

  [[ "${1?}" =~ "x86"   ]] && { echo "amd64 x86_64 x86"; return 0; }
  [[ "$1" =~ "armhf" ]] && { echo "arm32v7 arm armhf"; return 0; }
  [[ "$1" =~ "arm64" ]] && { echo "arm64v8 aarch64 arm64"; return 0; }

  echo -e "Unsupported architecture: '${arch}'!"
  return 1
}

clean_workspace() {
  # make sure we don't accidentally include this
  rm -f ncp-web/wizard.cfg
}

# Only execute script if not sourced
[[ "${BASH_SOURCE[0]}" == "$0" ]] && {
  arch="${1?Missing argument: target architecture}"

  shopt -s lastpipe
  get_arch_args "$arch" | read -r -a arch_args

  # Pull latest image for caching
  docker pull ownyourbits/nextcloudpi
  for target in nextcloudpi debian-ncp lamp nextcloud ncp-qemu-fix
  do
    build_arch "$target" "${release}" "${arch_args[@]}"
  done

  exit 0
}

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
