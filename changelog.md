
<<<<<<< HEAD
[v1.39.10](https://github.com/nextcloud/nextcloudpi/commit/27e7d06) (2021-09-21) fix inverted template logic for docker

[v1.39.9 ](https://github.com/nextcloud/nextcloudpi/commit/afeb957) (2021-09-21) letsencrypt: fix renewal with httpsonly enabled

[v1.39.8](https://github.com/nextcloud/nextcloudpi/commit/6fca91c) (2021-09-21) letsencrypt: take into account duplicate domains ending in -0001

[v1.39.7 ](https://github.com/nextcloud/nextcloudpi/commit/a07ddd2) (2021-09-21) letsencrypt: fix active status check

[v1.39.6](https://github.com/nextcloud/nextcloudpi/commit/534b9b5) (2021-09-19) ncp-update-nc: pre-check that NC is currently working fine
=======
[v1.40.2](https://github.com/nextcloud/nextcloudpi/commit/fc3f978) (2021-10-05) nc-update-nc: BTRFS support

[v1.40.1](https://github.com/nextcloud/nextcloudpi/commit/7c361c5) (2021-10-05) update: improve check for apt (#1356)

[v1.40.0 ](https://github.com/nextcloud/nextcloudpi/commit/a0728d7) (2021-10-04) nc-notify-updates: notify of new supported NC versions

[v1.39.21](https://github.com/nextcloud/nextcloudpi/commit/2037064) (2021-10-04) ncp-web: disable activation page once activated

[v1.39.20](https://github.com/nextcloud/nextcloudpi/commit/714c3e5) (2021-10-04) ncp-config: fix first time error with no known latest version

[v1.39.19](https://github.com/nextcloud/nextcloudpi/commit/05f0d35) (2021-09-30) ncp-web: fix upload from local file path

[v1.39.18](https://github.com/nextcloud/nextcloudpi/commit/f1c90f5) (2021-09-30) nc-httpsonly: always use overwriteprotocol https in all cases

[v1.39.17](https://github.com/nextcloud/nextcloudpi/commit/c037c11) (2021-09-29) add bash completion to ncc

[v1.39.16](https://github.com/nextcloud/nextcloudpi/commit/2be666b) (2021-09-27) nc-https: proto logic was inverted fix

[v1.39.15](https://github.com/nextcloud/nextcloudpi/commit/b067844) (2021-09-27) add get_ip function

[v1.39.14](https://github.com/nextcloud/nextcloudpi/commit/6ad96ed) (2021-09-25) nc-https:only fix infinite redirects behind proxy

[v1.39.13](https://github.com/nextcloud/nextcloudpi/commit/eef7b09) (2021-09-23) ncp-web: make letsencrypt detection more robust

[v1.39.12](https://github.com/nextcloud/nextcloudpi/commit/814569b) (2021-09-22) fix junk in overwrite.cli.url because of Redis not being yet ready

[v1.39.11](https://github.com/nextcloud/nextcloudpi/commit/4039da9) (2021-09-21) letsencrypt: take into account duplicate domains ending in -0001

[v1.39.10](https://github.com/nextcloud/nextcloudpi/commit/2b51476) (2021-09-21) fix inverted template logic for docker

[v1.39.9 ](https://github.com/nextcloud/nextcloudpi/commit/a4851dc) (2021-09-21) letsencrypt: fix renewal with httpsonly enabled

[v1.39.8 ](https://github.com/nextcloud/nextcloudpi/commit/1046a24) (2021-09-21) letsencrypt: fix active status check

[v1.39.7 ](https://github.com/nextcloud/nextcloudpi/commit/98976c9) (2021-09-22) dont update config if Redis is not yet ready

[v1.39.6 ](https://github.com/nextcloud/nextcloudpi/commit/534b9b5) (2021-09-19) ncp-update-nc: pre-check that NC is currently working fine
>>>>>>> devel

[v1.39.5 ](https://github.com/nextcloud/nextcloudpi/commit/cb184d2) (2021-09-19) ncp-update-nc: dont keep notifying when there is nothing to upgrade

[v1.39.4 ](https://github.com/nextcloud/nextcloudpi/commit/311cd2b) (2021-09-19) improve btrfs/ext checks

[v1.39.3 ](https://github.com/nextcloud/nextcloudpi/commit/f3e3b01) (2021-09-18) letsencrypt: improve active status check

[v1.39.2 ](https://github.com/nextcloud/nextcloudpi/commit/110311f) (2021-09-18) nextcloud-domain: make sure redis is running before it starts

[v1.39.1 ](https://github.com/nextcloud/nextcloudpi/commit/6290c1f) (2021-09-09) nc-static-IP: take into account httpsonly

[v1.39.0 ](https://github.com/nextcloud/nextcloudpi/commit/c10d4bd) (2021-09-05) upgrade to NC21.0.4

[v1.38.6](https://github.com/nextcloud/nextcloudpi/commit/3bf746b) (2021-08-25) raspi: allow oldstable origins

[v1.38.5 ](https://github.com/nextcloud/nextcloudpi/commit/e23b252) (2021-08-17) nc-init: drop News for 32-bit :(

[v1.38.4 ](https://github.com/nextcloud/nextcloudpi/commit/bb720be) (2021-08-17) build: make sure we clean /.ncp-image in old builds

[v1.38.3](https://github.com/nextcloud/nextcloudpi/commit/9642cf9) (2021-08-17) unattended-upgrades: update raspbian origins

[v1.38.2 ](https://github.com/nextcloud/nextcloudpi/commit/956eea4) (2021-08-16) nc-restore: try to detect old datadir in dataless restoration

[v1.38.1 ](https://github.com/nextcloud/nextcloudpi/commit/4f29d94) (2021-08-16) nextcloud.conf.sh: Prevent apache config test output to end up in generated template

[v1.38.0 ](https://github.com/nextcloud/nextcloudpi/commit/6e2dca5) (2021-08-09) upgrade to NC20.0.12

[v1.37.9 ](https://github.com/nextcloud/nextcloudpi/commit/b8c1409) (2021-08-09) letsencrypt: ability to disable it and roll back to self-signed certificates

[v1.37.8 ](https://github.com/nextcloud/nextcloudpi/commit/5a05b89) (2021-08-08) nextcloud: remove beta option

[v1.37.7 ](https://github.com/nextcloud/nextcloudpi/commit/1d696f0) (2021-08-07) nc-backup-auto.sh: don't smash ncp.log

[v1.37.6 ](https://github.com/nextcloud/nextcloudpi/commit/b840245) (2021-08-03) metrics.sh: Fix inverted is_active result

[v1.37.5 ](https://github.com/nextcloud/nextcloudpi/commit/fb102d2) (2021-08-03) metrics.sh: Fix USER variable being ignored

[v1.37.4 ](https://github.com/nextcloud/nextcloudpi/commit/e492032) (2021-08-02) nextcloud.conf.sh: Allow any user name for metrics endpoint and fix docker build

[v1.37.3 ](https://github.com/nextcloud/nextcloudpi/commit/b8a990e) (2021-08-02) Add ncp-app for prometheus (system) metrics

[v1.37.2](https://github.com/nextcloud/nextcloudpi/commit/4300e30) (2021-07-31) unattended-upgrades: update raspbian origins

[v1.37.1 ](https://github.com/nextcloud/nextcloudpi/commit/b1ffd70) (2021-07-06) ncp-app: bump to NC21

[v1.37.0 ](https://github.com/nextcloud/nextcloudpi/commit/effdd6c) (2021-07-03) upgrade to NC20.0.11

[v1.36.3 ](https://github.com/nextcloud/nextcloudpi/commit/7b809d1) (2021-05-13) ncp-web: fix port checking for IPv6 dual stack

[v1.36.2 ](https://github.com/nextcloud/nextcloudpi/commit/1a8ac71) (2021-05-11) ncp-web: fix port checking

[v1.36.1 ](https://github.com/nextcloud/nextcloudpi/commit/67aa599) (2021-05-09) lamp: allow only TLSv12 and TLSv13

[v1.36.0 ](https://github.com/nextcloud/nextcloudpi/commit/7aef967) (2020-09-16) Namecheap dynamic DNS client

[v1.35.2 ](https://github.com/nextcloud/nextcloudpi/commit/8d76a6b) (2021-04-29) ncp-web: fix display of big files for 32 bit

[v1.35.1 ](https://github.com/nextcloud/nextcloudpi/commit/0ee3aa9) (2021-04-29) ncp-web: fix backup download for big files in 32-bit

[v1.35.0 ](https://github.com/nextcloud/nextcloudpi/commit/be30663) (2021-02-27) upgrade to NC20.0.8

[v1.34.9 ](https://github.com/nextcloud/nextcloudpi/commit/7d15924) (2021-01-19) nc-autoupdate-ncp: Append to log instead of replace

[v1.34.8 ](https://github.com/nextcloud/nextcloudpi/commit/117b8ea) (2021-01-20) nc-automount: udiskie verbose output

[v1.34.7 ](https://github.com/nextcloud/nextcloudpi/commit/b978184) (2021-01-19) docker: fix datadir path contents

[v1.34.6 ](https://github.com/nextcloud/nextcloudpi/commit/84ccf94) (2021-01-18) docker: fix datadir path

[v1.34.5 ](https://github.com/nextcloud/nextcloudpi/commit/afa39fb) (2021-01-18) ncp-config: shorten descriptions

[v1.34.4 ](https://github.com/nextcloud/nextcloudpi/commit/3a3b6a7) (2021-01-17) btrfs-sync: check for existing keys

[v1.34.3 ](https://github.com/nextcloud/nextcloudpi/commit/6cb682a) (2021-01-17) update cron interval

[v1.34.2 ](https://github.com/nextcloud/nextcloudpi/commit/20bd14f) (2021-01-17) wizard: fix letsencrypt empty email

[v1.34.1](https://github.com/nextcloud/nextcloudpi/commit/23eecff) (2021-01-01) unattended-upgrades: fix raspbian origin

[v1.34.0 ](https://github.com/nextcloud/nextcloudpi/commit/ec428a2) (2021-01-01) upgrade to NC20.0.4

[v1.33.2 ](https://github.com/nextcloud/nextcloudpi/commit/82d00c8) (2021-01-01) ncp-config: fix empty values

[v1.33.1 ](https://github.com/nextcloud/nextcloudpi/commit/42fd597) (2020-12-12) nc-update-nc: improve error messages

[v1.33.0 ](https://github.com/nextcloud/nextcloudpi/commit/ffd0b44) (2020-12-10) upgrade to NC20.0.3

[v1.32.1 ](https://github.com/nextcloud/nextcloudpi/commit/35c0d96) (2020-11-30) nc-update-nc: ncp apps might not exist

[v1.32.0 ](https://github.com/nextcloud/nextcloudpi/commit/7afdc0f) (2020-11-24) upgrade to NC20.0.2

[v1.31.0 ](https://github.com/nextcloud/nextcloudpi/commit/ab9184c) (2020-10-19) upgrade to NC19.0.4

[v1.30.1 ](https://github.com/nextcloud/nextcloudpi/commit/9450613) (2020-10-20) nc-info: fixed api change for portchecker (#1194)

[v1.30.0 ](https://github.com/nextcloud/nextcloudpi/commit/f00fe21) (2020-09-19) upgrade to NC19.0.2

[v1.29.11](https://github.com/nextcloud/nextcloudpi/commit/82baebf) (2020-09-03) ncp-web: added a lot of german locales

[v1.29.10](https://github.com/nextcloud/nextcloudpi/commit/3706ed0) (2020-09-12) nc-previews: fix killing generate-all

[v1.29.9 ](https://github.com/nextcloud/nextcloudpi/commit/9d65011) (2020-09-07) nc-restore: also set tempdirectory

[v1.29.8 ](https://github.com/nextcloud/nextcloudpi/commit/21a791d) (2020-08-30) nc-limits: minimum 6 PHP threads (for NC talk)

[v1.29.7 ](https://github.com/nextcloud/nextcloudpi/commit/c143acc) (2020-07-24) do not hsts preload by default, only serve hsts header over https

[v1.29.6 ](https://github.com/nextcloud/nextcloudpi/commit/14b78e3) (2020-08-29) ncp-web: Fix the style of the language selection dropdown (chrome)

[v1.29.5 ](https://github.com/nextcloud/nextcloudpi/commit/34e84ba) (2020-08-30) ncp-web: fix initial screen displaying all sections

[v1.29.4 ](https://github.com/nextcloud/nextcloudpi/commit/17aae56) (2020-08-30) ncp-update-nc: check for ncc commands before using them

[v1.29.3 ](https://github.com/nextcloud/nextcloudpi/commit/76ffaec) (2020-08-26) nc-static-IP: Restricting gateway to one

[v1.29.0 ](https://github.com/nextcloud/nextcloudpi/commit/3cf269a) (2020-08-28) upgrade to NC19.0.2

[v1.28.4 ](https://github.com/nextcloud/nextcloudpi/commit/4c5b207) (2020-08-02) ncp-backup-auto: fix exit status for cron

[v1.28.3 ](https://github.com/nextcloud/nextcloudpi/commit/81fcd14) (2020-08-02) ncp-autoupdate-apps: dont fail cron if no updates

[v1.28.2 ](https://github.com/nextcloud/nextcloudpi/commit/06017a4) (2020-08-02) nc-limits: adjust db size

[v1.28.1 ](https://github.com/nextcloud/nextcloudpi/commit/dda010b) (2020-08-02) nc-ramlogs: pin version

[v1.28.0 ](https://github.com/nextcloud/nextcloudpi/commit/99cfe9b) (2020-07-23) upgrade to NC18.0.7

[v1.27.0 ](https://github.com/nextcloud/nextcloudpi/commit/3c96d2e) (2020-07-05) upgrade to NC18.0.6

[v1.26.2 ](https://github.com/nextcloud/nextcloudpi/commit/337ffeb) (2020-06-13) ncp-autoupdate: cronjob write to the log only (#1144)

[v1.26.1 ](https://github.com/nextcloud/nextcloudpi/commit/4e79386) (2020-06-13) ncp-web: fix port checking

[v1.26.0 ](https://github.com/nextcloud/nextcloudpi/commit/aedd8f0) (2020-06-11) upgrade to NC18.0.5

[v1.25.0 ](https://github.com/nextcloud/nextcloudpi/commit/ed3619f) (2020-04-24) upgrade to NC18.0.4

[v1.24.3 ](https://github.com/nextcloud/nextcloudpi/commit/1c45e0d) (2020-04-18) ncp-web: cache backup info

[v1.24.2 ](https://github.com/nextcloud/nextcloudpi/commit/ff565d6) (2020-04-06) build: small tweaks

[v1.24.1 ](https://github.com/nextcloud/nextcloudpi/commit/ae6c88f) (2020-04-06) nc-backup-auto: fix notify_admin

[v1.24.0 ](https://github.com/nextcloud/nextcloudpi/commit/a3dbec1) (2020-03-24) upgrade to NC18.0.3

[v1.23.2 ](https://github.com/nextcloud/nextcloudpi/commit/0a97f77) (2020-03-22) lamp: disable old TLS versions

[v1.23.1 ](https://github.com/nextcloud/nextcloudpi/commit/84e6b4e) (2020-03-15) ncp-web: check for possibly missing index

[v1.23.0 ](https://github.com/nextcloud/nextcloudpi/commit/d108fad) (2020-03-13) upgrade to NC18.0.2

[v1.22.3 ](https://github.com/nextcloud/nextcloudpi/commit/c09dfd9) (2020-03-02) nc-snapshot-auto: read datadir location during execution

[v1.22.2 ](https://github.com/nextcloud/nextcloudpi/commit/f71c8c8) (2020-03-02) nc-maintenance: add is_active

[v1.22.1 ](https://github.com/nextcloud/nextcloudpi/commit/c49c390) (2020-03-03) samba: option to apply only to a NC group (#1048)

[v1.22.0 ](https://github.com/nextcloud/nextcloudpi/commit/9304c86) (2020-03-03) Add nc-trusted-proxies (#1094)

[v1.21.0 ](https://github.com/nextcloud/nextcloudpi/commit/4a51c1f) (2020-02-28) upgrade to NC18.0.1

[v1.20.11](https://github.com/nextcloud/nextcloudpi/commit/f066b03) (2020-02-27) redis: make sure we have the right permissions for conf file

[v1.20.10](https://github.com/nextcloud/nextcloudpi/commit/c0cee6b) (2020-02-12) fail2ban: fix regex for NC18

[v1.20.9 ](https://github.com/nextcloud/nextcloudpi/commit/0c538ae) (2020-02-04) add notify_admin functionality

[v1.20.8 ](https://github.com/nextcloud/nextcloudpi/commit/986046f) (2020-02-05) nc-backup: add more info to description (#1073)

[v1.20.7 ](https://github.com/nextcloud/nextcloudpi/commit/b404765) (2020-01-26) fail2ban: update regex for NC17

[v1.20.6 ](https://github.com/nextcloud/nextcloudpi/commit/4a99207) (2020-01-21) ncp-config: dont save passwords

[v1.20.5 ](https://github.com/nextcloud/nextcloudpi/commit/a98baee) (2020-01-18) update: fix case where there is no current version file

[v1.20.4 ](https://github.com/nextcloud/nextcloudpi/commit/e0ae40b) (2020-01-19) Add user only if it does not exist. (#1059)

[v1.20.3 ](https://github.com/nextcloud/nextcloudpi/commit/6359ca3) (2020-01-14) nc-ramlogs: disable armbian-ramlog when inactive

[v1.20.2 ](https://github.com/nextcloud/nextcloudpi/commit/953c47a) (2019-11-13) Extend the ssh configuration check by calling the echo command if the first check fails.

[v1.20.1 ](https://github.com/nextcloud/nextcloudpi/commit/6d0bc6b) (2019-12-19) Revert "build: dont use empty values by default"

[v1.20.0 ](https://github.com/nextcloud/nextcloudpi/commit/f75c415) (2019-12-19) upgrade to NC17.0.2

[v1.19.1 ](https://github.com/nextcloud/nextcloudpi/commit/f9deb25) (2019-12-08) pre-generate: fix permissions

[v1.19.0 ](https://github.com/nextcloud/nextcloudpi/commit/72d2d00) (2019-11-30) upgrade to NC17.0.1

[v1.18.2 ](https://github.com/nextcloud/nextcloudpi/commit/c42bcc1) (2019-11-17) update: fix matching values

[v1.18.1 ](https://github.com/nextcloud/nextcloudpi/commit/310877f) (2019-11-18) Letsencrypt: support second domain (#1025)

[v1.18.0 ](https://github.com/nextcloud/nextcloudpi/commit/0fc2390) (2019-10-27) add ncp-previews

[v1.17.1 ](https://github.com/nextcloud/nextcloudpi/commit/c63cb27) (2019-09-29) nc-backup: exclude group folders in dataless backup

[v1.17.0 ](https://github.com/nextcloud/nextcloudpi/commit/05e78cc) (2019-09-28) upgrade to NC16.0.5

[v1.16.9 ](https://github.com/nextcloud/nextcloudpi/commit/46b2187) (2019-09-28) fix apt stuck in interactive conf file dialog

[v1.16.8 ](https://github.com/nextcloud/nextcloudpi/commit/f885861) (2019-09-16) unattended-upgrades: fix armbian disabling UU

[v1.16.7 ](https://github.com/nextcloud/nextcloudpi/commit/9ee9947) (2019-09-11) Increased modsecurity bodynofileslimit so larger files can be synced (#993)

[v1.16.6 ](https://github.com/nextcloud/nextcloudpi/commit/dbf129f) (2019-09-13) nc-datadir: fix

[v1.16.5 ](https://github.com/nextcloud/nextcloudpi/commit/789f0b5) (2019-09-12) nc-datadir: make sure dir exists before check

[v1.16.4 ](https://github.com/nextcloud/nextcloudpi/commit/4bd06e6) (2019-09-10) fail2ban: dont need ufw check in docker

[v1.16.3 ](https://github.com/nextcloud/nextcloudpi/commit/06005e1) (2019-09-09) nc-datadir: avoid using the symlink

[v1.16.2 ](https://github.com/nextcloud/nextcloudpi/commit/f4b4a65) (2019-09-04) custom code before/after auto-backup

[v1.16.1 ](https://github.com/nextcloud/nextcloudpi/commit/fd2b74b) (2019-09-02) Add missing port in nc-rsync-auto.sh (#983)

[v1.16.0 ](https://github.com/nextcloud/nextcloudpi/commit/1a367a6) (2019-08-23) upgrade to NC16.0.4

[v1.15.5 ](https://github.com/nextcloud/nextcloudpi/commit/954366e) (2019-08-18) make sure ufw.log always exists for fail2ban (#937)

[v1.15.4 ](https://github.com/nextcloud/nextcloudpi/commit/bf30c4f) (2019-07-28) add warning to add LABEL when formating

[v1.15.3 ](https://github.com/nextcloud/nextcloudpi/commit/bcef6bf) (2019-07-24) nc-snapshot: update btrfs-snp

[v1.15.2 ](https://github.com/nextcloud/nextcloudpi/commit/212bd46) (2019-07-19) update: restore smbclient after dist upgrade

[v1.15.1 ](https://github.com/nextcloud/nextcloudpi/commit/7663a90) (2019-07-17) exclude versions, trash, uploads from backups

[v1.15.0 ](https://github.com/nextcloud/nextcloudpi/commit/e4bd5fe) (2019-07-08) move to buster/PHP7.3

[v1.14.4 ](https://github.com/nextcloud/nextcloudpi/commit/68b3f8a) (2019-07-08) nc-previews: active by default

[v1.14.3 ](https://github.com/nextcloud/nextcloudpi/commit/85ebb39) (2019-07-06) nc-snapshot-sync: update btrfs-sync

[v1.14.2 ](https://github.com/nextcloud/nextcloudpi/commit/53d02fe) (2019-07-06) nc-hdd-monitor: fix detection

[v1.14.0 ](https://github.com/nextcloud/nextcloudpi/commit/fa9ddca) (2019-07-05) upgrade to NC16.0.2

[v1.13.6 ](https://github.com/nextcloud/nextcloudpi/commit/88da901) (2019-06-29) ncp-update: fixes on the new step based upgrade system

[v1.13.5 ](https://github.com/nextcloud/nextcloudpi/commit/fbdab43) (2019-06-29) ncp-web: adjust ipv6 local restrictions

[v1.13.4 ](https://github.com/nextcloud/nextcloudpi/commit/ce4477c) (2019-06-29) nc-previews: adjust preview sizes

[v1.13.3 ](https://github.com/nextcloud/nextcloudpi/commit/0701949) (2019-06-23) spDYN: remove unused IPV6 argument in spDYN.sh

[v1.13.2 ](https://github.com/nextcloud/nextcloudpi/commit/c392529) (2019-06-17) nc-backup: fix exclusion of ncp backups

[v1.13.1 ](https://github.com/nextcloud/nextcloudpi/commit/5de855f) (2019-06-01) ncp-web: avoid quotes in fields

[v1.13.0 ](https://github.com/nextcloud/nextcloudpi/commit/86f14ae) (2019-06-01) upgrade to NC15.0.8

[v1.12.10](https://github.com/nextcloud/nextcloudpi/commit/5924131) (2019-06-01) fail2ban: fix missing ufw filter

[v1.12.9 ](https://github.com/nextcloud/nextcloudpi/commit/c71b37f) (2019-05-27) ncp-notify-updates: dont spam cron mail

[v1.12.8 ](https://github.com/nextcloud/nextcloudpi/commit/bfdc475) (2019-05-25) docker: mount timezone

[v1.12.7 ](https://github.com/nextcloud/nextcloudpi/commit/76137ed) (2019-05-25) ncp-app: bump to NC16

[v1.12.6 ](https://github.com/nextcloud/nextcloudpi/commit/da09dc9) (2019-05-25) fail2ban: add a ufw jail and filter (dmaroulidis)

[v1.12.5 ](https://github.com/nextcloud/nextcloudpi/commit/30c0f57) (2019-05-25) ncp-web: update config reference URL

[v1.12.4 ](https://github.com/nextcloud/nextcloudpi/commit/c8d6222) (2019-05-26) ncp-web: Pt Translate (#907)

[v1.12.3 ](https://github.com/nextcloud/nextcloudpi/commit/d938481) (2019-05-11) nc-scan-auto: recursive and home-only options

[v1.12.2 ](https://github.com/nextcloud/nextcloudpi/commit/7589081) (2019-05-11) fix logrotate files

[v1.12.1 ](https://github.com/nextcloud/nextcloudpi/commit/1be5ddd) (2019-05-01) Rename configuration variables into self-documenting ones (#889)

[v1.12.0 ](https://github.com/nextcloud/nextcloudpi/commit/f34354c) (2019-04-29) ncp-web: add backups panel

[v1.11.5 ](https://github.com/nextcloud/nextcloudpi/commit/01cd421) (2019-04-29) letsencrypt: force renewal by default

[v1.11.4 ](https://github.com/nextcloud/nextcloudpi/commit/b3c7d13) (2019-04-28) letsencrypt: switch to apt version

[v1.11.3 ](https://github.com/nextcloud/nextcloudpi/commit/02efd61) (2019-04-09) nc-restore: check btrfs command

[v1.11.2 ](https://github.com/nextcloud/nextcloudpi/commit/3754609) (2019-04-06) armbian: fix uu

[v1.11.1 ](https://github.com/nextcloud/nextcloudpi/commit/a712935) (2019-04-05) nc-backup: fix space calculation

[v1.11.0 ](https://github.com/nextcloud/nextcloudpi/commit/5dedeaf) (2019-04-05) upgrade to NC15.0.6

[v1.10.12](https://github.com/nextcloud/nextcloudpi/commit/a6e33b1) (2019-04-05) update UPDATE config section

[v1.10.11](https://github.com/nextcloud/nextcloudpi/commit/194d111) (2019-04-04) create UPDATE config section

[v1.10.10](https://github.com/nextcloud/nextcloudpi/commit/b11c13e) (2019-04-05) nc-backup: improve needed space calculation (#864)

[v1.10.9 ](https://github.com/nextcloud/nextcloudpi/commit/5af854b) (2019-04-01) letsencrypt: dont return error if notif fails

[v1.10.8 ](https://github.com/nextcloud/nextcloudpi/commit/c18273a) (2019-03-26) nc-backup: fix space calculation

[v1.10.7 ](https://github.com/nextcloud/nextcloudpi/commit/41a4e84) (2019-03-14) nc-restore: Check for free space in $TMPDIR before extracting tar file

[v1.10.6 ](https://github.com/nextcloud/nextcloudpi/commit/38799fd) (2019-03-23) letsencrypt: rework notification

[v1.10.5 ](https://github.com/nextcloud/nextcloudpi/commit/2460264) (2019-03-23) fix cron path

[v1.10.4 ](https://github.com/nextcloud/nextcloudpi/commit/f0b467b) (2019-03-18) nc-update-nc-apps-auto: only notify if there was update

[v1.10.3 ](https://github.com/nextcloud/nextcloudpi/commit/4b6572a) (2019-03-18) nc-update-nc: fix case where imported cfg from non docker to docker

[v1.10.2 ](https://github.com/nextcloud/nextcloudpi/commit/ec66e40) (2019-03-16) freeDNS: fix hash

[v1.10.1 ](https://github.com/nextcloud/nextcloudpi/commit/311ccc7) (2019-03-13) nc-update-nc-apps-auto: notify user

[v1.10.0 ](https://github.com/nextcloud/nextcloudpi/commit/06073ed) (2019-03-13) add nc-previews-auto

[v1.9.8  ](https://github.com/nextcloud/nextcloudpi/commit/d7bbe25) (2019-03-13) nc-scan: improvements

[v1.9.7  ](https://github.com/nextcloud/nextcloudpi/commit/e03b095) (2019-03-13) nc-previews: improvements

[v1.9.6  ](https://github.com/nextcloud/nextcloudpi/commit/ccb6fc1) (2019-03-13) nc-scan-auto: improvements

[v1.9.5  ](https://github.com/nextcloud/nextcloudpi/commit/89cc042) (2019-03-09) nc-init: previews settings

[v1.9.4  ](https://github.com/nextcloud/nextcloudpi/commit/0c95243) (2019-03-09) unattended upgrades: update labels

[v1.9.3  ](https://github.com/nextcloud/nextcloudpi/commit/f5ba0b1) (2019-03-09) wizard: fix headers

[v1.9.2  ](https://github.com/nextcloud/nextcloudpi/commit/1a46667) (2019-03-08) cleanup update.sh

[v1.9.1  ](https://github.com/nextcloud/nextcloudpi/commit/060f004) (2019-03-03) fix LE cron

[v1.9.0  ](https://github.com/nextcloud/nextcloudpi/commit/a9d4775) (2019-03-03) upgrade to NC15.0.5

[v1.8.4  ](https://github.com/nextcloud/nextcloudpi/commit/9c39606) (2019-02-23) nc-nextcloud: disable .user.ini

[v1.8.3  ](https://github.com/nextcloud/nextcloudpi/commit/bf1fc1f) (2019-02-23) nc-limits: autocalculate database memory

[v1.8.2  ](https://github.com/nextcloud/nextcloudpi/commit/e39c3ab) (2019-02-22) lamp: adjust mariadb parameters

[v1.8.1  ](https://github.com/nextcloud/nextcloudpi/commit/160e295) (2019-03-05) nc-datadir: Add SATA to description (#822)

[v1.8.0  ](https://github.com/nextcloud/nextcloudpi/commit/602b3f2) (2019-02-23) add nc-maintenance-mode (#809)

[v1.7.0  ](https://github.com/nextcloud/nextcloudpi/commit/5e1ea77) (2019-02-17) add nc-restore-snapshot

[v1.6.7  ](https://github.com/nextcloud/nextcloudpi/commit/41a48c9) (2019-02-17) nc-backup-auto: notify failures

[v1.6.6  ](https://github.com/nextcloud/nextcloudpi/commit/743cb24) (2019-02-15) nc-automount: fix NFS delay

[v1.6.5  ](https://github.com/nextcloud/nextcloudpi/commit/c28868d) (2019-02-15) nc-trusted-domains: empty values by default

[v1.6.4  ](https://github.com/nextcloud/nextcloudpi/commit/4e04339) (2019-02-14) nc-nextcloud: update description

[v1.6.3  ](https://github.com/nextcloud/nextcloudpi/commit/af5e35d) (2019-02-13) ncp-update-nc: BTRFS basedir not supported

[v1.6.2  ](https://github.com/nextcloud/nextcloudpi/commit/b070387) (2019-02-13) nc-datadir: lift mountpoint restriction

[v1.6.1  ](https://github.com/nextcloud/nextcloudpi/commit/3e566f5) (2019-02-10) nc-nextcloud: add a warning

[v1.6.0  ](https://github.com/nextcloud/nextcloudpi/commit/b4bb86d) (2019-02-07) upgrade to NC15.0.4

[v1.5.2  ](https://github.com/nextcloud/nextcloudpi/commit/1a6b7df) (2019-02-07) nc-trusted-domains: add description

[v1.5.1  ](https://github.com/nextcloud/nextcloudpi/commit/a1842bc) (2019-01-30) nc-update-nc-apps-auto: log upgrades

[v1.5.0  ](https://github.com/nextcloud/nextcloudpi/commit/8ca3535) (2019-01-30) added nc-update-nc-apps and nc-update-nc-apps-auto

[v1.4.11 ](https://github.com/nextcloud/nextcloudpi/commit/6331ce5) (2019-01-28) update: make letsencrypt update more resiliant (2)

[v1.4.10 ](https://github.com/nextcloud/nextcloudpi/commit/55121d4) (2019-01-27) update: make letsencrypt update more resiliant

[v1.4.9  ](https://github.com/nextcloud/nextcloudpi/commit/9a36ceb) (2019-01-25) letsencrypt: use the latest github version

[v1.4.8  ](https://github.com/nextcloud/nextcloudpi/commit/338da33) (2019-01-26) ncp-update-nc: fix unnecessary quotes

[v1.4.7  ](https://github.com/nextcloud/nextcloudpi/commit/ffc1fa5) (2019-01-25) ncp-config: fix local variables

[v1.4.6  ](https://github.com/nextcloud/nextcloudpi/commit/b338ede) (2019-01-24) ncp-config: fix missing variable

[v1.4.5  ](https://github.com/nextcloud/nextcloudpi/commit/b7efa7a) (2019-01-22) armbian: fix cron permissions bug (2)

[v1.4.4  ](https://github.com/nextcloud/nextcloudpi/commit/af426a5) (2019-01-22) armbian: fix cron permissions bug

[v1.4.3  ](https://github.com/nextcloud/nextcloudpi/commit/0e062aa) (2019-01-21) dnsmasq: detect IP from config file (#782)

[v1.4.2  ](https://github.com/nextcloud/nextcloudpi/commit/57728e2) (2019-01-21) Proposed fix for issue #773 (#781)

[v1.4.1  ](https://github.com/nextcloud/nextcloudpi/commit/d0ca44a) (2019-01-16) docker: support for ncp-update-nc

[v1.4.0  ](https://github.com/nextcloud/nextcloudpi/commit/1dd1bb7) (2019-01-16) add nc-trusted-domains

[v1.3.12 ](https://github.com/nextcloud/nextcloudpi/commit/1f11d40) (2019-01-16) add public IP to trusted domains

[v1.3.11 ](https://github.com/nextcloud/nextcloudpi/commit/84ac075) (2019-01-16) nc-backup: parallel compression

[v1.3.10 ](https://github.com/nextcloud/nextcloudpi/commit/2419e57) (2019-01-15) nc-backup: compress in place and exclude previews folder

[v1.3.9  ](https://github.com/nextcloud/nextcloudpi/commit/0b8252b) (2019-01-15) build: add exfat utils for external storage

[v1.3.8  ](https://github.com/nextcloud/nextcloudpi/commit/193d89b) (2019-01-14) nc-datadir: fix fail2ban logpath

[v1.3.7  ](https://github.com/nextcloud/nextcloudpi/commit/2ac9b8b) (2019-01-14) ncp-web: allow private IPv6 addresses

[v1.3.6  ](https://github.com/nextcloud/nextcloudpi/commit/34cba9f) (2019-01-14) nc-automount: add delays to some services in a persistent way

[v1.3.5  ](https://github.com/nextcloud/nextcloudpi/commit/6fb9c9b) (2019-01-14) nc-hdd-test: try to detect device type if auto doesnt work

[v1.3.4  ](https://github.com/nextcloud/nextcloudpi/commit/9b1ecbb) (2019-01-14) nc-info: fix automount reporting

[v1.3.3  ](https://github.com/nextcloud/nextcloudpi/commit/389ed0c) (2019-01-14) nc-ramlog: adapt to armbian

[v1.3.2  ](https://github.com/nextcloud/nextcloudpi/commit/be9a546) (2019-01-14) nc-automount: fix description

[v1.3.1  ](https://github.com/nextcloud/nextcloudpi/commit/61e3ff3) (2019-01-13) ncp-update: fail if version cant be parsed

[v1.3.0  ](https://github.com/nextcloud/nextcloudpi/commit/2c943b7) (2019-01-12) upgrade to NC15.0.2

[v1.2.0  ](https://github.com/nextcloud/nextcloudpi/commit/9eaab31) (2019-01-08) add NCP Nextcloud app

[v1.1.3  ](https://github.com/nextcloud/nextcloudpi/commit/d21592c) (2019-01-11) nc-update-nextcloud: only try to restore on reboot once

[v1.1.2  ](https://github.com/nextcloud/nextcloudpi/commit/228c818) (2019-01-10) ncp-web: fix section unselected when sidebar reloads

[v1.1.1  ](https://github.com/nextcloud/nextcloudpi/commit/6ba0cb0) (2019-01-10) ncp-web: escape HTML in details box

[v1.1.0  ](https://github.com/nextcloud/nextcloudpi/commit/0ff1df9) (2019-01-08) upgrade to NC15

[v1.0.2  ](https://github.com/nextcloud/nextcloudpi/commit/06b00e4) (2019-01-09) wizard: dont change missing parameters

[v1.0.1  ](https://github.com/nextcloud/nextcloudpi/commit/f722c45) (2019-01-08) nc-update-nc: remove backup after restoring

[v1.0.0  ](https://github.com/nextcloud/nextcloudpi/commit/013198c) (2019-01-08) ncp-config: allow empty values

[v0.67.13](https://github.com/nextcloud/nextcloudpi/commit/21fee19) (2018-12-31) ncp-web: new chinese translate and update chinese translate. (#721)

[v0.67.12](https://github.com/nextcloud/nextcloudpi/commit/a38be5e) (2018-12-29) curl installer: add provisioning step

[v0.67.11](https://github.com/nextcloud/nextcloudpi/commit/4307b14) (2018-12-27) dynDNS: pdate cron execution interval (#754)

[v0.67.10](https://github.com/nextcloud/nextcloudpi/commit/2e9440d) (2018-12-23) log2ram:  adapt to new name in armbian (#749)

[v0.67.9 ](https://github.com/nextcloud/nextcloudpi/commit/e87c972) (2018-12-21) docker: fix DATADIR variable in nc-backup (#746)

[v0.67.8 ](https://github.com/nextcloud/nextcloudpi/commit/9766dc2) (2018-12-17) nc-init: update echo at end when init done. (#738)

[v0.67.7 ](https://github.com/nextcloud/nextcloudpi/commit/d75ecc2) (2018-12-16) fix tempdir config

[v0.67.6 ](https://github.com/nextcloud/nextcloudpi/commit/ca7bc90) (2018-12-06) nc-init: fix missing variable

[v0.67.5 ](https://github.com/nextcloud/nextcloudpi/commit/d19a7f7) (2018-12-01) nc-datadir: also use tempdirectory setting

[v0.67.4 ](https://github.com/nextcloud/nextcloudpi/commit/88d9fe2) (2018-11-26) nc-restore: check that we are in linux fs

[v0.67.3 ](https://github.com/nextcloud/nextcloudpi/commit/5278bfd) (2018-11-26) nc-datadir: shorten short description

[v0.67.2 ](https://github.com/nextcloud/nextcloudpi/commit/5e4be44) (2018-11-26) change dialog text width to 120

[v0.67.1 ](https://github.com/nextcloud/nextcloudpi/commit/b0262f9) (2018-11-23) referrer policy already in .htaccess in NC14.0.4

[v0.67.0 ](https://github.com/nextcloud/nextcloudpi/commit/bcac4bc) (2018-11-22) upgrade to NC14.0.4

[v0.66.6 ](https://github.com/nextcloud/nextcloudpi/commit/5aeb83c) (2018-11-18) nc-static-IP: clarify usage

[v0.66.4 ](https://github.com/nextcloud/nextcloudpi/commit/f3666d6) (2018-11-11) build: package php7.2-imagick now available

[v0.66.3 ](https://github.com/nextcloud/nextcloudpi/commit/d4206f7) (2018-11-11) nc-hdd-test: remove redundancy

[v0.66.2 ](https://github.com/nextcloud/nextcloudpi/commit/1b25141) (2018-11-06) dont fail removing cronfile

[v0.66.1 ](https://github.com/nextcloud/nextcloudpi/commit/089bebb) (2018-11-04) nc-info: speedup

[v0.66.0 ](https://github.com/nextcloud/nextcloudpi/commit/3cd1cd5) (2018-11-04) add nc-hdd-monitor

[v0.65.0 ](https://github.com/nextcloud/nextcloudpi/commit/6138183) (2018-11-03) add nc-test-hdd

[v0.64.12](https://github.com/nextcloud/nextcloudpi/commit/5e7f3da) (2018-11-03) docker: fix provisioning on a stopped the container

[v0.64.11](https://github.com/nextcloud/nextcloudpi/commit/1758331) (2018-10-27) check for path transversal

[v0.64.10](https://github.com/nextcloud/nextcloudpi/commit/26083e9) (2018-10-24) update: update sources

[v0.64.9 ](https://github.com/nextcloud/nextcloudpi/commit/54e5c21) (2018-10-23) ncp-config: use simple characters

[v0.64.8 ](https://github.com/nextcloud/nextcloudpi/commit/9d998ae) (2018-10-22) ncp-web: update chinese translations

[v0.64.7 ](https://github.com/nextcloud/nextcloudpi/commit/20a4147) (2018-10-21) ncp-web: update chinese translations

[v0.64.6 ](https://github.com/nextcloud/nextcloudpi/commit/bd9b9f1) (2018-10-21) DDNS_spDYN: switch to wget and more

[v0.64.5 ](https://github.com/nextcloud/nextcloudpi/commit/b5ba95a) (2018-10-21) ncp-web: fixed hover text for ncp wizard icon (#688)

[v0.64.4 ](https://github.com/nextcloud/nextcloudpi/commit/d2155b0) (2018-10-21) nc-rsync: dont preserve ACL

[v0.64.3 ](https://github.com/nextcloud/nextcloudpi/commit/6fb1c06) (2018-10-21) nc-rsync: sync datadir, not only content (#686) (#687)

[v0.64.2 ](https://github.com/nextcloud/nextcloudpi/commit/d6b7267) (2018-10-14) ncp-update-nc: make sure cron.php is not running and there are no pending jobs

[v0.64.1 ](https://github.com/nextcloud/nextcloudpi/commit/c036525) (2018-10-12) docker: make bin persistent too

[v0.64.0 ](https://github.com/nextcloud/nextcloudpi/commit/a9b1542) (2018-10-12) upgrade to NC14.0.3

[v0.63.0 ](https://github.com/nextcloud/nextcloudpi/commit/b4555ba) (2018-10-11) upgrade to NC14.0.2

[v0.62.10](https://github.com/nextcloud/nextcloudpi/commit/48ac238) (2018-10-07) limit logs size with logrotate

[v0.62.9 ](https://github.com/nextcloud/nextcloudpi/commit/694a885) (2018-10-07) DDNS_spDYN reinstall DDNS_spDYN for use of IPv6 (#642)

[v0.62.8 ](https://github.com/nextcloud/nextcloudpi/commit/c6da8a9) (2018-10-07) Use DIG instead of NSLOOKUP in DDNS apps (#666)

[v0.62.7 ](https://github.com/nextcloud/nextcloudpi/commit/54e0968) (2018-10-07) nc-prettyURL: Catch failure of maintenance:update:htaccess (#654)

[v0.62.6 ](https://github.com/nextcloud/nextcloudpi/commit/5e3d411) (2018-10-06) nc-limits: fix PHP service restart

[v0.62.5 ](https://github.com/nextcloud/nextcloudpi/commit/0bf6045) (2018-10-03) nc-update-nc: dont fix the news app if there is no news app

[v0.62.4 ](https://github.com/nextcloud/nextcloudpi/commit/aa886f9) (2018-10-03) nc-update-nextcloud: option to upgrade to the latest version

[v0.62.3 ](https://github.com/nextcloud/nextcloudpi/commit/af4b646) (2018-10-03) nc-autoupdate-nc: fix repeating notification

[v0.62.2 ](https://github.com/nextcloud/nextcloudpi/commit/6324949) (2018-10-02) nc-prettyURL: make sure URL is correct

[v0.62.1 ](https://github.com/nextcloud/nextcloudpi/commit/4f20b71) (2018-09-30) redis: change eviction policy

[v0.62.0 ](https://github.com/nextcloud/nextcloudpi/commit/4bce1bb) (2018-09-26) upgrade to PHP7.2

[v0.61.0 ](https://github.com/nextcloud/nextcloudpi/commit/66e4d83) (2018-09-26) upgrade to NC14

[v0.60.8 ](https://github.com/nextcloud/nextcloudpi/commit/6152e7e) (2018-09-24) ncp-web: put configuration in a separate file from available languages

[v0.60.7 ](https://github.com/nextcloud/nextcloudpi/commit/cdbb750) (2018-09-24) docker: disable auto-upgrade until it is adapted to containers

[v0.60.6 ](https://github.com/nextcloud/nextcloudpi/commit/1150ed8) (2018-09-24) nc-format-USB: fix

[v0.60.5 ](https://github.com/nextcloud/nextcloudpi/commit/3de5fe0) (2018-09-23) armbian: fix locales for ncp-config

[v0.60.4 ](https://github.com/nextcloud/nextcloudpi/commit/a7f0fd2) (2018-09-23) build: use a separate file for NCP database config

[v0.60.3 ](https://github.com/nextcloud/nextcloudpi/commit/1bfcebc) (2018-09-23) nc-update-nextcloud: workaround news integrity bug

[v0.60.2 ](https://github.com/nextcloud/nextcloudpi/commit/5914624) (2018-09-21) DDNS_spdyn.sh : Send new IP only when changed.

[v0.60.1 ](https://github.com/nextcloud/nextcloudpi/commit/f80ee23) (2018-07-31) nc-restore: restore to volume in docker container

[v0.60.0 ](https://github.com/nextcloud/nextcloudpi/commit/3a1b974) (2018-09-22) add nc-previews

[v0.59.20](https://github.com/nextcloud/nextcloudpi/commit/4457485) (2018-09-21) autoupdate: log everything to ncp.log

[v0.59.19](https://github.com/nextcloud/nextcloudpi/commit/cc53f40) (2018-09-21) ncp-report: remove sensitive data

[v0.59.18](https://github.com/nextcloud/nextcloudpi/commit/7a8c0e4) (2018-09-20) docker: build fixes

[v0.59.17](https://github.com/nextcloud/nextcloudpi/commit/9ee4282) (2018-09-09) docker: fix letsencrypt not persistent

[v0.59.16](https://github.com/nextcloud/nextcloudpi/commit/7443425) (2018-09-09) docker: allow domains in command line, not only IPs

[v0.59.15](https://github.com/nextcloud/nextcloudpi/commit/41f21fa) (2018-09-17) Don't overwrite an existing mail_smtpmode, if it is not "PHP"

[v0.59.14](https://github.com/nextcloud/nextcloudpi/commit/1420348) (2018-09-18) spDYN: fix misspelled variables

[v0.59.13](https://github.com/nextcloud/nextcloudpi/commit/3479014) (2018-09-15) spDYN: support IPv6

[v0.59.12](https://github.com/nextcloud/nextcloudpi/commit/241f2e0) (2018-09-07) Change email program from PHP to Sendmail

[v0.59.11](https://github.com/nextcloud/nextcloudpi/commit/5be7866) (2018-09-16) lamp: add referrer policy for enhanced privacy

[v0.59.10](https://github.com/nextcloud/nextcloudpi/commit/fcbd661) (2018-09-04) ncp-web: add hover text for ncp admin header icons

[v0.59.9 ](https://github.com/nextcloud/nextcloudpi/commit/6a755c3) (2018-09-16) nc-prettyURL: fixes

[v0.59.8 ](https://github.com/nextcloud/nextcloudpi/commit/a00cd0b) (2018-09-15) nc-format-USB: drive number was off by one (#631)

[v0.59.7 ](https://github.com/nextcloud/nextcloudpi/commit/e26a834) (2018-08-22) Rename DDNS apps so they show up together

[v0.59.6 ](https://github.com/nextcloud/nextcloudpi/commit/1210517) (2018-09-12) wizard: fix instructions for BTRFS

[v0.59.5 ](https://github.com/nextcloud/nextcloudpi/commit/ed96a0c) (2018-09-09) nc-limits: fix error when specifying units

[v0.59.4 ](https://github.com/nextcloud/nextcloudpi/commit/ee370f1) (2018-09-03) ncp-suggestions: fix Raspbian parsing

[v0.59.3 ](https://github.com/nextcloud/nextcloudpi/commit/6e1a1a9) (2018-08-31) build: add imagick for gallery

[v0.59.2 ](https://github.com/nextcloud/nextcloudpi/commit/e25f5d1) (2018-09-10) nc-format-USB: fix wrong detection of USB drives present

[v0.59.1 ](https://github.com/nextcloud/nextcloudpi/commit/378ca60) (2018-09-10) nc-datadir: support specifying the root of the mountpoint

[v0.59.0 ](https://github.com/nextcloud/nextcloudpi/commit/9113ab2) (2018-08-31) update to NC 13.0.6

[v0.58.1 ](https://github.com/nextcloud/nextcloudpi/commit/dad9900) (2018-07-25) nc-datadir: backup existing datadir after checks

[v0.58.0 ](https://github.com/nextcloud/nextcloudpi/commit/df7a277) (2018-07-23) update to NC 13.0.5

[v0.57.21](https://github.com/nextcloud/nextcloudpi/commit/965716d) (2018-07-23) Fixes #566 Remove redundant opcache configuration (#572)

[v0.57.20](https://github.com/nextcloud/nextcloudpi/commit/bf91e4c) (2018-07-20) ncp-config: add spaces to invalid characters

[v0.57.19](https://github.com/nextcloud/nextcloudpi/commit/baaf79a) (2018-07-20) nc-backup: fix space check error message

[v0.57.18](https://github.com/nextcloud/nextcloudpi/commit/b81b3e6) (2018-07-13) fix ncc command repeating itself

[v0.57.17](https://github.com/nextcloud/nextcloudpi/commit/dc089bf) (2018-07-03) armbian: fix image tag preventing updates

[v0.57.16](https://github.com/nextcloud/nextcloudpi/commit/2aa0e8f) (2018-06-27) SSH: fix root password in Raspbian

[v0.57.15](https://github.com/nextcloud/nextcloudpi/commit/2c01a87) (2018-06-26) nc-automount: fix udiskie not installed in latest image

[v0.57.14](https://github.com/nextcloud/nextcloudpi/commit/f1cc627) (2018-06-26) added database dir to ncp-info (#553)

[v0.57.13](https://github.com/nextcloud/nextcloudpi/commit/fe12ff9) (2018-06-24) nc-limits: fix units

[v0.57.12](https://github.com/nextcloud/nextcloudpi/commit/bbb25fa) (2018-06-21) nc-limits: autolimits enhancements

[v0.57.11](https://github.com/nextcloud/nextcloudpi/commit/9983b7c) (2018-06-20) letsencrypt: notify of renewals

[v0.57.10](https://github.com/nextcloud/nextcloudpi/commit/a0a31b4) (2018-06-20) ncp-web: fix JS docker detection

[v0.57.9 ](https://github.com/nextcloud/nextcloudpi/commit/de5d9fb) (2018-06-21) nc-format-USB: fix when ZRAM active

[v0.57.8 ](https://github.com/nextcloud/nextcloudpi/commit/3ee6409) (2018-06-19) docker: adapt wizard

[v0.57.7 ](https://github.com/nextcloud/nextcloudpi/commit/c727d65) (2018-06-19) docker: fix persist ncp-web password

[v0.57.6 ](https://github.com/nextcloud/nextcloudpi/commit/865ad08) (2018-06-19) fix mysqld service named mysql

[v0.57.5 ](https://github.com/nextcloud/nextcloudpi/commit/1a9a53f) (2018-06-18) fix nextcloud-domain running before default GW is ready

[v0.57.4 ](https://github.com/nextcloud/nextcloudpi/commit/9210fb2) (2018-06-18) letsencrypt: install from debian package

[v0.57.3 ](https://github.com/nextcloud/nextcloudpi/commit/5aa071e) (2018-06-18) armbian: default to SSH disabled

[v0.57.2 ](https://github.com/nextcloud/nextcloudpi/commit/7b2737b) (2018-06-18) nc-static-IP: autodetect default interface

[v0.57.1 ](https://github.com/nextcloud/nextcloudpi/commit/7ac1847) (2018-06-18) docker: replace systemd for service

[v0.57.0 ](https://github.com/nextcloud/nextcloudpi/commit/676776f) (2018-06-18) update to NC 13.0.4

[v0.56.25](https://github.com/nextcloud/nextcloudpi/commit/57852ad) (2018-06-18) nc-snapshot-sync: upgrade

[v0.56.24](https://github.com/nextcloud/nextcloudpi/commit/0d7ceb5) (2018-06-18) nc-datadir: make sure we have the correct permissions

[v0.56.23](https://github.com/nextcloud/nextcloudpi/commit/005ed80) (2018-06-18) nc-info: fix typo

[v0.56.22](https://github.com/nextcloud/nextcloudpi/commit/cef7cb4) (2018-06-14) nc-restore: fix redis restart in docker

[v0.56.21](https://github.com/nextcloud/nextcloudpi/commit/598e1c8) (2018-06-11) docker: persist SSL certificates

[v0.56.20](https://github.com/nextcloud/nextcloudpi/commit/75cfd80) (2018-06-11) ncp-web: fix sanitization for fail2ban

[v0.56.19](https://github.com/nextcloud/nextcloudpi/commit/b78c9e2) (2018-06-06) add ncc command, shortcut of occ

[v0.56.18](https://github.com/nextcloud/nextcloudpi/commit/412eee2) (2018-06-06) NFS: fix dependency with automount

[v0.56.17](https://github.com/nextcloud/nextcloudpi/commit/05c14ce) (2018-06-04) ncp-web: sanitize the ref parameter

[v0.56.16](https://github.com/nextcloud/nextcloudpi/commit/3862eca) (2018-05-29) build: fix cleanup armbian images

[v0.56.15](https://github.com/nextcloud/nextcloudpi/commit/b45e68f) (2018-05-28) ncp-web: added chinese translations

[v0.56.14](https://github.com/nextcloud/nextcloudpi/commit/a070860) (2018-05-27) re-rename to NCPi

[v0.56.13](https://github.com/nextcloud/nextcloudpi/commit/003c29c) (2018-05-28) spDYN: install curl for docker

[v0.56.12](https://github.com/nextcloud/nextcloudpi/commit/ed0a368) (2018-05-28) nc-format-USB: fix when ZRAM active

[v0.56.11](https://github.com/nextcloud/nextcloudpi/commit/fae7ba2) (2018-05-27) ncp-config: silence connectivity errors

[v0.56.10](https://github.com/nextcloud/nextcloudpi/commit/027a2a0) (2018-05-25) nc-ramlogs: fix docker installation from latest upstream changes

[v0.56.9 ](https://github.com/nextcloud/nextcloudpi/commit/438e73d) (2018-05-24) remove old systemd timer config in running systems

[v0.56.8 ](https://github.com/nextcloud/nextcloudpi/commit/9e8fc92) (2018-05-22) fix php cli tmpdir for running instances

[v0.56.7 ](https://github.com/nextcloud/nextcloudpi/commit/061d2ae) (2018-05-22) move NC httpd logs to /var/log

[v0.56.6 ](https://github.com/nextcloud/nextcloudpi/commit/fac99a6) (2018-05-20) fix update httpd log location in virtual host after nc-datadir

[v0.56.5 ](https://github.com/nextcloud/nextcloudpi/commit/c97acf8) (2018-05-20) ncp-autoupdate: dont return 0 if no updates available

[v0.56.4 ](https://github.com/nextcloud/nextcloudpi/commit/cd32b30) (2018-05-18) nc-info: change port checker providers

[v0.56.3 ](https://github.com/nextcloud/nextcloudpi/commit/f04de1f) (2018-05-17) nc-update-nextcloud: make sure backup syncs to disk

[v0.56.2 ](https://github.com/nextcloud/nextcloudpi/commit/741e79a) (2018-05-15) nc-restore: refuse to restore from /var/www/nextcloud

[v0.56.1 ](https://github.com/nextcloud/nextcloudpi/commit/88dcfef) (2018-05-15) nc-update-nextcloud: rollback in case of power cut

[v0.56.0 ](https://github.com/nextcloud/nextcloudpi/commit/9bd6f81) (2018-05-15) added nc-autoupdate-nc

[v0.55.4 ](https://github.com/nextcloud/nextcloudpi/commit/ee92111) (2018-05-15) nc-autoupdate-ncp: fix wrong user

[v0.55.3 ](https://github.com/nextcloud/nextcloudpi/commit/191ea16) (2018-05-15) nc-update-netcloud: include version in backup name

[v0.55.2 ](https://github.com/nextcloud/nextcloudpi/commit/2507cc6) (2018-05-15) nc-backup: faster free space calculation. Minimize maintenance mode time

[v0.55.1 ](https://github.com/nextcloud/nextcloudpi/commit/5e3da08) (2018-05-14) nc-backup: exclude ncp-update-nc backups

[v0.55.0 ](https://github.com/nextcloud/nextcloudpi/commit/8d01fc4) (2018-05-11) added nc-update-nextcloud

[v0.54.14](https://github.com/nextcloud/nextcloudpi/commit/8ef0881) (2018-05-14) samba: fix permissions

[v0.54.13](https://github.com/nextcloud/nextcloudpi/commit/b08e45f) (2018-05-11) nc-nextcloud: fix upload tmp dir

[v0.54.12](https://github.com/nextcloud/nextcloudpi/commit/eb1cf1a) (2018-05-11) nc-restore: fix tmp dirs in backups without data

[v0.54.11](https://github.com/nextcloud/nextcloudpi/commit/40a8431) (2018-05-11) nc-backup: make more robust to unexpected failure

[v0.54.10](https://github.com/nextcloud/nextcloudpi/commit/2ef575c) (2018-05-11) nc-restore: make more robust to unexpected failure

[v0.54.9 ](https://github.com/nextcloud/nextcloudpi/commit/b93aec5) (2018-05-11) nc-restore: separate in its own executable

[v0.54.8 ](https://github.com/nextcloud/nextcloudpi/commit/dbc3094) (2018-05-10) nc-backup: better avoid duplicates

[v0.54.7 ](https://github.com/nextcloud/nextcloudpi/commit/5dca250) (2018-05-10) armbian: fix static IP

[v0.54.6 ](https://github.com/nextcloud/nextcloudpi/commit/09741e1) (2018-05-10) nc-notify-updates: fix wrong user

[v0.54.5 ](https://github.com/nextcloud/nextcloudpi/commit/688d6d8) (2018-05-10) armbian: fix mDNS

[v0.54.4 ](https://github.com/nextcloud/nextcloudpi/commit/63f83da) (2018-05-09) avoid temp dir vulnerabilities

[v0.54.3 ](https://github.com/nextcloud/nextcloudpi/commit/28d2332) (2018-05-03) nc-datadir: avoid using occ for faster execution

[v0.54.2 ](https://github.com/nextcloud/nextcloudpi/commit/73bc22a) (2018-05-03) samba: restart after configuration change

[v0.54.1 ](https://github.com/nextcloud/nextcloudpi/commit/9a6d371) (2018-04-27) nc-snapshot-sync: upgrade

[v0.54.0 ](https://github.com/nextcloud/nextcloudpi/commit/99f1e1e) (2018-04-27) update to NC 13.0.2

[v0.53.33](https://github.com/nextcloud/nextcloudpi/commit/b199121) (2018-04-25) nc-info: provide timeout for wget

[v0.53.32](https://github.com/nextcloud/nextcloudpi/commit/3bb8cad) (2018-04-22) nc-info: check for existance of ncp-baseimage

[v0.53.31](https://github.com/nextcloud/nextcloudpi/commit/20c734b) (2018-04-21) fix double default gateway

[v0.53.30](https://github.com/nextcloud/nextcloudpi/commit/9c600bd) (2018-04-20) ncp-report: fix root execution

[v0.53.29](https://github.com/nextcloud/nextcloudpi/commit/a9458f5) (2018-04-05) renamed to NextCloudPlus

[v0.53.28](https://github.com/nextcloud/nextcloudpi/commit/0d6c780) (2018-04-18) ncp-web: added spanish translations

[v0.53.27](https://github.com/nextcloud/nextcloudpi/commit/20c0d80) (2018-04-09) ncp-web: added language dropdown selector

[v0.53.26](https://github.com/nextcloud/nextcloudpi/commit/a9b37ab) (2018-04-06) nc-automount: remove directories left from unclean shutdown

[v0.53.25](https://github.com/nextcloud/nextcloudpi/commit/7aba9c5) (2018-04-09) build: clean docker-env

[v0.53.24](https://github.com/nextcloud/nextcloudpi/commit/b9116e7) (2018-04-05) ncp-web: faster first load by asynchronous call to is_active()

[v0.53.23](https://github.com/nextcloud/nextcloudpi/commit/7eecd81) (2018-04-05) ncp-web: force reload CSRF tokens every time

[v0.53.22](https://github.com/nextcloud/nextcloudpi/commit/eece4d0) (2018-04-05) ncp-web: collapse sidebar menu when clicking in new sections

[v0.53.21](https://github.com/nextcloud/nextcloudpi/commit/6031440) (2018-04-05) ncp-web: make config.php into a table

[v0.53.20](https://github.com/nextcloud/nextcloudpi/commit/16e245c) (2018-04-04) ncp-web: check for updates upon first run

[v0.53.19](https://github.com/nextcloud/nextcloudpi/commit/8a2d30a) (2018-04-04) ncp-web: replace textarea with div for output

[v0.53.18](https://github.com/nextcloud/nextcloudpi/commit/4f321cc) (2018-04-04) ncp-web: refresh sidebar after launching actions

[v0.53.17](https://github.com/nextcloud/nextcloudpi/commit/e652777) (2018-04-04) ncp-web: reload ncp-web after nc-update

[v0.53.16](https://github.com/nextcloud/nextcloudpi/commit/df9e09e) (2018-04-04) ncp-web: implement is_active()

[v0.53.15](https://github.com/nextcloud/nextcloudpi/commit/490d84d) (2018-04-04) docker: add column command

[v0.53.14](https://github.com/nextcloud/nextcloudpi/commit/fb2ad5d) (2018-04-04) ncp-web: fix scroll bar

[v0.53.13](https://github.com/nextcloud/nextcloudpi/commit/e559f74) (2018-04-04) ncp-web: fix ncp-app selection

[v0.53.12](https://github.com/nextcloud/nextcloudpi/commit/30da787) (2018-04-03) ncp-web: added nc-config and helper buttons

[v0.53.11](https://github.com/nextcloud/nextcloudpi/commit/d133c73) (2018-04-03) ncp-web: fix glitch showing power dialog

[v0.53.10](https://github.com/nextcloud/nextcloudpi/commit/fa1ec75) (2018-04-03) ncp-web: implement dashboard

[v0.53.9 ](https://github.com/nextcloud/nextcloudpi/commit/d79e10a) (2018-04-02) SSH: stop service upon activation

[v0.53.8 ](https://github.com/nextcloud/nextcloudpi/commit/ca66dac) (2018-04-02) ncp-web: fix update notification

[v0.53.7 ](https://github.com/nextcloud/nextcloudpi/commit/925c6fe) (2018-03-29) ncp-web: use random passwords for NC and ncp-web

[v0.53.6 ](https://github.com/nextcloud/nextcloudpi/commit/f1bbf57) (2018-03-27) samba: dont force NAME_REGEX for username

[v0.53.5 ](https://github.com/nextcloud/nextcloudpi/commit/062438b) (2018-03-20) NFS: check user and group existence

[v0.53.4 ](https://github.com/nextcloud/nextcloudpi/commit/1830d77) (2018-03-18) nc-ramlogs: fix enabled by default upon installoation

[v0.53.3 ](https://github.com/nextcloud/nextcloudpi/commit/423ea0e) (2018-03-17) docker: fix development container script folder

[v0.53.2 ](https://github.com/nextcloud/nextcloudpi/commit/85127d7) (2018-03-17) letsencrypt: remove .well-known dir after renewal

[v0.53.1 ](https://github.com/nextcloud/nextcloudpi/commit/30f5756) (2018-03-17) fix web update to NC13.0.1 with .well-known existence

[v0.53.0 ](https://github.com/nextcloud/nextcloudpi/commit/436cd9f) (2018-03-17) update to NC 13.0.1

[v0.52.2 ](https://github.com/nextcloud/nextcloudpi/commit/1f81611) (2018-03-17) build: small script adjustments

[v0.52.1 ](https://github.com/nextcloud/nextcloudpi/commit/c6aeb4e) (2018-03-16) docker: include nc-webui

[v0.52.0 ](https://github.com/nextcloud/nextcloudpi/commit/ed26128) (2018-03-12) added nc-rsync-auto

[v0.51.0 ](https://github.com/nextcloud/nextcloudpi/commit/26c88d0) (2018-03-12) added nc-rsync

[v0.50.0 ](https://github.com/nextcloud/nextcloudpi/commit/84f27f2) (2018-03-12) added nc-snapshot-sync

[v0.47.4 ](https://github.com/nextcloud/nextcloudpi/commit/4ed6b52) (2018-03-14) Add template generation functionality to L10N.php (activate by setting constant GENERATE_TEMPLATES to true).

[v0.47.3 ](https://github.com/nextcloud/nextcloudpi/commit/38dfa60) (2018-03-16) fix for nc-automount-links

[v0.47.2 ](https://github.com/nextcloud/nextcloudpi/commit/b3be948) (2018-03-15) improve dependency of database with automount

[v0.47.1 ](https://github.com/nextcloud/nextcloudpi/commit/2c1f8b4) (2018-03-10) update: make sure redis log exists

[v0.47.0 ](https://github.com/nextcloud/nextcloudpi/commit/7a3976b) (2018-03-05) added nc-zram

[v0.46.40](https://github.com/nextcloud/nextcloudpi/commit/1c23fa7) (2018-03-04) nc-backup-auto: change to using cron

[v0.46.39](https://github.com/nextcloud/nextcloudpi/commit/e912749) (2018-03-04) nc-ramlogs: change implementation to use log2ram

[v0.46.38](https://github.com/nextcloud/nextcloudpi/commit/b346cbe) (2018-03-04) disable ncp user login

[v0.46.37](https://github.com/nextcloud/nextcloudpi/commit/18e35df) (2018-03-03) nc-automount: fix dependencies

[v0.46.36](https://github.com/nextcloud/nextcloudpi/commit/45a8800) (2018-03-03) build: fix systemd dir not existing

[v0.46.35](https://github.com/nextcloud/nextcloudpi/commit/1a7c8b9) (2018-02-26) ncp-web: add localization (#372)

[v0.46.34](https://github.com/nextcloud/nextcloudpi/commit/c4a111c) (2018-02-26) ncp-web: fix responsive in iPad

[v0.46.33](https://github.com/nextcloud/nextcloudpi/commit/9f819f4) (2018-02-23) Added some useful comments for first time users

[v0.46.32](https://github.com/nextcloud/nextcloudpi/commit/e3a19b9) (2018-02-23) disable unused services for SMB and NFS

[v0.46.31](https://github.com/nextcloud/nextcloudpi/commit/d3c7354) (2018-02-23) update: print info first

[v0.46.30](https://github.com/nextcloud/nextcloudpi/commit/36a803f) (2018-02-22) add ncp-provisioning to SD card images

[v0.46.29](https://github.com/nextcloud/nextcloudpi/commit/d05b069) (2018-02-22) ncp-web: fix overlay z-index

[v0.46.28](https://github.com/nextcloud/nextcloudpi/commit/0d6ad68) (2018-02-22) wizard: fix logbox overflow

[v0.46.27](https://github.com/nextcloud/nextcloudpi/commit/d2318a4) (2018-02-20) wizard: animate side logs

[v0.46.26](https://github.com/nextcloud/nextcloudpi/commit/6dd70a7) (2018-02-21) ncp-web: animate script textbox

[v0.46.25](https://github.com/nextcloud/nextcloudpi/commit/8389ac7) (2018-02-21) ncp-web: fix backend request without arguments

[v0.46.24](https://github.com/nextcloud/nextcloudpi/commit/8d100b9) (2018-02-21) ncp-web: link to wizard and Nextcloud instance

[v0.46.23](https://github.com/nextcloud/nextcloudpi/commit/63b74a8) (2018-02-19) ncp-web: support for small screens

[v0.46.22](https://github.com/nextcloud/nextcloudpi/commit/bf4d2fc) (2018-02-19) UFW: make it work with nc-forward-ports

[v0.46.21](https://github.com/nextcloud/nextcloudpi/commit/94bd3b9) (2018-02-19) docker: use docker networks for x86

[v0.46.20](https://github.com/nextcloud/nextcloudpi/commit/a9a1809) (2018-02-15) random password provisioning on boot/startup

[v0.46.19](https://github.com/nextcloud/nextcloudpi/commit/648f53b) (2018-02-18) ncp-web: re-style poweroff menu

[v0.46.18](https://github.com/nextcloud/nextcloudpi/commit/7d03e84) (2018-02-18) ncp-web: disable event handler after poweroff

[v0.46.17](https://github.com/nextcloud/nextcloudpi/commit/f1d41e3) (2018-02-10) Add dialog for shutdown.

[v0.46.16](https://github.com/nextcloud/nextcloudpi/commit/26afda9) (2018-02-16) remove redundant configuration from unattended upgrades

[v0.46.15](https://github.com/nextcloud/nextcloudpi/commit/8546ea6) (2018-02-16) lamp: enhance SSL security (chacha cypher), and OCSP stapling

[v0.46.14](https://github.com/nextcloud/nextcloudpi/commit/f8381f4) (2018-02-16) log all NCP actions to /var/log/ncp.log

[v0.46.13](https://github.com/nextcloud/nextcloudpi/commit/51b1e5d) (2018-02-16) update: accept github branch as an argument to ncp-update to test development branch

[v0.46.12](https://github.com/nextcloud/nextcloudpi/commit/67a4093) (2018-02-15) lamp: protect apache fingerprinting

[v0.46.11](https://github.com/nextcloud/nextcloudpi/commit/875ce59) (2018-02-15) SSH: dont create user if it doesnt exist

[v0.46.10](https://github.com/nextcloud/nextcloudpi/commit/cac81ec) (2018-02-09) samba: create share per NC user

[v0.46.9 ](https://github.com/nextcloud/nextcloudpi/commit/30a8bdd) (2018-02-13) letsencrypt: only call update-rc.d in docker builds

[v0.46.8 ](https://github.com/nextcloud/nextcloudpi/commit/34a3bd5) (2018-02-12) preactivate useful apps for a selfhosted instance

[v0.46.7 ](https://github.com/nextcloud/nextcloudpi/commit/c14b056) (2018-02-12) update: fix typo in check version

[v0.46.6 ](https://github.com/nextcloud/nextcloudpi/commit/dc88dcb) (2018-02-08) Update ncp-check-version

[v0.46.5 ](https://github.com/nextcloud/nextcloudpi/commit/3b458f3) (2018-02-09) nc-backup: stronger permissions for backup file

[v0.46.4 ](https://github.com/nextcloud/nextcloudpi/commit/fc0d3f9) (2018-02-08) do not rely on pings, just return value of operations

[v0.46.3 ](https://github.com/nextcloud/nextcloudpi/commit/ab86551) (2018-02-07) unattended upgrades: fix unattended upgrades not working because of modified files

[v0.46.2 ](https://github.com/nextcloud/nextcloudpi/commit/91eeeea) (2018-02-07) modsecurity: turn off logging, its too spammy for ramlogs

[v0.46.1 ](https://github.com/nextcloud/nextcloudpi/commit/d7f253e) (2018-02-07) ping to 4.2.2.2 because google is blocked in china

[v0.46.0 ](https://github.com/nextcloud/nextcloudpi/commit/64f9673) (2018-02-06) update to NC 13.0.0

[v0.45.4 ](https://github.com/nextcloud/nextcloudpi/commit/048ee6a) (2018-02-06) added ncp-config link to nextcloudpi-config

[v0.45.3 ](https://github.com/nextcloud/nextcloudpi/commit/257787a) (2018-02-05) lamp: add ldap support (#377)

[v0.45.2 ](https://github.com/nextcloud/nextcloudpi/commit/4dce600) (2018-02-05) nc-nextcloud: fixes for beta versions

[v0.45.1 ](https://github.com/nextcloud/nextcloudpi/commit/67b12bb) (2018-02-05) nc-backup: fixes in checking space and auto

[v0.45.0 ](https://github.com/nextcloud/nextcloudpi/commit/ec40fe6) (2018-02-03) update to NC 12.0.5

[v0.44.15](https://github.com/nextcloud/nextcloudpi/commit/85742a5) (2018-01-10) nc-init and samba: default to ncp user

[v0.44.14](https://github.com/nextcloud/nextcloudpi/commit/978781c) (2018-01-10) nc-ramlogs: limit tmpfs to 100M

[v0.44.13](https://github.com/nextcloud/nextcloudpi/commit/7d105f8) (2018-01-10) letsencrypt: revert pip.conf pre-workaround, tweak cron

[v0.44.12](https://github.com/nextcloud/nextcloudpi/commit/db322f2) (2018-01-10) nc-swapfile: improved, and take BTRFS into account

[v0.44.11](https://github.com/nextcloud/nextcloudpi/commit/0587ca3) (2018-01-07) nc-restore: check validity of backup file

[v0.44.10](https://github.com/nextcloud/nextcloudpi/commit/614c57d) (2018-01-07) nc-restore: refresh trusted domains

[v0.44.9 ](https://github.com/nextcloud/nextcloudpi/commit/0972d57) (2018-01-07) nc-restore: fix bug detecting data

[v0.44.8 ](https://github.com/nextcloud/nextcloudpi/commit/459fe39) (2018-01-06) nc-restore: restore to a btrfs subvolume

[v0.44.7 ](https://github.com/nextcloud/nextcloudpi/commit/3beff63) (2018-01-06) nc-backup: make binary work standalone

[v0.44.6 ](https://github.com/nextcloud/nextcloudpi/commit/f63a353) (2018-01-05) nc-restore: restore compressed backups

[v0.44.5 ](https://github.com/nextcloud/nextcloudpi/commit/54631e2) (2018-01-04) nc-backup: compress backups and refactoring

[v0.44.4 ](https://github.com/nextcloud/nextcloudpi/commit/a1a2f51) (2018-01-03) nc-restore: update redis password

[v0.44.3 ](https://github.com/nextcloud/nextcloudpi/commit/fd71cb6) (2018-01-03) nc-export: protect file from read

[v0.44.2 ](https://github.com/nextcloud/nextcloudpi/commit/2687fdb) (2018-01-01) nc-snapshot: update btrfs-snp

[v0.44.1 ](https://github.com/nextcloud/nextcloudpi/commit/6fb4fef) (2017-12-28) nc-snapshot: use btrfs-snp

[v0.44.0 ](https://github.com/nextcloud/nextcloudpi/commit/9e1da02) (2017-12-28) added nc-snapshot-auto

[v0.43.3 ](https://github.com/nextcloud/nextcloudpi/commit/e10dd39) (2017-12-26) nc-datadir: use clone on btrfs systems

[v0.43.2 ](https://github.com/nextcloud/nextcloudpi/commit/803a1f1) (2017-12-19) UFW: prettier output

[v0.43.1 ](https://github.com/nextcloud/nextcloudpi/commit/66e50d8) (2017-12-19) ncp-config: validate input

[v0.43.0 ](https://github.com/nextcloud/nextcloudpi/commit/c0a9997) (2017-12-18) added nc-audit

[v0.42.0 ](https://github.com/nextcloud/nextcloudpi/commit/71f676e) (2017-12-18) added UFW

[v0.41.13](https://github.com/nextcloud/nextcloudpi/commit/34fc851) (2017-12-17) security hardening part 3

[v0.41.12](https://github.com/nextcloud/nextcloudpi/commit/af54edb) (2017-12-17) security hardening part 2

[v0.41.11](https://github.com/nextcloud/nextcloudpi/commit/bd5cb8e) (2017-12-16) security hardening

[v0.41.10](https://github.com/nextcloud/nextcloudpi/commit/85c8722) (2017-12-16) dnsmasq: added interface

[v0.41.9 ](https://github.com/nextcloud/nextcloudpi/commit/4b07f0b) (2017-12-14) fix occ command without execute permissions

[v0.41.8 ](https://github.com/nextcloud/nextcloudpi/commit/3f09cd5) (2017-12-13) Fixed configuration interoperability between nc-datadit and fail2ban. (#323)

[v0.41.7 ](https://github.com/nextcloud/nextcloudpi/commit/f7030f5) (2017-12-12) replace ping to github.com to google.com

[v0.41.6 ](https://github.com/nextcloud/nextcloudpi/commit/3fedf4f) (2017-12-05) ncp-config: show changelog on updates

[v0.41.5 ](https://github.com/nextcloud/nextcloudpi/commit/3896b7f) (2017-12-05) nc-database: accept BTRFS filesystems

[v0.41.4 ](https://github.com/nextcloud/nextcloudpi/commit/3c85b80) (2017-11-29) nc-limits: added PHP threads and Redis mem limits

[v0.41.3 ](https://github.com/nextcloud/nextcloudpi/commit/30c34d8) (2017-12-05) SSH: enhance security

[v0.41.2 ](https://github.com/nextcloud/nextcloudpi/commit/030bbed) (2017-12-04) nc-automount: check for USBdrive labeled drive case

[v0.41.1 ](https://github.com/nextcloud/nextcloudpi/commit/29da1b5) (2017-12-04) nc-info: warn of long operation

[v0.41.0 ](https://github.com/nextcloud/nextcloudpi/commit/ad26b87) (2017-12-04) updated to NC12.0.4

[v0.40.0 ](https://github.com/nextcloud/nextcloudpi/commit/d40360c) (2017-12-03) added btrfs snapshots

[v0.39.3 ](https://github.com/nextcloud/nextcloudpi/commit/7726f09) (2017-11-29) nc-export: silent cd

[v0.39.2 ](https://github.com/nextcloud/nextcloudpi/commit/7aaf31c) (2017-11-29) nc-import: fix ncp-web appearing to fail when activating options that restart httpd

[v0.39.1 ](https://github.com/nextcloud/nextcloudpi/commit/1e2de68) (2017-11-28) motd: update logo

[v0.39.0 ](https://github.com/nextcloud/nextcloudpi/commit/f8b328e) (2017-11-27) added nc-export-ncp and nc-import-ncp

[v0.38.1 ](https://github.com/nextcloud/nextcloudpi/commit/6c7cd4b) (2017-11-27) nc-info: warn distro

[v0.38.0 ](https://github.com/nextcloud/nextcloudpi/commit/58d4ca6) (2017-11-27) added SSH

[v0.37.5 ](https://github.com/nextcloud/nextcloudpi/commit/39064cc) (2017-11-25) nc-info: provide suggestions

[v0.37.4 ](https://github.com/nextcloud/nextcloudpi/commit/5d7188e) (2017-11-25) dnsmasq: improve output

[v0.37.3 ](https://github.com/nextcloud/nextcloudpi/commit/86ab526) (2017-11-24) build: fix cleanup

[v0.37.2 ](https://github.com/nextcloud/nextcloudpi/commit/2c884b7) (2017-11-20) nc-datadir: dont create dir if not exists

[v0.37.1 ](https://github.com/nextcloud/nextcloudpi/commit/dd1d6e6) (2017-11-19) nc-restore: fix restore passwod

[v0.37.0 ](https://github.com/nextcloud/nextcloudpi/commit/de4e0c7) (2017-11-19) added nc-info

[v0.36.2 ](https://github.com/nextcloud/nextcloudpi/commit/d1e529e) (2017-11-19) nc-diag: small fixes

[v0.36.1 ](https://github.com/nextcloud/nextcloudpi/commit/c1eb908) (2017-11-18) update: fix return value

[v0.36.0 ](https://github.com/nextcloud/nextcloudpi/commit/ede912f) (2017-11-18) added ncp-diag and ncp-report

[v0.35.2 ](https://github.com/nextcloud/nextcloudpi/commit/2c25fa9) (2017-11-17) nextcloudpi-config: inform changelog

[v0.35.1 ](https://github.com/nextcloud/nextcloudpi/commit/bccbb5b) (2017-11-17) nc-datadir: make backup if non empty

[v0.35.0 ](https://github.com/nextcloud/nextcloudpi/commit/75fe8d4) (2017-11-17) added nc-passwd

[v0.34.16](https://github.com/nextcloud/nextcloudpi/commit/370fc74) (2017-11-17) nc-datadir: refuse to move to SD card

[v0.34.15](https://github.com/nextcloud/nextcloudpi/commit/ba76566) (2017-11-16) update: check existence ncp.conf

[v0.34.14](https://github.com/nextcloud/nextcloudpi/commit/95240ca) (2017-11-16) update: check return code

[v0.34.13](https://github.com/nextcloud/nextcloudpi/commit/7e126fd) (2017-11-16) improve IP detection

[v0.34.12](https://github.com/nextcloud/nextcloudpi/commit/ac9989d) (2017-11-16) fail2ban: fix accidentally deleted line

[v0.34.11](https://github.com/nextcloud/nextcloudpi/commit/509206c) (2017-11-15) ncp-web: only show wizard button if it exists, delete from  docker

[v0.34.10](https://github.com/nextcloud/nextcloudpi/commit/dc2ddd7) (2017-11-14) noip: fix return value

[v0.34.9 ](https://github.com/nextcloud/nextcloudpi/commit/a7af6e4) (2017-11-12) nc-nextcloud: restart php after redis

[v0.34.8 ](https://github.com/nextcloud/nextcloudpi/commit/88815bb) (2017-11-12) nc-init: install notifications

[v0.34.7 ](https://github.com/nextcloud/nextcloudpi/commit/c2143b9) (2017-11-12) redis: fix update bug

[v0.34.6 ](https://github.com/nextcloud/nextcloudpi/commit/a71ec05) (2017-11-11) redis: fix socket permissions

[v0.34.5 ](https://github.com/nextcloud/nextcloudpi/commit/10488be) (2017-11-10) update: wait running apt processes (fix)

[v0.34.4 ](https://github.com/nextcloud/nextcloudpi/commit/fa5f56e) (2017-11-09) redis: fixes with ramlogs and modsecurity

[v0.34.3 ](https://github.com/nextcloud/nextcloudpi/commit/9657f7f) (2017-11-09) redis: change overcommit memory on update

[v0.34.2 ](https://github.com/nextcloud/nextcloudpi/commit/f557c8d) (2017-11-09) Revert "update: wait running apt processes"

[v0.34.1 ](https://github.com/nextcloud/nextcloudpi/commit/94b7021) (2017-11-09) nc-nextcloud: added more logging

[v0.34.0 ](https://github.com/nextcloud/nextcloudpi/commit/958beef) (2017-11-07) added NCP custom theme with new logo

[v0.33.0 ](https://github.com/nextcloud/nextcloudpi/commit/7e2abc9) (2017-11-06) added redis

[v0.32.7 ](https://github.com/nextcloud/nextcloudpi/commit/1955ece) (2017-11-09) nc-notify-updates: fixes

[v0.32.6 ](https://github.com/nextcloud/nextcloudpi/commit/4329eea) (2017-11-08) noip: manage many interfaces and fix return value

[v0.32.5 ](https://github.com/nextcloud/nextcloudpi/commit/8dbd282) (2017-11-08) update: wait running apt processes

[v0.32.4 ](https://github.com/nextcloud/nextcloudpi/commit/01a33d4) (2017-11-08) fail2ban: update logpath on nc-datadir or nc-restore

[v0.32.3 ](https://github.com/nextcloud/nextcloudpi/commit/963542b) (2017-11-06) nc-notify-updates: rework for more accuracy

[v0.32.2 ](https://github.com/nextcloud/nextcloudpi/commit/fa2279f) (2017-11-04) ncp-web: fix return value

[v0.32.1 ](https://github.com/nextcloud/nextcloudpi/commit/961008c) (2017-11-04) build: replace user pi for user ncp

[v0.32.0 ](https://github.com/nextcloud/nextcloudpi/commit/06294c5) (2017-11-03) spDYN: initial adjustments

[v0.31.29](https://github.com/nextcloud/nextcloudpi/commit/74fd94c) (2017-11-02) ncp-web: fix timeout in long operations

[v0.31.28](https://github.com/nextcloud/nextcloudpi/commit/b27974f) (2017-10-31) build: expand filesystem during first boot

[v0.31.27](https://github.com/nextcloud/nextcloudpi/commit/515b731) (2017-10-31) nc-backup: check available space

[v0.31.26](https://github.com/nextcloud/nextcloudpi/commit/6fdb761) (2017-10-30) build: check ncp-launcher existence for old images

[v0.31.25](https://github.com/nextcloud/nextcloudpi/commit/447585d) (2017-10-29) letsencrypt: remove workaround. fixed upstream

[v0.31.24](https://github.com/nextcloud/nextcloudpi/commit/36af04b) (2017-10-27) nc-forward-ports: more info in output

[v0.31.23](https://github.com/nextcloud/nextcloudpi/commit/a494e69) (2017-10-27) nc-format-USB: more info in output

[v0.31.22](https://github.com/nextcloud/nextcloudpi/commit/0bc5e09) (2017-10-25) wizard: chain configurations and improved feedback

[v0.31.20](https://github.com/nextcloud/nextcloudpi/commit/d8b6eb3) (2017-10-26) nc-notify-updates: fix repeated lines

[v0.31.19](https://github.com/nextcloud/nextcloudpi/commit/2f1a9c9) (2017-10-25) samba: disable homes share by default

[v0.31.18](https://github.com/nextcloud/nextcloudpi/commit/84a2d61) (2017-10-25) letsencrypt: fix return value

[v0.31.17](https://github.com/nextcloud/nextcloudpi/commit/8f54ff7) (2017-10-25) noip: make possible to reconfigure while running

[v0.31.16](https://github.com/nextcloud/nextcloudpi/commit/4c7e562) (2017-10-22) freeDNS: fix periodic update typo

[v0.31.15](https://github.com/nextcloud/nextcloudpi/commit/7ffc801) (2017-10-19) ncp-web: improve password prompt permissions

[v0.31.14](https://github.com/nextcloud/nextcloudpi/commit/bd74eb4) (2017-10-09) ncp-web: integrate ncp-wizard with ncp-web

[v0.31.13](https://github.com/nextcloud/nextcloudpi/commit/a5ce511) (2017-10-07) letsencrypt: fix workaround for old images

[v0.31.12](https://github.com/nextcloud/nextcloudpi/commit/dcbafb2) (2017-10-05) fail2ban: email notification (Closes #232)

[v0.31.11](https://github.com/nextcloud/nextcloudpi/commit/a4e5df7) (2017-10-04) nc-backup: fix excludes

[v0.31.10](https://github.com/nextcloud/nextcloudpi/commit/c00e1e9) (2017-10-04) nc-forward-ports: exit status on failure

[v0.31.9 ](https://github.com/nextcloud/nextcloudpi/commit/6eab4ff) (2017-10-03) nc-wifi: improve instructions

[v0.31.8 ](https://github.com/nextcloud/nextcloudpi/commit/6e129da) (2017-09-30) ncp-web: small fixes

[v0.31.7 ](https://github.com/nextcloud/nextcloudpi/commit/99126b6) (2017-10-03) letsencrypt: dont change config if not successful

[v0.31.6 ](https://github.com/nextcloud/nextcloudpi/commit/9623e48) (2017-10-03) letsencrypt: fix external bug (Closes #230)

[v0.31.5 ](https://github.com/nextcloud/nextcloudpi/commit/ba9d6fd) (2017-09-30) nc-format-USB: fix format disks >2TB and more (Closes #223)

[v0.31.4 ](https://github.com/nextcloud/nextcloudpi/commit/cfcb535) (2017-09-30) nc-format-USB: speed up ext4 creation with lazy initialization

[v0.31.3 ](https://github.com/nextcloud/nextcloudpi/commit/b2500f3) (2017-09-30) letsencrypt: fix uppercase domains cert path (Closes #229)

[v0.31.2 ](https://github.com/nextcloud/nextcloudpi/commit/2f83da0) (2017-09-30) ncp-web: remove http2 push headers. They dont play well with pwauth (#224)

[v0.31.1 ](https://github.com/nextcloud/nextcloudpi/commit/8c590e9) (2017-09-28) nc-static-IP: fix occ path

[v0.31.0 ](https://github.com/nextcloud/nextcloudpi/commit/5b50ec3) (2017-09-27) wizard: connect backend with frontend. Modifications for first release

[v0.30.0 ](https://github.com/nextcloud/nextcloudpi/commit/0c535b5) (2017-09-25) reviewed duckDNS: small adaptations

[v0.29.4 ](https://github.com/nextcloud/nextcloudpi/commit/192a9fc) (2017-09-23) nc-backup: apply limit before backup

[v0.29.3 ](https://github.com/nextcloud/nextcloudpi/commit/3a5cc3f) (2017-09-24) ncp-web: authentication fixes

[v0.29.2 ](https://github.com/nextcloud/nextcloudpi/commit/786728c) (2017-09-20) changed hostname

[v0.29.1 ](https://github.com/nextcloud/nextcloudpi/commit/a42e379) (2017-09-20) lamp: add fileinfo mcrypt packages

[v0.29.0 ](https://github.com/nextcloud/nextcloudpi/commit/189e34b) (2017-09-20) updated to NC12.0.3

[v0.28.2 ](https://github.com/nextcloud/nextcloudpi/commit/c141989) (2017-09-18) ncp-web: point changelog to master

[v0.28.1 ](https://github.com/nextcloud/nextcloudpi/commit/019c2f0) (2017-09-15) nc-static-IP: add new IP to trusted domain

[v0.28.0 ](https://github.com/nextcloud/nextcloudpi/commit/bd79fb9) (2017-09-14) added nc-static-IP

[v0.27.0 ](https://github.com/nextcloud/nextcloudpi/commit/111cc78) (2017-09-14) added nc-fix-permissions

[v0.26.32](https://github.com/nextcloud/nextcloudpi/commit/bb91d83) (2017-09-12) split library.sh

[v0.26.31](https://github.com/nextcloud/nextcloudpi/commit/020cfdc) (2017-09-12) fail2ban: autodetect log path

[v0.26.30](https://github.com/nextcloud/nextcloudpi/commit/c982deb) (2017-09-11) ncp-web: fix php exec with background restarting of processes

[v0.26.29](https://github.com/nextcloud/nextcloudpi/commit/c20649d) (2017-09-11) remove config txt output

[v0.26.28](https://github.com/nextcloud/nextcloudpi/commit/ef402e7) (2017-09-08) nc-backup: small fixes

[v0.26.27](https://github.com/nextcloud/nextcloudpi/commit/1630425) (2017-09-10) ncp-web: link to wiki info for each extra

[v0.26.26](https://github.com/nextcloud/nextcloudpi/commit/cdad339) (2017-09-10) ncp-web: minor tweaks

[v0.26.25](https://github.com/nextcloud/nextcloudpi/commit/60711f3) (2017-09-10) ncp-web: click version for changelog. click new version notification to nc-update

[v0.26.24](https://github.com/nextcloud/nextcloudpi/commit/1da6b12) (2017-09-10) nc-format-USB: silent mkfs output

[v0.26.23](https://github.com/nextcloud/nextcloudpi/commit/70aac8e) (2017-09-10) ncp-web: display info for each option

[v0.26.22](https://github.com/nextcloud/nextcloudpi/commit/1f055f8) (2017-09-09) nc-format-USB: adjust to the new automount system

[v0.26.21](https://github.com/nextcloud/nextcloudpi/commit/82d72e9) (2017-09-08) tag images

[v0.26.20](https://github.com/nextcloud/nextcloudpi/commit/4a0a182) (2017-09-08) backend: is_active() functionality

[v0.26.19](https://github.com/nextcloud/nextcloudpi/commit/6e63b55) (2017-09-08) letsencrypt: occ path fix

[v0.26.18](https://github.com/nextcloud/nextcloudpi/commit/e7e0786) (2017-09-07) refactor show_info(), make it only depend on variables

[v0.26.17](https://github.com/nextcloud/nextcloudpi/commit/74c8d95) (2017-09-07) ncp-web: link to changelog

[v0.26.16](https://github.com/nextcloud/nextcloudpi/commit/4d01fd8) (2017-09-06) added sendmail and mail configuration

[v0.26.15](https://github.com/nextcloud/nextcloudpi/commit/abe0ee7) (2017-09-06) disable not needed apache modules

[v0.26.14](https://github.com/nextcloud/nextcloudpi/commit/21832c1) (2017-09-06) modsecurity: fix in Stretch

[v0.26.13](https://github.com/nextcloud/nextcloudpi/commit/b5f037e) (2017-09-06) apache: set default Servername

[v0.26.12](https://github.com/nextcloud/nextcloudpi/commit/14dcde4) (2017-09-06) nc-automount: more logging and safety delay

[v0.26.11](https://github.com/nextcloud/nextcloudpi/commit/ce42e1a) (2017-09-05) nc-automount: small fix

[v0.26.10](https://github.com/nextcloud/nextcloudpi/commit/a5beae8) (2017-09-05) nc-autoupdate-ncp: ability to choose the user to notify

[v0.26.9 ](https://github.com/nextcloud/nextcloudpi/commit/4c70d15) (2017-09-04) cleanup: dont disable ssh in extras, only in nextcloudpi.sh

[v0.26.8 ](https://github.com/nextcloud/nextcloudpi/commit/00e8c77) (2017-09-04) samba: always use NC datadir

[v0.26.7 ](https://github.com/nextcloud/nextcloudpi/commit/4074eda) (2017-09-04) samba: disable SMB1

[v0.26.6 ](https://github.com/nextcloud/nextcloudpi/commit/6a2dd48) (2017-09-04) ncp-web: disable PHP restart in update, (doesnt work) (#176)

[v0.26.5 ](https://github.com/nextcloud/nextcloudpi/commit/997f610) (2017-09-04) unattended upgrades: delete default config in stretch

[v0.26.4 ](https://github.com/nextcloud/nextcloudpi/commit/87b1509) (2017-09-03) nc-automount: small fix

[v0.26.3 ](https://github.com/nextcloud/nextcloudpi/commit/0b28b96) (2017-09-03) freeDNS: fix

[v0.26.2 ](https://github.com/nextcloud/nextcloudpi/commit/88a7d5e) (2017-09-03) nc-automount: improve links more

[v0.26.1 ](https://github.com/nextcloud/nextcloudpi/commit/5f943ac) (2017-09-02) freeDNS: fixes

[v0.26.0 ](https://github.com/nextcloud/nextcloudpi/commit/dd08a39) (2017-09-01) Add FreeDNS client installation for Raspbian

[v0.25.2 ](https://github.com/nextcloud/nextcloudpi/commit/3393477) (2017-09-02) nc-automount: improve links

[v0.25.1 ](https://github.com/nextcloud/nextcloudpi/commit/ee74875) (2017-09-01) nc-notify-updates: notify also of unattended upgrades

[v0.25.0 ](https://github.com/nextcloud/nextcloudpi/commit/bb58ac7) (2017-09-01) added nc-webui

[v0.24.18](https://github.com/nextcloud/nextcloudpi/commit/e5790d4) (2017-09-01) fix IP regex

[v0.24.17](https://github.com/nextcloud/nextcloudpi/commit/a695c16) (2017-09-01) nc-notify-updates: allow specifying user

[v0.24.16](https://github.com/nextcloud/nextcloudpi/commit/c4d2e41) (2017-08-31) nc-automount: complete overhaul

[v0.24.15](https://github.com/nextcloud/nextcloudpi/commit/b25fd33) (2017-08-31) cleanup qemu rules

[v0.24.14](https://github.com/nextcloud/nextcloudpi/commit/1a33e38) (2017-08-31) noip: update description

[v0.24.13](https://github.com/nextcloud/nextcloudpi/commit/f492269) (2017-08-31) use always no-install-recommends

[v0.24.12](https://github.com/nextcloud/nextcloudpi/commit/009c82e) (2017-08-31) shellcheck style fixes

[v0.24.11](https://github.com/nextcloud/nextcloudpi/commit/cfc7599) (2017-08-31) nc-backup: exclude opcachedir and logs

[v0.24.10](https://github.com/nextcloud/nextcloudpi/commit/a86efea) (2017-08-31) various extras: check internet connectivity

[v0.24.9 ](https://github.com/nextcloud/nextcloudpi/commit/2c911be) (2017-08-30) nc-automount: small fix

[v0.24.8 ](https://github.com/nextcloud/nextcloudpi/commit/8374a70) (2017-08-30) nc-news: remove it, it is already in the app store

[v0.24.7 ](https://github.com/nextcloud/nextcloudpi/commit/9e212e6) (2017-08-30) fix nextcloud-domain service with ipv6

[v0.24.6 ](https://github.com/nextcloud/nextcloudpi/commit/a8cfd17) (2017-08-29) nc-automount: only modify fstab when active

[v0.24.5 ](https://github.com/nextcloud/nextcloudpi/commit/263e15a) (2017-08-29) adjust max PHP processes

[v0.24.4 ](https://github.com/nextcloud/nextcloudpi/commit/8846df1) (2017-08-29) samba: fix permissions

[v0.24.3 ](https://github.com/nextcloud/nextcloudpi/commit/06a07cb) (2017-08-24) remove special characters from output, for ncp-web

[v0.24.2 ](https://github.com/nextcloud/nextcloudpi/commit/f044c6d) (2017-08-24) ncp-web: use SSE to display process output in real time. Exit status green/red

[v0.24.1 ](https://github.com/nextcloud/nextcloudpi/commit/edccf4a) (2017-08-22) fix fail2ban with stretch

[v0.24.0 ](https://github.com/nextcloud/nextcloudpi/commit/5e711e9) (2017-08-20) update to Raspbian Stretch

[v0.23.0 ](https://github.com/nextcloud/nextcloudpi/commit/3d80632) (2017-08-17) ncp-web: poweroff button

[v0.22.1 ](https://github.com/nextcloud/nextcloudpi/commit/ba95342) (2017-08-17) nc-notify-updates: simplify parameters

[v0.22.0 ](https://github.com/nextcloud/nextcloudpi/commit/53c498b) (2017-08-16) update to nextcloud 12.0.2

[v0.21.2 ](https://github.com/nextcloud/nextcloudpi/commit/e10bf3b) (2017-08-16) nc-notify-updates: only notify once

[v0.21.1 ](https://github.com/nextcloud/nextcloudpi/commit/b95f6d5) (2017-08-16) nc-automount: added info

[v0.21.0 ](https://github.com/nextcloud/nextcloudpi/commit/d638cf9) (2017-08-16) added nc-autoupdate-ncp

[v0.20.4 ](https://github.com/nextcloud/nextcloudpi/commit/8f349c9) (2017-08-16) faster remote updates and version checks

[v0.20.3 ](https://github.com/nextcloud/nextcloudpi/commit/96685c2) (2017-08-15) nc-automount: fixed persistence of links and more

[v0.20.2 ](https://github.com/nextcloud/nextcloudpi/commit/9176473) (2017-08-14) nc-database: fail gracefully if mv fails

[v0.20.1 ](https://github.com/nextcloud/nextcloudpi/commit/7dde92a) (2017-08-14) ncp-web: allow commas

[v0.20.0 ](https://github.com/nextcloud/nextcloudpi/commit/5ebeaf1) (2017-08-12) added nc-notify-updates

[v0.19.11](https://github.com/nextcloud/nextcloudpi/commit/c2ca13e) (2017-08-11) fix version check

[v0.19.10](https://github.com/nextcloud/nextcloudpi/commit/20fea70) (2017-08-11) alert of updates

[v0.19.9 ](https://github.com/nextcloud/nextcloudpi/commit/a0154aa) (2017-08-10) ncp-web: show version

[v0.19.8 ](https://github.com/nextcloud/nextcloudpi/commit/77567c4) (2017-08-10) ncp-web: visually indicate selected extra

[v0.19.7 ](https://github.com/nextcloud/nextcloudpi/commit/08b3e1f) (2017-08-10) ncp-web: active mark

[v0.19.6 ](https://github.com/nextcloud/nextcloudpi/commit/f58ca62) (2017-08-10) nc-restore: inform of existing data backup

[v0.19.5 ](https://github.com/nextcloud/nextcloudpi/commit/b1c3073) (2017-08-10) ncp-web: use checkboxes for yes/no fields

[v0.19.4 ](https://github.com/nextcloud/nextcloudpi/commit/6f74658) (2017-08-10) ncp-web: LAN access restrictions ipv6

[v0.19.3 ](https://github.com/nextcloud/nextcloudpi/commit/390b313) (2017-08-10) nc-restore: dont destroy existing datadir

[v0.19.2 ](https://github.com/nextcloud/nextcloudpi/commit/3dd9945) (2017-08-10) restore from other instance fix

[v0.19.1 ](https://github.com/nextcloud/nextcloudpi/commit/a6b79b4) (2017-08-08) fix web update to NC12.0.1

[v0.19.0 ](https://github.com/nextcloud/nextcloudpi/commit/fc4ea8a) (2017-08-08) update to nextcloud 12.0.1

[v0.18.9 ](https://github.com/nextcloud/nextcloudpi/commit/4ecfccb) (2017-08-08) dont install php-smbclient: breaks samba

[v0.18.8 ](https://github.com/nextcloud/nextcloudpi/commit/bce67d3) (2017-08-08) letsencrypt: info about open ports

[v0.18.7 ](https://github.com/nextcloud/nextcloudpi/commit/744c716) (2017-08-07) stop script if noip config fails

[v0.18.6 ](https://github.com/nextcloud/nextcloudpi/commit/6617f29) (2017-08-01) nc-backup: small fix

[v0.18.5 ](https://github.com/nextcloud/nextcloudpi/commit/d819bbb) (2017-07-31) simplify parameters

[v0.18.4 ](https://github.com/nextcloud/nextcloudpi/commit/c4210c5) (2017-07-31) fix swapfile with automount

[v0.18.3 ](https://github.com/nextcloud/nextcloudpi/commit/6f8d553) (2017-07-31) output some more information in nc-backup-auto and nc-scan-auto

[v0.18.2 ](https://github.com/nextcloud/nextcloudpi/commit/c5c5a8e) (2017-07-31) fix nc-scan-auto

[v0.18.1 ](https://github.com/nextcloud/nextcloudpi/commit/e0d9aea) (2017-07-31) use letsencrypt certificate for ncp-web

[v0.18.0 ](https://github.com/nextcloud/nextcloudpi/commit/182c41a) (2017-07-30) added nc-backup-auto

[v0.17.21](https://github.com/nextcloud/nextcloudpi/commit/74c0f57) (2017-07-30) fix ncadmin password

[v0.17.20](https://github.com/nextcloud/nextcloudpi/commit/6257eb6) (2017-07-30) refactor nc-scan-auto

[v0.17.19](https://github.com/nextcloud/nextcloudpi/commit/90dd8d6) (2017-07-29) backup/restore: include datadir

[v0.17.18](https://github.com/nextcloud/nextcloudpi/commit/530e3a1) (2017-07-29) randomize database password (fixes)

[v0.17.17](https://github.com/nextcloud/nextcloudpi/commit/558e3a5) (2017-07-28) manage overwrite.cli.url

[v0.17.16](https://github.com/nextcloud/nextcloudpi/commit/24ccde4) (2017-07-28) fix smbclient segfault

[v0.17.15](https://github.com/nextcloud/nextcloudpi/commit/6df5f73) (2017-07-27) nc-restore: fix situation opcache dir was moved

[v0.17.14](https://github.com/nextcloud/nextcloudpi/commit/edbfa67) (2017-07-27) randomize database password

[v0.17.13](https://github.com/nextcloud/nextcloudpi/commit/3ee3a28) (2017-07-27) added HTTP port to port forwarding rules

[v0.17.12](https://github.com/nextcloud/nextcloudpi/commit/8127734) (2017-07-27) fix unattended-upgrades

[v0.17.11](https://github.com/nextcloud/nextcloudpi/commit/00a483a) (2017-07-27) output some more information in automount,datadir,unattended-upgrades

[v0.17.10](https://github.com/nextcloud/nextcloudpi/commit/efa3a90) (2017-07-26) secure mysqld

[v0.17.9 ](https://github.com/nextcloud/nextcloudpi/commit/20c35ea) (2017-07-26) nc-backup: make sure destination dir exists

[v0.17.8 ](https://github.com/nextcloud/nextcloudpi/commit/47a9caf) (2017-07-26) nc-nextcloud: fixes for docker build process

[v0.17.7 ](https://github.com/nextcloud/nextcloudpi/commit/93a2b0a) (2017-07-26) nc-init: check mariaDB up

[v0.17.6 ](https://github.com/nextcloud/nextcloudpi/commit/1344a7d) (2017-07-26) dnsmasq detect ip

[v0.17.5 ](https://github.com/nextcloud/nextcloudpi/commit/a7a4637) (2017-07-26) enable nc-news

[v0.17.3 ](https://github.com/nextcloud/nextcloudpi/commit/90ff8b5) (2017-07-24) letsencrypt without restarting apache

[v0.17.2 ](https://github.com/nextcloud/nextcloudpi/commit/bec9cdb) (2017-07-24) ncp-web HTTPS only

[v0.17.1 ](https://github.com/nextcloud/nextcloudpi/commit/1e98c8e) (2017-07-23) restart HTTPd delayed on the bg, so it does not kill AJAX response

[v0.17.0 ](https://github.com/nextcloud/nextcloudpi/commit/41e71b4) (2017-07-13) added ncp-web

[v0.16.2 ](https://github.com/nextcloud/nextcloudpi/commit/33e01e7) (2017-07-07) changed mysql config file location

[v0.16.1 ](https://github.com/nextcloud/nextcloudpi/commit/a98bf79) (2017-07-05) improve info letsencrypt

[v0.16.0 ](https://github.com/nextcloud/nextcloudpi/commit/a82d2d1) (2017-06-28) added nc-format-USB

[v0.15.2 ](https://github.com/nextcloud/nextcloudpi/commit/83af8e7) (2017-06-29) add smbclient for external storage

[v0.15.1 ](https://github.com/nextcloud/nextcloudpi/commit/0e5d8ac) (2017-06-29) nc-automount improvements

[v0.15.0 ](https://github.com/nextcloud/nextcloudpi/commit/dbbdfea) (2017-06-29) add nc-forward-ports

[v0.14.9 ](https://github.com/nextcloud/nextcloudpi/commit/4aba049) (2017-06-29) init noip service in installation step

[v0.14.8 ](https://github.com/nextcloud/nextcloudpi/commit/ea1a3d6) (2017-06-29) add info message nc-news

[v0.14.7 ](https://github.com/nextcloud/nextcloudpi/commit/10a9d2e) (2017-06-29) clear screen before nextcloudpi output

[v0.14.6 ](https://github.com/nextcloud/nextcloudpi/commit/27830f5) (2017-06-28) change config message

[v0.14.5 ](https://github.com/nextcloud/nextcloudpi/commit/88bf2c7) (2017-06-28) nc-wifi and trusted domain fixes

[v0.14.4 ](https://github.com/nextcloud/nextcloudpi/commit/c94bc52) (2017-06-27) nc-automount fixes

[v0.14.3 ](https://github.com/nextcloud/nextcloudpi/commit/bb61bb7) (2017-06-27) protect nextcloudpi-config files from reading. They can contain sensitive information

[v0.14.2 ](https://github.com/nextcloud/nextcloudpi/commit/36b3f49) (2017-06-25) More warnings for nc-database

[v0.14.1 ](https://github.com/nextcloud/nextcloudpi/commit/709cd60) (2017-06-25) Show current version in MOTD when there is an update available

[v0.14.0 ](https://github.com/nextcloud/nextcloudpi/commit/c33cabc) (2017-06-14) nc-init as a nextcloudpi-config option

[v0.13.0 ](https://github.com/nextcloud/nextcloudpi/commit/f2f0687) (2017-06-14) nc-news, install news app

[v0.12.19](https://github.com/nextcloud/nextcloudpi/commit/c03bb6f) (2017-06-13) support for utf8 4byte char

[v0.12.18](https://github.com/nextcloud/nextcloudpi/commit/ecedf91) (2017-06-13) check version format

[v0.12.17](https://github.com/nextcloud/nextcloudpi/commit/338adfb) (2017-06-13) instructions for dnsmasq and noip

[v0.12.16](https://github.com/nextcloud/nextcloudpi/commit/463eee9) (2017-06-06) update trusted domains also from letsencrypt config

[v0.12.14](https://github.com/nextcloud/nextcloudpi/commit/fb0ad98) (2017-05-28) nc-automount fixes

[v0.12.13](https://github.com/nextcloud/nextcloudpi/commit/e917409) (2017-05-28) nc-datadir detect occ errors

[v0.12.12](https://github.com/nextcloud/nextcloudpi/commit/eb4e0d4) (2017-05-28) protect ncp-update from self modifications. fix

[v0.12.11](https://github.com/nextcloud/nextcloudpi/commit/eb438ed) (2017-05-28) also ask to press a key if script fails, to see failed output

[v0.12.10](https://github.com/nextcloud/nextcloudpi/commit/dd01b64) (2017-05-28) rpi-update to prune old modules

[v0.12.9 ](https://github.com/nextcloud/nextcloudpi/commit/b428b0f) (2017-05-27) nc-datadir: move .opcache location too

[v0.12.8 ](https://github.com/nextcloud/nextcloudpi/commit/2a58cc2) (2017-05-26) more checks fail2ban

[v0.12.7 ](https://github.com/nextcloud/nextcloudpi/commit/f0df477) (2017-05-26) only show "press any key" if not canceled

[v0.12.5 ](https://github.com/nextcloud/nextcloudpi/commit/3dbfd2b) (2017-05-25) fix nextcloud-domain service with wicd service

[v0.12.4 ](https://github.com/nextcloud/nextcloudpi/commit/59c981b) (2017-05-25) press key after going back to menu ncp-config

[v0.12.3 ](https://github.com/nextcloud/nextcloudpi/commit/c8ee570) (2017-05-25) improvements for nc-backup and nc-restore

[v0.12.2 ](https://github.com/nextcloud/nextcloudpi/commit/7ea3dbe) (2017-05-25) test for write permissions for mysql and www-data user for nc-datadir and nc-database

[v0.12.1 ](https://github.com/nextcloud/nextcloudpi/commit/c02bc6b) (2017-05-25) revisited modsecurity rules. Fixed photo uploads and notes app

[v0.12.0 ](https://github.com/nextcloud/nextcloudpi/commit/e3a4878) (2017-05-20) add automount feature

[v0.11.1 ](https://github.com/nextcloud/nextcloudpi/commit/06423bf) (2017-05-23) if ACTIVE=yes by default, launch configure for that script on update

[v0.11.0 ](https://github.com/nextcloud/nextcloudpi/commit/0479dbb) (2017-05-22) add NC12

[v0.10.1 ](https://github.com/nextcloud/nextcloudpi/commit/7eaedb4) (2017-05-22) cal nextcloud-domain from nc-wifi

[v0.10.0 ](https://github.com/nextcloud/nextcloudpi/commit/f77b769) (2017-05-21) add nc-backup and nc-restore

[v0.9.0  ](https://github.com/nextcloud/nextcloudpi/commit/0909fce) (2017-05-20) add nextcloud instance installation command to ncp-config

[v0.8.8  ](https://github.com/nextcloud/nextcloudpi/commit/addd0a8) (2017-05-20) check destination filesystem in nc-datadir nc-databasedir

[v0.8.7  ](https://github.com/nextcloud/nextcloudpi/commit/0f0c860) (2017-05-20) add trusted domains also when setting up no-ip

[v0.8.6  ](https://github.com/nextcloud/nextcloudpi/commit/aae7663) (2017-04-27) show ✓ if an item is activated in nextcloudpi-config

[v0.8.5  ](https://github.com/nextcloud/nextcloudpi/commit/092d22a) (2017-05-20) fix update.sh

[v0.8.4  ](https://github.com/nextcloud/nextcloudpi/commit/2877a28) (2017-04-27) return to menu in nextcloudpi-config

[v0.8.3  ](https://github.com/nextcloud/nextcloudpi/commit/8200602) (2017-04-27) dont ask for confirmation on exiting config

[v0.8.2  ](https://github.com/nextcloud/nextcloudpi/commit/be2e4e6) (2017-04-27) keep current configuration on remote updates

[v0.8.1  ](https://github.com/nextcloud/nextcloudpi/commit/64bf42f) (2017-04-27) added show_info() to nextcloudpi-config

[v0.8.0  ](https://github.com/nextcloud/nextcloudpi/commit/117f72a) (2017-04-26) [update 11.0.3] split installation between base LAMP and NC. Cleaner to just update NC releases over the base

[v0.7.2  ](https://github.com/nextcloud/nextcloudpi/commit/cb7c5ca) (2017-04-21) fix issue #6 First booting with a connected ethernet cable makes wicd daemon start with an empty wireless interface

[v0.7.1  ](https://github.com/nextcloud/nextcloudpi/commit/1483c72) (2017-04-16) do not cleanup as part of ncp-update

[v0.7.0  ](https://github.com/nextcloud/nextcloudpi/commit/c726250) (2017-04-14) added samba/cifs

[v0.6.0  ](https://github.com/nextcloud/nextcloudpi/commit/47f4c75) (2017-04-11) NFS and nc-scan

[v0.5.10 ](https://github.com/nextcloud/nextcloudpi/commit/714f6b2) (2017-04-07) fixes enabling services

[v0.5.9  ](https://github.com/nextcloud/nextcloudpi/commit/a17c393) (2017-04-04) disable dhcpcd when enabling wicd

[v0.5.8  ](https://github.com/nextcloud/nextcloudpi/commit/a340077) (2017-04-04) ncp-update: only root

[v0.5.7  ](https://github.com/nextcloud/nextcloudpi/commit/c60ee01) (2017-04-04) protect ncp-update from self modifications

[v0.5.6  ](https://github.com/nextcloud/nextcloudpi/commit/1c19f4c) (2017-04-04) fix ncp-update with no internet access

[v0.5.5  ](https://github.com/nextcloud/nextcloudpi/commit/eaf3fe7) (2017-04-04) fix print version nextcloudpi-config

[v0.5.4  ](https://github.com/nextcloud/nextcloudpi/commit/f363412) (2017-04-03) nc-wifi fixes: not enabled by default

[v0.5.3  ](https://github.com/nextcloud/nextcloudpi/commit/9b5cd81) (2017-04-03) check for updates (and update) upon launching nextcloudpi-config

[v0.5.2  ](https://github.com/nextcloud/nextcloudpi/commit/138fecc) (2017-04-02) fix empty wireless_interfaces in nc-wifi

[v0.5.1  ](https://github.com/nextcloud/nextcloudpi/commit/aec77e4) (2017-04-01) bugfixes RAM logs, swap and nc-database

[v0.5.0  ](https://github.com/nextcloud/nextcloudpi/commit/e1c46b5) (2017-03-31) added RAM logs

[v0.4.0  ](https://github.com/nextcloud/nextcloudpi/commit/ef12ceb) (2017-03-31) added configure swap file

[v0.3.0  ](https://github.com/nextcloud/nextcloudpi/commit/fd942a5) (2017-03-31) added database location config

[v0.2.0  ](https://github.com/nextcloud/nextcloudpi/commit/d7ced8d) (2017-03-31) added wifi-curses

[v0.1.0  ](https://github.com/nextcloud/nextcloudpi/commit/75b4268) (2017-03-29) ncp updates and motd. structure directories

[v0.0.1  ](https://github.com/nextcloud/nextcloudpi/commit/28accd2) (2017-03-24) add HTTPS only setting to nextcloudpi-config
