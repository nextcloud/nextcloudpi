English | [Traditional Chinese 繁體中文](i18n/README-zh_TW.md) | [Simplified Chinese 简体中文](i18n/README-zh_CN.md)

# NextcloudPi [![chatroom icon](https://patrolavia.github.io/telegram-badge/chat.png)](https://t.me/NextcloudPi) [![forums icon](https://img.shields.io/badge/help-forums-blue.svg)](https://help.nextcloud.com/c/support/appliances-docker-snappy-vm) [![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=N8PJHSEQF4G7Y&lc=US&item_name=Own%20Your%20Bits&item_number=NextcloudPi&no_note=1&no_shipping=1&currency_code=EUR&bn=PP%2dDonationsBF%3abtn_donate_LG%2egif%3aNonHosted) [![blog](https://img.shields.io/badge/follow-blog-orange.svg)](https://ownyourbits.com)

![NCP Logo](https://github.com/nextcloud/nextcloudpi/blob/master/ncp-app/img/app.svg)

This is the build code for [NextcloudPi](https://nextcloudpi.com).

NextcloudPi is a ready to use image for Virtual Machines, Raspberry Pi, Odroid HC1, rock64 and other boards [(⇒Downloads)](https://github.com/nextcloud/nextcloudpi/releases).

This code also generates the NextcloudPi [docker image](https://hub.docker.com/r/ownyourbits/nextcloudpi), LXD and VM, and includes an installer for any Debian based system.

Find the full documentation at [docs.nextcloudpi.com](http://docs.nextcloudpi.com)

---

[![VM Integration Tests](https://github.com/nextcloud/nextcloudpi/workflows/VM%20Integration%20Tests/badge.svg)](https://github.com/nextcloud/nextcloudpi/actions/workflows/vm-tests.yml)

[![Docker Integration Tests](https://github.com/nextcloud/nextcloudpi/actions/workflows/build-docker.yml/badge.svg)](https://github.com/nextcloud/nextcloudpi/actions/workflows/build-docker.yml)

---

## Features

 * Debian/Raspbian 11 Bullseye
 * Nextcloud 25.0.2
 * Apache, with HTTP2 enabled
 * PHP 8.1
 * MariaDB 10
 * Redis memory cache
 * ncp-config TUI for easy setup ( RAM logs, USB drive and more )
 * Automatic redirection to HTTPS
 * ACPU PHP cache
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

![ncp-web](https://user-images.githubusercontent.com/21343324/136853829-f4e99ec0-6307-431f-b4c7-21b2330cae7f.png)

Or from the command line using

```
sudo ncp-config
```

![NCP-config](https://help.nextcloud.com/uploads/default/original/3X/b/3/b3d157022a32296ab54428b14b5df02104a91f18.png)


## Run in docker

```
docker run --detach \
           --publish 4443:4443 \
           --publish 443:443 \
           --publish 80:80 \
           --volume ncdata:/data \
           --name nextcloudpi \
           ownyourbits/nextcloudpi $DOMAIN
```

`$DOMAIN` can also be the IP-address of the host device.

## Run in LXD

```
lxc image import "NextcloudPi_LXD_vX.XX.X.tar.gz" --alias "nextcloudpi" # Imports the image, replace the X's with version number
lxc launch "nextcloudpi" ncp # Launches a container from the image
lxc start ncp # Starts the container you've launched from the imported image
```

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
- `docker` _(If you're building a Docker image)_
- `lxd` _(If you're building an LXD/LXC container image)_

```
git clone https://github.com/nextcloud/nextcloudpi.git
cd nextcloudpi
./build/build-SD-rpi.sh
```

### Armbian-based board

```
./build-SD-armbian.sh odroidxu4   # supported board code name
```

In order to generate the Docker images, you'll also need to change the username, repo and tags to match your credentials at Docker Hub.

```
git clone https://github.com/nextcloud/nextcloudpi.git
cd nextcloudpi
build/build-docker.sh x86
build/build-docker.sh armhf
build/build-docker.sh arm64
```

### LXD

```
./build/build-LXD.sh
```

NextcloudPi can be installed in any architecture running the latest Debian

_Note: this assumes a clean Debian install, and there is no rollback method_

### Curl install scripts

```
# curl -sSL https://raw.githubusercontent.com/nextcloud/nextcloudpi/master/install.sh | bash
```

## Downloads

https://nextcloudpi.com

https://hub.docker.com/r/ownyourbits/nextcloudpi

## Contact

You can find us in the [forums](https://help.nextcloud.com/c/support/appliances-docker-snappy-vm) and a [Telegram group](https://t.me/NextcloudPi)
