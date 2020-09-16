[English](/README.md) | Traditional Chinese 繁體中文


# NextCloudPi [![chatroom icon](https://patrolavia.github.io/telegram-badge/chat.png)](https://t.me/NextCloudPi) [![forums icon](https://img.shields.io/badge/help-forums-blue.svg)](https://help.nextcloud.com/c/support/appliances-docker-snappy-vm) [![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=N8PJHSEQF4G7Y&lc=US&item_name=Own%20Your%20Bits&item_number=NextCloudPi&no_note=1&no_shipping=1&currency_code=EUR&bn=PP%2dDonationsBF%3abtn_donate_LG%2egif%3aNonHosted) [![blog](https://img.shields.io/badge/follow-blog-orange.svg)](https://ownyourbits.com)


![NC Logo](https://ownyourbits.com/wp-content/uploads/2017/11/ncp-square.png)

歡迎來到 [NextCloudPi](https://nextcloudpi.com)！

NextCloudPi 是專門為 Raspberry Pi、Odroid HC1、rock64 以及其它單板電腦所製作的映象檔。

為了方便使用者簡單地安裝 NextCloud 所製作。

這個映像檔還為 [ARM](https://hub.docker.com/r/ownyourbits/nextcloudpi-armhf) 及 [x86](https://hub.docker.com/r/ownyourbits/nextcloudpi-x86) 等平臺製作，並且可安裝於任何為 Debian 作業系統為基底的電腦。


我們深知這個專案可能會對新手頭痛，因此我們有提供說明文件，方便你查詢解答。**網址是：[docs.nextcloudpi.com](docs.nextcloudpi.com)。**

## 功能

 * Debian/Raspbian 10 Buster
 * Nextcloud 16.0.3
 * Apache 2.4.25, with HTTP2 enabled
 * PHP 7.3
 * MariaDB 10
 * Redis memory cache ( NEW 11-12-2017 )
 * 4.9 Linux Kernel ( NEW 03-13-2017 )
 * ncp-config for easy setup ( RAM logs, USB drive and more )
 * Automatic redirection to HTTPS
 * ACPU PHP cache
 * PHP Zend OPcache enabled with file cache
 * HSTS
 * Cron jobs for Nextcloud
 * Sane configuration defaults
 * 完整的表情符號支援
 * Postfix email
 * Secure

## 特別之處

 * 首次安裝導覽頁面
 * NextCloudPi 網路 面板
 * 可使用 Wi-Fi
 * Ram logs
 * 自動安裝安全更新，且預設如此。
 * 內建 Let’s Encrypt，可使用此功能來建立受信任的 SSL 證書。
 * 內建 Fail2Ban ，可保護您不受殭屍登入(SSH)的干擾及風險。
 * UFW 防火牆
 * 可使用no-ip.org 所提供的浮動IP連結功能
 * 可使用freeDNS 所提供的浮動IP連結功能
 * 可使用duckDNS 所提供的浮動IP連結功能
 * 可使用spDYN 所提供的浮動IP連結功能
 * 可使用Namecheap DNS 所提供的浮動IP連結功能
 * 內建 dnsmasq DNS 伺服器快取
 * ModSecurity 網路應用程式防火牆
 * NFS ready to mount your files over LAN
 * SAMBA ready to share your files with Windows/Mac/Linux
 * USB 自動掛載
 * 遠端更新
 * 自動更新 NextCloudPi
 * 自動更新 Nextcloud
 * 更新通知
 * NextCloud 備份、復原備份
 * NextCloud 線上安裝
 * 格式化 USB 裝置成 BTRFS
 * BTRFS 快照
 * 自動建立 BTRFS 快照
 * 自動同步 BTRFS 快照
 * 排程 rsync
 * ZRAM
 * UPnP 自動設定 Portautomatic port 轉發
 * 可建立 Lynis 及 Debsecan 的安全審核報告
 * ZRAM

您可以使用瀏覽器HTTPS進入連接埠 :4443 ，就可以使用網路介面的更多設定。


![NCP-config](https://ownyourbits.com/wp-content/uploads/2017/07/web-letsencrypt.jpg)

或者使用指令來設定

```
sudo ncp-config
```

![NCP-config](https://ownyourbits.com/wp-content/uploads/2017/03/ncp-conf-700x456.jpg)


## 如何建立 ?

安裝 git、docker、qemu-user-static、chroot 以及所有常用之建立工具

```
git clone https://github.com/nextcloud/nextcloudpi.git
cd nextcloudpi
./build-SD-rpi.sh
```

或者以 Armbian 為基礎的主機板

```
./build-SD-armbian.sh odroidxu4   # supported board code name
```

建立 docker 映像檔

```
git clone https://github.com/nextcloud/nextcloudpi.git
cd nextcloudpi
./build-docker.sh x86
./build-docker.sh armhf
./build-docker.sh arm64
```

NextCloudPi 可以安裝在運行最新的 debian 的任何體系結構中

```
# curl -sSL https://raw.githubusercontent.com/nextcloud/nextcloudpi/master/install.sh | bash
```

## 下載

取得映像檔，及更多有關詳細資訊及更多說明, 請參見

https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/

Pull the docker image

https://nextcloudpi.com

https://hub.docker.com/r/ownyourbits/nextcloudpi-x86

https://hub.docker.com/r/ownyourbits/nextcloudpi-armhf

https://hub.docker.com/r/ownyourbits/nextcloudpi-arm64

## 聯絡

你可以加入[Telegram 群組](https://t.me/NextCloudPi)，或者使用[論壇](https://help.nextcloud.com/c/support/appliances-docker-snappy-vm)來找到我們。

如果你也想為這個專案進行本地化，歡迎加入 Telegram [NCP Wiki Team](https://t.me/NCP_Wiki_Team) 群組，來洽詢更多身為本地化編輯員該做的事。
