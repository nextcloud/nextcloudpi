English | [Traditional Chinese 繁體中文](i18n/README-zh_TW.md) | [Simplified Chinese 简体中文](i18n/README-zh_CN.md)

_(The translated README pages are not updated at this time)_

# NextcloudPi

[![Telegram icon][telegram-badge]][chat-telegram] [![Matrix icon][matrix-badge]][chat-matrix]  [![Nextcloud icon][nc-badge]][nc-github]

[![Forum icon][forum-badge]][nc-forum-support]

<p align="center">
  <img src="https://github.com/nextcloud/nextcloudpi/blob/master/ncp-app/img/app.svg"
       width="120"
       height="85"
       alt="NextcloudPi logo">
</p>

This is the build code for the [NextcloudPi][ncp-website] open-source community project.

NextcloudPi is a ready to use image for Virtual Machines, Raspberry Pi, Odroid HC1, Rock64 and other boards. ([⇒ Downloads][ncp-releases])

This code also generates the NextcloudPi LXD and LXC containers and there is an install script for the latest supported Debian based system as well.

Find the documentation at [docs.nextcloudpi.com][ncp-docs-website], the documentation is all written by volunteers.

Please reach out in the [Matrix][chat-matrix-wiki] or [Telegram][chat-telegram-wiki] Wiki group chats if you want to help out to keep them up-to-date and we'll add you to the [Wiki Group][nc-forum-wiki-group] on the [forum][nc-forum].

---

`master`

[![VM Tests][vm-tests-badge]][vm-tests]

[![Docker Tests][docker-tests-badge]][docker-tests]

`devel`

[![VM Tests][gh-vm-tests-badge-devel]][vm-tests]

[![Docker Tests][gh-docker-tests-badge-devel]][docker-tests]

---

## Features

 * Raspberry Pi OS/Debian 11 _(Bullseye)_
 * Nextcloud
 * Apache, with HTTP2 enabled
 * PHP 8.1
 * MariaDB
 * Redis memory cache
 * ncp-config TUI for easy setup ( RAM logs, USB drive and more )
 * Automatic redirection to HTTPS
 * APCu PHP cache
 * PHP Zend OPcache enabled with file cache
 * HSTS
 * Cron jobs for Nextcloud
 * Sane configuration defaults
 * Full emoji support
 * Postfix email
 * Secure

## Extras

 * Setup wizard
 * NextcloudPi Web Panel
 * Wi-Fi ready
 * Ram logs
 * Automatic security updates, activated by default.
 * Let’s Encrypt for trusted HTTPS certificates.
 * Fail2Ban protection against brute force attacks.
 * UFW firewall
 * Dynamic DNS support for no-ip.org
 * Dynamic DNS support for freeDNS
 * Dynamic DNS support for duckDNS
 * Dynamic DNS support for spDYN
 * Dynamic DNS support for Namecheap
 * dnsmasq DNS server with DNS cache
 * ModSecurity Web Application Firewall
 * NFS ready to mount your files over LAN
 * SAMBA ready to share your files with Windows/Mac/Linux
 * USB automount
 * Remote updates
 * Automatic NCP updates
 * Automatic Nextcloud updates
 * Update notifications
 * Nextcloud backup and restore
 * Nextcloud online installation
 * Format USB drive to BTRFS
 * BTRFS snapshots
 * Automatic BTRFS snapshots
 * BTRFS snapshot auto sync
 * scheduled rsync
 * UPnP automatic port forwarding
 * Security audits with Lynis and Debsecan
 * ZRAM
 * SMART hard drive health monitoring

Extras can be activated and configured using the web interface at HTTPS port 4443

![ncp-web][ncp-web-image]

Or from the command line using

```
sudo ncp-config
```

![NCP-config][ncp-config-image]

## Docker has been discontinued

Docker has been discontinued for the time being, please read the announcement here: https://help.nextcloud.com/t/nextcloudpi-planning-to-discontinue-its-docker-version-with-nc-25/158895

## Run in LXD

```
# Imports the LXC image, replace the X's with version number
lxc image import "NextcloudPi_LXD_vX.XX.X.tar.gz" --alias "nextcloudpi"

# Launches a container from the image
lxc launch "nextcloudpi" ncp

# Starts the container you've launched from the imported image
lxc start ncp
```

## Run in Proxmox

Use the [install script][ncp-proxmox-install-script-v5] from [tteck][tteck-profile] to install the LXC container on your Proxmox instance

He has multiple helper scripts available for Proxmox on his [website][website-helper-scripts], do go have a look if you're using Proxmox. :+1:

Installation: `bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/nextcloudpi-v5.sh)"`

Default Settings: `2GB RAM - 8GB Storage - 2vCPU`

_(Check his [website][website-helper-scripts] if this has changed and we haven't had the time to update it here yet, it's located under: Media - Photo > NextcloudPi LXC)_

Thenk you [tteck][tteck-profile] :heart: for making the helper script & letting us use this for Proxmox installations :pray:

You can find his GitHub repository with his helper scripts [here][gh-helper-scripts-repo].

## How to build

Packages

