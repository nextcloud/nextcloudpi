# Batch-build docker container layers for NextCloudPi
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#

set -e

version=$(git describe --tags --always)
version=${version%-*-*}
release=$(jq -r .release < etc/ncp.cfg)

function docker_build() { DOCKER_BUILDKIT=1 docker build --progress=plain . "$@"; }

function build_arch()
{
  local release="${1}"
  local arch="${2}"
  local arch_qemu="${3}"
  local ncp_tag="${4:-$arch}"

  docker_build -f docker/debian-ncp/Dockerfile  -t ownyourbits/debian-ncp-${ncp_tag}:latest --pull --build-arg release=${release} --build-arg arch=${arch} --build-arg arch_qemu=${arch_qemu}
  docker_build -f docker/lamp/Dockerfile        -t ownyourbits/lamp-${ncp_tag}:latest              --build-arg release=${release} --build-arg arch=${ncp_tag}
  docker_build -f docker/nextcloud/Dockerfile   -t ownyourbits/nextcloud-${ncp_tag}:latest         --build-arg release=${release} --build-arg arch=${ncp_tag}
  docker_build -f docker/nextcloudpi/Dockerfile -t ownyourbits/nextcloudpi-${ncp_tag}:latest       --build-arg release=${release} --build-arg arch=${ncp_tag} --build-arg ncp_ver=${version}

  docker tag ownyourbits/debian-ncp-${ncp_tag}:latest ownyourbits/debian-ncp-${ncp_tag}:"${version}"
  docker tag ownyourbits/lamp-${ncp_tag}:latest ownyourbits/lamp-${ncp_tag}:"${version}"
  docker tag ownyourbits/nextcloud-${ncp_tag}:latest ownyourbits/nextcloud-${ncp_tag}:"${version}"
  docker tag ownyourbits/nextcloudpi-${ncp_tag}:latest ownyourbits/nextcloudpi-${ncp_tag}:"${version}"
}

# make sure we don't accidentally include this
rm -f ncp-web/wizard.cfg

[[ "$@" =~ "x86"   ]] && build_arch "${release}" amd64   x86_64  x86
[[ "$@" =~ "armhf" ]] && build_arch "${release}" arm32v7 arm     armhf
[[ "$@" =~ "arm64" ]] && build_arch "${release}" arm64v8 aarch64 arm64

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
