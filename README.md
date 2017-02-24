# NextCloudPi generator

![NC Logo](/resources/nextcloud-square-logo.png)

Use QEMU to automatically generate Raspbian Images with Nextcloud 

## Features

* Raspbian 8 Jessie
* Nextcloud 11.0.1
* Apache 2.4.25, with HTTP2 enabled
* PHP 7.0 
* MariaDB 10
* Automatic redirection to HTTPS
* ACPU PHP cache
* PHP Zend OPcache enabled with file cache
* HSTS
* Cron jobs for Nextcloud
* Sane configuration defaults

## Usage

```
git clone https://github.com/nachoparker/nextcloud-raspbian-generator.git
cd nextcloud-raspbian-generator
./install-nextcloud.sh 192.168.0.145 # change to your QEMU raspbian IP
```

If we also want fail2ban in our image

```
./install-fail2ban.sh NextCloudPi_02-18-17.img 192.168.0.145 # change to your QEMU raspbian IP
```

Adjust for the image name generated in the first step.

Get the image or find details and instructions at

https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/

More on the fail2ban installation

https://ownyourbits.com/2017/02/24/nextcloudpi-fail2ban-installer/