- `apt-utils`
- `apt-transport-https`
- `build-essential`
- `binfmt-support`
- `binutils`
- `bzip2`
- `ca-certificates`
- `chroot`
- `cron`
- `curl`
- `dialog`
- `lsb-release`
- `jq`
- `git`
- `psmisc`
- `procps`
- `wget`
- `whiptail`
- `qemu`
- `qemu-user-static`

### Raspberry Pi IMG

```
git clone https://github.com/nextcloud/nextcloudpi.git
cd nextcloudpi
./build/build-SD-rpi.sh
```

### Armbian-based board

```
./build-SD-armbian.sh odroidxu4   # supported board code name
```

### LXD

```
./build/build-LXD.sh
```

NextcloudPi can be installed in any architecture running the latest Debian

_Note: this assumes a clean Debian install, and there is no rollback method_

### Curl install scripts

This is executed as `root` as indicated by the `#`

```
# curl -sSL https://raw.githubusercontent.com/nextcloud/nextcloudpi/master/install.sh | bash
```

If you're not `root` you can run it with `sudo` like so

```
curl -sSL https://raw.githubusercontent.com/nextcloud/nextcloudpi/master/install.sh | sudo bash
```

## Links

[Website][ncp-website]

[Downloads][ncp-releases]

<!-- [Docker Hub][ncp-docker-hub] -->

[Nextcloud Forum][nc-forum]

[Nextcloud Forum Support][nc-forum-support]

_(Use the Forum for Support questions please, there's a NCP tag available, it will bridge your post to the Matrix and Telegram chats)_

## Contact

You can find us on the [Forum][nc-forum], [Telegram][chat-telegram] or [Matrix][chat-matrix]

<!-- LINKS -->

[ncp-website]: https://nextcloudpi.com

[ncp-docs-website]: http://docs.nextcloudpi.com

[ncp-docker-hub]: https://hub.docker.com/r/ownyourbits/nextcloudpi

[ncp-releases]: https://github.com/nextcloud/nextcloudpi/releases

[nc-github]: https://github.com/nextcloud

<!-- FORUM -->

[nc-forum]: https://help.nextcloud.com/

[nc-forum-support]: https://help.nextcloud.com/c/support/appliances-docker-snappy-vm

[nc-forum-wiki-group]: https://help.nextcloud.com/g/NCP_Wiki_Team/members

<!-- CHAT -->

[chat-matrix]: https://matrix.to/#/#nextcloudpi:matrix.org

[chat-matrix-wiki]: https://matrix.to/#/#NCP_Wiki_Team:matrix.org

[chat-telegram]: https://t.me/NextcloudPi

[chat-telegram-wiki]: https://t.me/NCP_Wiki_Team

<!-- TESTS -->

[vm-tests]: https://github.com/nextcloud/nextcloudpi/actions/workflows/vm-tests.yml

[docker-tests]: https://github.com/nextcloud/nextcloudpi/actions/workflows/build-docker.yml

<!-- BADGES -->

[gh-vm-tests-badge]: https://github.com/nextcloud/nextcloudpi/actions/workflows/vm-tests.yml/badge.svg

[gh-docker-tests-badge]: https://github.com/nextcloud/nextcloudpi/actions/workflows/build-docker.yml/badge.svg

[gh-vm-tests-badge-devel]: https://github.com/nextcloud/nextcloudpi/actions/workflows/vm-tests.yml/badge.svg?branch=devel

[gh-docker-tests-badge-devel]: https://github.com/nextcloud/nextcloudpi/actions/workflows/build-docker.yml/badge.svg?branch=devel

[vm-tests-badge]: https://github.com/nextcloud/nextcloudpi/workflows/VM%20Integration%20Tests/badge.svg

[docker-tests-badge]: https://github.com/nextcloud/nextcloudpi/actions/workflows/build-docker.yml/badge.svg

[telegram-badge]: https://img.shields.io/badge/Telegram-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white

[matrix-badge]: https://img.shields.io/badge/matrix-000000?style=for-the-badge&logo=Matrix&logoColor=white

[forum-badge]: https://img.shields.io/badge/help-forums-blue.svg

[nc-badge]: https://img.shields.io/badge/Nextcloud-0082C9?style=for-the-badge&logo=Nextcloud&logoColor=white

<!-- TTECK -->

[tteck-profile]: https://github.com/tteck

[gh-helper-scripts-repo]: https://github.com/tteck/Proxmox

[website-helper-scripts]: https://tteck.github.io/Proxmox/

[ncp-proxmox-install-script-v5]: https://github.com/tteck/Proxmox/blob/main/install/nextcloudpi-v5-install.sh

<!-- IMAGES -->

[ncp-web-image]: https://user-images.githubusercontent.com/21343324/136853829-f4e99ec0-6307-431f-b4c7-21b2330cae7f.png

[ncp-config-image]: https://help.nextcloud.com/uploads/default/original/3X/b/3/b3d157022a32296ab54428b14b5df02104a91f18.png

<!-- EXTRAS & BACKUPS

[telegram-badge]: https://patrolavia.github.io/telegram-badge/chat.png

[rpi-badge]: https://img.shields.io/badge/Raspberry%20Pi-A22846?style=for-the-badge&logo=Raspberry%20Pi&logoColor=white

[linux-badge]: https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black

[debian-badge]: https://img.shields.io/badge/Debian-A81D33?style=for-the-badge&logo=debian&logoColor=white

[gh-badge]: https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white

-->
