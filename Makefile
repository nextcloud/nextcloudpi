# Batch-build docker container layers for nextcloudpi
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#


nextcloudpi-armhf: nextcloud-armhf
	docker build . -f docker-armhf/nextcloudpi/Dockerfile   -t ownyourbits/nextcloudpi-armhf:latest

nextcloud-armhf: lamp-armhf
	docker build . -f docker-armhf/nextcloud/Dockerfile     -t ownyourbits/nextcloud-armhf:latest

lamp-armhf: debian-ncp-armhf
	docker build . -f docker-armhf/lamp/Dockerfile          -t ownyourbits/lamp-armhf:latest

debian-ncp-armhf:
	docker build . -f docker-armhf/debian-ncp/Dockerfile  -t ownyourbits/debian-ncp-armhf:latest


nextcloudpi-x86: nextcloud-x86
	docker build . -f docker/nextcloudpi/Dockerfile       -t ownyourbits/nextcloudpi-x86:latest

nextcloud-x86: lamp-x86
	docker build . -f docker/nextcloud/Dockerfile         -t ownyourbits/nextcloud-x86:latest

lamp-x86: debian-ncp-x86
	docker build . -f docker/lamp/Dockerfile           -t ownyourbits/lamp-x86:latest

debian-ncp-x86: 
	docker build . -f docker/debian-ncp/Dockerfile   -t ownyourbits/debian-ncp-x86:latest

devel: 
	docker build . -f docker/devel/Dockerfile   -t ownyourbits/nextcloudpi-x86:devel

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
