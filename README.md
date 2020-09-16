English | [Traditional Chinese 繁體中文](/README-ZH-TW.md)

# NextCloudPi [![chatroom icon](https://patrolavia.github.io/telegram-badge/chat.png)](https://t.me/NextCloudPi) [![forums icon](https://img.shields.io/badge/help-forums-blue.svg)](https://help.nextcloud.com/c/support/appliances-docker-snappy-vm) [![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=N8PJHSEQF4G7Y&lc=US&item_name=Own%20Your%20Bits&item_number=NextCloudPi&no_note=1&no_shipping=1&currency_code=EUR&bn=PP%2dDonationsBF%3abtn_donate_LG%2egif%3aNonHosted) [![blog](https://img.shields.io/badge/follow-blog-orange.svg)](https://ownyourbits.com)


![NC Logo](https://ownyourbits.com/wp-content/uploads/2017/11/ncp-square.png)

This is the build code for [NextCloudPi](https://nextcloudpi.com).

NextCloudPi is a ready to use image for Raspberry Pi, Odroid HC1, rock64 and other boards.

This code also generates the NextCloudPi docker images for [ARM](https://hub.docker.com/r/ownyourbits/nextcloudpi-armhf) and [x86](https://hub.docker.com/r/ownyourbits/nextcloudpi-x86) platforms, and includes an installer for any Debian based system.

Find the full documentation at [docs.nextcloudpi.com](http://docs.nextcloudpi.com)

## Features

 * Debian/Raspbian 10 Buster
 * Nextcloud 19.0.2
 * Apache 2.4.25, with HTTP2 enabled
 * PHP 7.3
 * MariaDB 10
 * Redis memory cache
 * ncp-config for easy setup ( RAM logs, USB drive and more )
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
 * NextCloudPi Web Panel
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
 * NextCloud backup and restore
 * NextCloud online installation
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


![NCP-config](https://ownyourbits.com/wp-content/uploads/2017/07/web-letsencrypt.jpg)

, or from the command line from

```
sudo ncp-config
```

![NCP-config](https://ownyourbits.com/wp-content/uploads/2017/03/ncp-conf-700x456.jpg)


## Run in docker

```
docker run -d -p 4443:4443 -p 443:443 -p 80:80 -v ncdata:/data --name nextcloudpi ownyourbits/nextcloudpi $DOMAIN
```


## How to build

Install git, docker, qemu-user-static, chroot and all the usual building tools.

```
git clone https://github.com/nextcloud/nextcloudpi.git
cd nextcloudpi
./build-SD-rpi.sh
```

, or for an Armbian based board

```
./build-SD-armbian.sh odroidxu4   # supported board code name
```

In order to generate the Docker images

```
git clone https://github.com/nextcloud/nextcloudpi.git
cd nextcloudpi
./build-docker.sh x86
./build-docker.sh armhf
./build-docker.sh arm64
```

NextCloudPi can be installed in any architecture running the latest Debian

```
# curl -sSL https://raw.githubusercontent.com/nextcloud/nextcloudpi/master/install.sh | bash
```

## Downloads

Get the image, find details and more instructions at

https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/

Pull the docker image

https://nextcloudpi.com

https://hub.docker.com/r/ownyourbits/nextcloudpi

## Contact

You can find us in the [forums](https://help.nextcloud.com/c/support/appliances-docker-snappy-vm) and a [Telegram group](https://t.me/NextCloudPi)
