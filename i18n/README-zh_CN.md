[English](/README.md) | [Traditional Chinese 繁體中文](README-zh_TW.md) | Simplified Chinese 简体中文

# NextCloudPi [![chatroom icon](https://patrolavia.github.io/telegram-badge/chat.png)](https://t.me/NextCloudPi) [![forums icon](https://img.shields.io/badge/help-forums-blue.svg)](https://help.nextcloud.com/c/support/appliances-docker-snappy-vm) [![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=N8PJHSEQF4G7Y&lc=US&item_name=Own%20Your%20Bits&item_number=NextCloudPi&no_note=1&no_shipping=1&currency_code=EUR&bn=PP%2dDonationsBF%3abtn_donate_LG%2egif%3aNonHosted) [![blog](https://img.shields.io/badge/follow-blog-orange.svg)](https://ownyourbits.com)


![NC Logo](https://ownyourbits.com/wp-content/uploads/2017/11/ncp-square.png)

这里是用来构建 [NextCloudPi](https://nextcloudpi.com) 的代码。

NextCloudPi 是一款适用于 Raspberry Pi、Odroid HC1、rock64 等其他板卡的现成镜像。

这个代码也可以用来生成 [ARM](https://hub.docker.com/r/ownyourbits/nextcloudpi-armhf) 和 [x86](https://hub.docker.com/r/ownyourbits/nextcloudpi-x86) 平台的 docker 镜像，并且包含一个适用于任何基于 Debian 系统的安装程序。

可以在 [docs.nextcloudpi.com](http://docs.nextcloudpi.com) 找到完整的文档。

## 功能

 * Debian/Raspbian 10 Buster
 * Nextcloud 19.0.2
 * Apache 2.4.25, with HTTP2 enabled
 * PHP 7.3
 * MariaDB 10
 * Redis memory cache
 * 用于简单设置的 ncp-config 命令(RAM 日志，USB 驱动及其他)
 * 自动重定向到 HTTPS
 * ACPU PHP cache
 * PHP Zend OPcache enabled with file cache
 * HSTS
 * Cron jobs for Nextcloud
 * Sane configuration defaults
 * 完整的 emoji 支持
 * Postfix email
 * 安全

## 额外之处

 * 安装向导
 * NextCloudPi Web 面板
 * 已准备好的 Wi-Fi
 * RAM 日志
 * 自动安装安全更新，默认激活
 * Let’s Encrypt for trusted HTTPS certificates.
 * Fail2Ban protection against brute force attacks.
 * UFW 防火墙
 * 对 no-ip.org 的动态 DNS支持
 * 对 freeDNS 的动态 DNS支持
 * 对 duckDNS 的动态 DNS支持
 * 对 spDYN 的动态 DNS支持
 * dnsmasq DNS server with DNS cache
 * ModSecurity Web Application Firewall
 * 通过预装的 NFS 挂载局域网内的文件
 * 通过预装的 SAMBA 与 Windows/Mac/Linux 分享文件
 * 自动挂载 USB
 * 远程更新
 * 自动更新 NextCloudPi
 * 自动更新 NextCloud
 * 更新通知
 * NextCloud 备份和恢复
 * NextCloud 在线安装
 * 格式化 USB 驱动器为 BTRFS
 * BTRFS 快照
 * 自动建立 BTRFS 快照
 * BTRFS 快照自动同步
 * 定时同步
 * UPnP 自动端口转发
 * 用 Lynis and Debsecan 生成安全审计
 * ZRAM
 * SMART 硬盘健康监测

可以使用 HTTPS 端口 4443 的 web 界面激活和配置“附加功能”

![NCP-config](https://ownyourbits.com/wp-content/uploads/2017/07/web-letsencrypt.jpg)

，或者通过命令

```
sudo ncp-config
```

![NCP-config](https://ownyourbits.com/wp-content/uploads/2017/03/ncp-conf-700x456.jpg)


## 在 docker 中运行

```
docker run -d -p 4443:4443 -p 443:443 -p 80:80 -v ncdata:/data --name nextcloudpi ownyourbits/nextcloudpi $DOMAIN
```


## 如何构建

安装 git, docker, qemu-user-static, chroot 和所有常用的构建工具。

```
git clone https://github.com/nextcloud/nextcloudpi.git
cd nextcloudpi
./build-SD-rpi.sh
```

，或者基于 Armbian 的主板

```
./build-SD-armbian.sh odroidxu4   # 受支持的主板代码的名称
```

为了生成 Docker 镜像

```
git clone https://github.com/nextcloud/nextcloudpi.git
cd nextcloudpi
./build-docker.sh x86
./build-docker.sh armhf
./build-docker.sh arm64
```

NextCloudPi 可以被安装在任何架构的最新版本 Debian 系统上

```
# curl -sSL https://raw.githubusercontent.com/nextcloud/nextcloudpi/master/install.sh | bash
```

## 下载

获取镜像，寻找细节和更多说明，请点击这里

https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/

https://nextcloudpi.com

拉取 Docker 镜像

https://hub.docker.com/r/ownyourbits/nextcloudpi

## 联系

你可以在 [forums](https://help.nextcloud.com/c/support/appliances-docker-snappy-vm) 和 [Telegram group](https://t.me/NextCloudPi) 找到我们
