#!/bin/bash

# Launch security audit reports for NextCloudPi
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh nc-audit.sh <IP> (<img>)
#
# See installer.sh instructions for details
#
# More at https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/
#

DESCRIPTION="Perform a security audit with lynis and debsecan"

install()
{
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    lynis debian-goodies needrestart debsums debsecan
  cp /etc/lynis/default.prf /etc/lynis/ncp.prf
  cat >> /etc/lynis/ncp.prf <<EOF
# Won't install apt-listbugs and all its ruby dependencies
skip-test=CUST-0810

# Won't install puppet or similar
skip-test=TOOL-5002

# Raspbian doesn't have security sources ( https://www.raspberrypi.org/forums/viewtopic.php?t=98006&p=680175 ) 
skip-test=PKGS-7388

# We have a preset partition scheme in the SD card
skip-test=FILE-6310

# We don't use firewire
skip-test=STRG-1846

# We use USB in NCP
skip-test=STRG-1840

# Won't recompile kernel to support auditd
skip-test=ACCT-9628

# Won't be protected against DDOS in self-hosting, will save the resources
skip-test=HTTP-6640
skip-test=HTTP-6641

# False positive about mysql root password ( https://github.com/CISOfy/lynis/issues/288 )
skip-test=DBS-1816

# vmlinuz missing at least in Raspbian
skip-test=KRNL-5788

# won't recompile kernels for PAE NX
skip-test=KRNL-5677

# false positive with DNS settings. We use mDNS and dnsmasq (and they work)
skip-test=NAME-4028

# false positive due to fail2ban
skip-test=FIRE-4513
EOF
}

configure()
{
  echo "General security audit"
  lynis audit system --profile /etc/lynis/ncp.prf --no-colors

  echo "Known vulnerabilities in this system"
  debsecan
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

