# Batch-build docker container layers for nextcloudpi
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#


nextcloudpi: nextcloud
	docker build . -f docker/nextcloudpi/Dockerfile       -t ownyourbits/nextcloudpi:latest

nextcloud: lamp
	docker build . -f docker/nextcloud/Dockerfile         -t ownyourbits/nextcloud:latest

lamp: miniraspbian
	docker build . -f docker/lamp/Dockerfile           -t ownyourbits/lamp-arm:latest

miniraspbian: 
	docker build . -f docker/miniraspbian/Dockerfile   -t ownyourbits/miniraspbian:latest

devel: 
	docker build . -f docker/devel/Dockerfile   -t ownyourbits/nextcloudpi:devel
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
