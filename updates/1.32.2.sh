# Applies the fix from https://github.com/nextcloud/server/pull/24550

set -e

source /usr/local/etc/library.sh # sets NCVER PHPVER RELEASE

[[ -d "/var/www/nextcloud" ]] || {
  echo "Nextcloud doesn't appear to be installed - aborting";
  exit 1;
}

cd "/var/www/nextcloud"

patch -p1 <<EOF
diff --git a/lib/private/Session/CryptoSessionData.php b/lib/private/Session/CryptoSessionData.php
index fc7693b71b2..2b5b5c7b5e7 100644
--- a/lib/private/Session/CryptoSessionData.php
+++ b/lib/private/Session/CryptoSessionData.php
@@ -87,6 +87,7 @@ protected function initializeSession() {
 			);
 		} catch (\Exception $e) {
 			$this->sessionValues = [];
+			$this->regenerateId(true, false);
 		}
 	}
 
EOF

# docker images only
[[ -f /.docker-image ]] && {
  :
}

# for non docker images
[[ ! -f /.docker-image ]] && {
  :
}

exit 0
