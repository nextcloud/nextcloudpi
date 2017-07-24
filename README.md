# NextCloudPi

![NC Logo](https://ownyourbits.com/wp-content/uploads/2017/02/nextcloudpi-logo.png)

This is the build code for [NextCloudPi](https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/).

NextCloudPi is a ready to use image for Raspberry Pi.

This code also generates the [NextCloudPi ARM docker image](https://hub.docker.com/r/ownyourbits/nextcloudpi/).

## Features

* Raspbian 8 Jessie
* Nextcloud 12
* Apache 2.4.25, with HTTP2 enabled
* PHP 7.0 (double the speed of PHP5!)
* MariaDB 10
* 4.9.13 Linux Kernel ( NEW 03-13-2017 )
* nextcloudpi-config for easy setup ( RAM logs, USB drive and more )
* Automatic redirection to HTTPS
* ACPU PHP cache
* PHP Zend OPcache enabled with file cache
* HSTS
* Cron jobs for Nextcloud
* Sane configuration defaults
* Full emoji support ( NEW 05-24-2017 )
* Secure

## Extras

 * NextCloudPi Web Panel ( NEW 07-24-2017 )
 * Wi-Fi ready ( NEW 03-31-2017 )
 * Automatic security updates, activated by default. ( NEW 03-21-2017 )
 * Let’s Encrypt for trusted HTTPS certificates.(  NEW 03-16-2017 )
 * Fail2Ban protection against brute force attacks. ( NEW 02-24-2017 )
 * Dynamic DNS support for no-ip.org ( NEW 03-05-2017 )
 * dnsmasq DNS server with DNS cache ( NEW 03-09-2017 )
 * ModSecurity Web Application Firewall ( NEW 03-23-2017 )
 * NFS ready to mount your files over LAN ( NEW 04-13-2017 )
 * SAMBA ready to share your files with Windows/Mac/Linux ( NEW 04-16-2017 )
 * USB automount ( NEW 05-24-2017 )
 * Remote updates ( NEW 03-31-2017 )
 * Unofficial Nextcloud News App installer ( NEW 05-24-2017 )
 * NextCloud backup and restore ( NEW 05-24-2017 )
 * NextCloud online installation ( NEW 05-24-2017 )
 * Format USB drive to ext4 ( NEW 07-03-2017 )
 * UPnP automatic port forwarding ( NEW 07-03-2017 )


Any extra can be installed independently in a running Raspbian instance through SSH. See `installer.sh`

Extras can be activated and configured using the web interface at HTTPS port 4443


![NCP-config](https://ownyourbits.com/wp-content/uploads/2017/07/web-letsencrypt.jpg)

, or from the command line from

```
sudo nextcloudpi-config
```

![NCP-config](https://ownyourbits.com/wp-content/uploads/2017/03/ncp-conf-700x456.jpg)


## How to build

NextCloudPi is based on Raspbian and is automatically generated using QEMU.

```
git clone https://github.com/nextcloud/nextcloudpi.git
cd nextcloudpi
./batch.sh 192.168.0.145 # change to your QEMU raspbian IP
```

The docker image can be generated in an ARM environment with docker

```
git clone https://github.com/nextcloud/nextcloudpi.git
make -C nextcloudpi
```

## Downloads

Get the image, find details and more instructions at

https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/

Pull the docker image

https://ownyourbits.com/2017/06/08/nextcloudpi-docker-for-raspberry-pi/

https://hub.docker.com/r/ownyourbits/nextcloudpi/
