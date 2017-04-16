# NextCloudPi generator

![NC Logo](/resources/nextcloud-square-logo.png)

Use QEMU to automatically generate Raspbian Images with Nextcloud 

## Features

* Raspbian 8 Jessie
* Nextcloud 11.0.2
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
* Secure

## Extras

* Wi-Fi ready ( NEW 03-31-2017 )
* Automatic security updates, activated by default. ( NEW 03-21-2017 )
* Let’s Ecrypt for trusted HTTPS certificates.(  NEW 03-16-2017 )
* Fail2Ban protection against brute force attacks. ( NEW 02-24-2017 )
* Dynamic DNS support for no-ip.org ( NEW 03-05-2017 )
* dnsmasq DNS server with DNS cache ( NEW 03-09-2017 )
* ModSecurity Web Application Firewall ( NEW 03-23-2017 )
* NFS ready to mount your files over LAN ( NEW 04-13-2017 )
* SAMBA ready to share your files with Windows/Mac/Linux ( NEW 04-16-2017 )
* Remote updates ( NEW 03-31-2017 )

## Usage

```
git clone https://github.com/nachoparker/nextcloud-raspbian-generator.git
cd nextcloud-raspbian-generator
./batch.sh 192.168.0.145 # change to your QEMU raspbian IP
```

Extras can be activated and configured using

```
sudo nextcloudpi-config
```

![NCP-config](/resources/ncp-config.jpg)

Get the image, find details and more instructions at

https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/
