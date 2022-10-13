#!/bin/bash

# modsecurity WAF installation on Raspbian
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at ownyourbits.com
#

install()
{
  apt-get update
  apt-get install -y --no-install-recommends libapache2-mod-security2 modsecurity-crs
  a2dismod security2

  cat >> /etc/modsecurity/crs/crs-setup.conf <<'EOF'

  # NextcloudPi: allow PROPFIND for webDAV
  SecAction "id:900200, phase:1, nolog, pass, t:none, setvar:'tx.allowed_methods=GET HEAD POST OPTIONS PROPFIND'"
EOF

  # CONFIGURE
  cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf
  sed -i "s|SecRuleEngine .*|SecRuleEngine Off|"               /etc/modsecurity/modsecurity.conf
  sed -i 's|SecTmpDir .*|SecTmpDir   /var/cache/modsecurity/|' /etc/modsecurity/modsecurity.conf
  sed -i 's|SecDataDir .*|SecDataDir /var/cache/modsecurity/|' /etc/modsecurity/modsecurity.conf
  sed -i 's|^SecRequestBodyLimit .*|#SecRequestBodyLimit 13107200|' /etc/modsecurity/modsecurity.conf

  # turn modsecurity logs off, too spammy
  sed -i 's|SecAuditEngine .*|SecAuditEngine Off|' /etc/modsecurity/modsecurity.conf

  cat >> /etc/apache2/apache2.conf <<EOF
<IfModule mod_security2.c>
  SecServerSignature " "
</IfModule>
EOF
}

configure()
{
  local NCDIR=/var/www/nextcloud/
  local NCPWB=/var/www/ncp-web/

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

  # UPLOADS ( https://github.com/nextcloud/nextcloudpi/issues/959#issuecomment-529150562 )
  SecRequestBodyNoFilesLimit 536870912

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

  [[ $ACTIVE == "yes" ]] && local STATE=On || local STATE=Off
  sed -i "s|SecRuleEngine .*|SecRuleEngine $STATE|" /etc/modsecurity/modsecurity.conf
  [[ $ACTIVE == "yes" ]] && echo "Enabling module security2" || echo "Disabling module security2"
  [[ $ACTIVE == "yes" ]] && a2enmod security2 &>/dev/null || a2dismod security2 &>/dev/null

  apachectl -k graceful
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

