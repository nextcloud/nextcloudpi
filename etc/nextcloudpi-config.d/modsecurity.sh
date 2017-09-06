#!/bin/bash

# modsecurity WAF installation on Raspbian 
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
NCDIR=/var/www/nextcloud/
NCPWB=/var/www/ncp-web/
DESCRIPTION="Web Application Firewall for extra security (experimental)"

install()
{
  apt-get update
  apt-get install -y --no-install-recommends libapache2-mod-security2 modsecurity-crs
  a2dismod security2

  cat >> /etc/modsecurity/crs/crs-setup.conf <<'EOF'

  # NextCloudPi: allow PROPFIND for webDAV
  SecAction "id:900200, phase:1, nolog, pass, t:none, setvar:'tx.allowed_methods=GET HEAD POST OPTIONS PROPFIND'"
EOF

  # CONFIGURE
  cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf
  sed -i "s|SecRuleEngine .*|SecRuleEngine Off|"               /etc/modsecurity/modsecurity.conf
  sed -i 's|SecTmpDir .*|SecTmpDir   /var/cache/modsecurity/|' /etc/modsecurity/modsecurity.conf
  sed -i 's|SecDataDir .*|SecDataDir /var/cache/modsecurity/|' /etc/modsecurity/modsecurity.conf

  cat >> /etc/apache2/apache2.conf <<EOF
<IfModule mod_security2.c>
  SecServerSignature " "
</IfModule>
EOF
}

show_info()
{
  whiptail --yesno \
           --backtitle "NextCloudPi configuration" \
           --title "Experimental feature warning" \
"This feature is highly experimental and has only been tested with
a basic NextCloud installation. If a new App does not work disable it" \
  20 90
}

configure() 
{ 
  cat > /etc/modsecurity/modsecurity_crs_99_whitelist.conf <<EOF
<Directory $NCDIR>
  # VIDEOS
  SecRuleRemoveById 958291             # Range Header Checks
  SecRuleRemoveById 980120             # Correlated Attack Attempt

  # PDF
  SecRuleRemoveById 920230             # Check URL encodings

  # ADMIN (webdav)
  SecRuleRemoveById 960024             # Repeatative Non-Word Chars (heuristic)
  SecRuleRemoveById 981173             # SQL Injection Character Anomaly Usage
  SecRuleRemoveById 980130             # Correlated Attack Attempt
  SecRuleRemoveById 981243             # PHPIDS - Converted SQLI Filters
  SecRuleRemoveById 981245             # PHPIDS - Converted SQLI Filters
  SecRuleRemoveById 981246             # PHPIDS - Converted SQLI Filters
  SecRuleRemoveById 981318             # String Termination/Statement Ending Injection Testing
  SecRuleRemoveById 973332             # XSS Filters from IE
  SecRuleRemoveById 973338             # XSS Filters - Category 3
  SecRuleRemoveById 981143             # CSRF Protections ( TODO edit LocationMatch filter )

  # COMING BACK FROM OLD SESSION
  SecRuleRemoveById 970903             # Microsoft Office document properties leakage

  # NOTES APP
  SecRuleRemoveById 981401             # Content-Type Response Header is Missing and X-Content-Type-Options is either missing or not set to 'nosniff'
  SecRuleRemoveById 200002             # Failed to parse request body

  # UPLOADS ( 5 MB max excluding file size )
  SecRequestBodyNoFilesLimit 5242880

  # GENERAL
  SecRuleRemoveById 920350             # Host header is a numeric IP address

  # REGISTERED WARNINGS, BUT DID NOT HAVE TO DISABLE THEM
  #SecRuleRemoveById 981220 900046 981407
  #SecRuleRemoveById 981222 981405 981185 949160

</Directory>
<Directory $NCPWB>
  # GENERAL
  SecRuleRemoveById 920350             # Host header is a numeric IP address
</Directory>
EOF

  [[ $ACTIVE_ == "yes" ]] && local STATE=On || local STATE=Off
  sed -i "s|SecRuleEngine .*|SecRuleEngine $STATE|" /etc/modsecurity/modsecurity.conf
  [[ $ACTIVE_ == "yes" ]] && echo "Enabling module security2" || echo "Disabling module security2"
  [[ $ACTIVE_ == "yes" ]] && a2enmod security2 &>/dev/null || a2dismod security2 &>/dev/null

  # delayed in bg so it does not kill the connection, and we get AJAX response
  ( sleep 2 && systemctl restart apache2 ) &>/dev/null & 
}

cleanup()
{
  apt-get autoremove -y
  apt-get clean
  rm /var/lib/apt/lists/* -r
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

