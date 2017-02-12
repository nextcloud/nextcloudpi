# nextcloud-raspbian-generator
Automatically generate Raspbian Images with Nextcloud installed and configured using QEMU

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
./install-image.sh 192.168.0.145 # change to your QEMU raspbian IP
```

See details and instructions at

https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/
