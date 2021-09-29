#!/bin/bash

# Tag current commit, generate changelog and push to current branch
#
# Copyleft 2018 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
#
#  To install to an image using QEMU
#
#      ./tag_and_push.sh <tag>
#
# More at: https://ownyourbits.com
#

set -e

TAG="$@"
 
source build/buildlib.sh
git tag "$TAG"
generate_changelog
git add changelog.md
git commit -C HEAD --amend
git tag -f "$TAG"
git push origin HEAD --tags

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
