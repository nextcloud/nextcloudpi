#!/bin/bash

# modsecurity WAF installation on Raspbian 
# Tested with 2017-03-02-raspbian-jessie-lite.img
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh modsecurity.sh <IP> (<img>)
#
# See installer.sh instructions for details
#
# More at ownyourbits.com
#

ACTIVE_=no
NCDIR_=/var/www/nextcloud/
DESCRIPTION="Web Application Firewall for extra security (experimental)"

install()
{
  apt-get update
  apt-get install -y --no-install-recommends libapache2-mod-security2 modsecurity-crs

  # COPY RULES
  cd /usr/share/modsecurity-crs/base_rules/
  for ruleFile in * ; do sudo ln -s /usr/share/modsecurity-crs/base_rules/$ruleFile /etc/modsecurity/$ruleFile ; done
  cd /usr/share/modsecurity-crs/optional_rules/
  for ruleFile in * ; do sudo ln -s /usr/share/modsecurity-crs/optional_rules/$ruleFile /etc/modsecurity/$ruleFile ; done
  rm /etc/modsecurity/modsecurity_crs_16_session_hijacking.conf # https://github.com/SpiderLabs/owasp-modsecurity-crs/commit/e2fbef4ce89fed0c4dd338002b9a090dd2f6491d

  # CONFIGURE
  cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf
  sed -i 's|SecTmpDir .*|SecTmpDir   /var/cache/modsecurity/|' /etc/modsecurity/modsecurity.conf
  sed -i 's|SecDataDir .*|SecDataDir /var/cache/modsecurity/|' /etc/modsecurity/modsecurity.conf

  cp /usr/share/modsecurity-crs/modsecurity_crs_10_setup.conf /etc/modsecurity/modsecurity_crs_10_setup.conf
  patch /etc/modsecurity/modsecurity_crs_10_setup.conf <<<'66,67c66
< SecDefaultAction "phase:1,deny,log"
< SecDefaultAction "phase:2,deny,log"
---
> SecDefaultAction "phase:2,pass,log"
152c151
< #SecAction \
---
> SecAction \
278c277
<   setvar:'\''tx.allowed_methods=GET HEAD POST OPTIONS'\'', \
---
>   setvar:'\''tx.allowed_methods=GET HEAD POST OPTIONS PROPFIND'\'', \
280c279
<   setvar:'\''tx.allowed_http_versions=HTTP/0.9 HTTP/1.0 HTTP/1.1'\'', \
---
>   setvar:'\''tx.allowed_http_versions=HTTP/1.1 HTTP/2.0'\'', \'

cat >> /etc/modsecurity/modsecurity_crs_99_whitelist.conf <<EOF
<Directory $NCDIR_>
  # VIDEOS
  SecRuleRemoveById 958291             # Range Header Checks
  SecRuleRemoveById 981203             # Correlated Attack Attempt

  # PDF
  SecRuleRemoveById 950109             # Check URL encodings

  # ADMIN (webdav)
  SecRuleRemoveById 960024             # Repeatative Non-Word Chars (heuristic)
  SecRuleRemoveById 981173             # SQL Injection Character Anomaly Usage
  SecRuleRemoveById 981204             # Correlated Attack Attempt
  SecRuleRemoveById 981243             # PHPIDS - Converted SQLI Filters
  SecRuleRemoveById 981245             # PHPIDS - Converted SQLI Filters
  SecRuleRemoveById 981246             # PHPIDS - Converted SQLI Filters
  SecRuleRemoveById 981318             # String Termination/Statement Ending Injection Testing
  SecRuleRemoveById 973332             # XSS Filters from IE
  SecRuleRemoveById 973338             # XSS Filters - Category 3
  SecRuleRemoveById 981143             # CSRF Protections ( TODO edit LocationMatch filter )

  # COMING BACK FROM OLD SESSION
  SecRuleRemoveById 970903             # Microsoft Office document properties leakage
</Directory>
EOF
  cat >> /etc/apache2/apache2.conf <<EOF
<IfModule mod_security2.c>
  SecServerSignature " "
</IfModule>
EOF
}

configure() 
{ 
  [[ $ACTIVE_ == "yes" ]] && local STATE=On || local STATE=Off
  sed -i "s|SecRuleEngine .*|SecRuleEngine $STATE|" /etc/modsecurity/modsecurity.conf
  service apache2 restart
}

cleanup()
{
  apt-get autoremove -y
  apt-get clean
  rm /var/lib/apt/lists/* -r
  rm -f /home/pi/.bash_history
  systemctl disable ssh
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

