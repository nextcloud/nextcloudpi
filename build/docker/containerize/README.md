# Containerize NCP

_A project that started from a brainstorming in the Matrix Wiki chat room._  
First post & preliminary information and all that sort of stuff :pray: 

A very much Work In Progress, confirming and testing if a design idea could indeed work as thought-out theoretically

## Project idea 

Convert NCP and it's tool into something like a "binary" application container (or containers that only do "one thing/task") and services capable of being integrated with others, also making it possible to update/upgrade parts of the whole instead of everything.

Where ncp-config is the master container over the others, and this image can then be used as a service. 

## End goal
 
Containerize NCP completely

## Starting point & proof-of-concept

~~Convert `ncp-config`'s various scripts into individual containers & `ncp-config` to a container as well, being used as the master container, to control the others~~

Edit: To use one container, a bash control script (maybe?) called ncp-tools, or something, is entrypoint, possibly install it as plugin or only nc-encrypt which needs admin permissions. And put all the ncp script tools into one container directly using a bash script as a controller with case checking (?) for the different parts inside the container. Which right now seems to be the better option, but I don't know 🙏

Then combine that with nextcloud-aio, Nextcloud, PHP, mariaDB or a database and Caddy as front-end or reverse proxy, which is how I've used Caddy the most (reverse-proxy)

- [ ] Category re-design/re-structuring (?)

- [ ] New category suggestion
  - BACKUP
  - NETWORK
  - SYSTEM
  - UPDATE

<details><summary>Status</summary>

+ [ ] Stopped
+ [ ] Not started
+ [ ] Not continuing
+ [X] Researching
+ [X] Testing
+ [X] Ongoing
+ [ ] Paused
+ [ ] Completed
</details>

TODO
  1. - [X] Added a few relevant help articles, for basic understanding around the subject of the project.
  2. - [X] Added some more relevant help articles from the Docker documentation, can be really hard to find otherwise.
  3. - [x] Add links and script names to the categories for ncp-config until completed
  2. - [ ] Expand explanations (_partly done_)
  3. - [X] Begin research 
  4. - [ ] Begin testing
  5. - [ ] What else? ..

<!-- START Master scripts links -->
[ncp-config]: https://github.com/nextcloud/nextcloudpi/blob/master/bin/ncp-config
<!-- END Master scripts links -->

## Related Help articles & Documentation information

[Google - Best practice, Building containers][1]  
[Google - Best practice, Operating containers][2]  
[Docker - Best practice, Dockerfile][3]  
[Docker - Best practice, Development][4]  
[Docker - Best practice, Image-building][9]  
[Docker - Build enhancements][5]  
[Docker - Choosing a build driver][6]  
[Docker - Manage images][7]  
[Docker - Create a base image][8]  

[Docker - Multi-container apps][10]  
[Docker - Update the application][11]  
[Docker - Packaging your software][12]  
[Docker - Multi-stage builds][13]  
[Docker - Compose, Overview][14]  
[Docker - Reference, run command][15]  
[Docker - Specify a Dockerfile][18]  

[Docker - Announcement, Compose V2][16]

[Red Hat Dev - Blog Post, Systemd in Containers][17]

[Docker docs, Deprecated Features][docker-deprecated]

<!-- START Help articles -->
[1]: https://cloud.google.com/architecture/best-practices-for-building-containers#signal-handling
[2]: https://cloud.google.com/architecture/best-practices-for-operating-containers
[3]: https://docs.docker.com/develop/develop-images/dockerfile_best-practices/
[4]: https://docs.docker.com/develop/dev-best-practices/
[5]: https://docs.docker.com/develop/develop-images/build_enhancements/
[6]: https://docs.docker.com/build/building/drivers/
[7]: https://docs.docker.com/develop/develop-images/image_management/
[8]: https://docs.docker.com/develop/develop-images/baseimages/
[9]: https://docs.docker.com/get-started/09_image_best/
[10]: https://docs.docker.com/get-started/07_multi_container/
[11]: https://docs.docker.com/get-started/03_updating_app/
[12]: https://docs.docker.com/build/building/packaging/
[13]: https://docs.docker.com/build/building/multi-stage/
[14]: https://docs.docker.com/compose/
[15]: https://docs.docker.com/engine/reference/run
[16]: https://www.docker.com/blog/announcing-compose-v2-general-availability/
[17]: https://developers.redhat.com/blog/2019/04/24/how-to-run-systemd-in-a-container
[18]: https://docs.docker.com/engine/reference/commandline/build/#specify-a-dockerfile--f
[docker-deprecated]: https://docs.docker.com/engine/deprecated/
<!-- END Help articles -->

## Notes

[Gist Notes, Docker Commands][docker-cmd]

[Docker Hub, Nextcloudpi][ncp-docker-hub]

[Docker docs, IPv6 Support][docker-ipv6]

<!-- START Notes Links --> 
[docker-cmd]: https://gist.github.com/ZendaiOwl/f80b09d792d3b7ed51eb00e72ab866de
[ncp-docker-hub]: https://hub.docker.com/r/ownyourbits/nextcloudpi
[docker-orchestration]: https://docs.docker.com/get-started/orchestration/
[docker-ipv6]: https://docs.docker.com/config/daemon/ipv6/
<!-- END Notes Links -->

A Nextcloud instance's directories to restore settings.

1. Config
2. Database
3. Data (User files & App data (?)) 

<details><summary>CMD's to get IP</summary>

```bash
# INTERNAL IP ADDRESS
# IPv4 - String manipulation
"$(ip addr | grep 192 | awk '{print $2}' | cut -b 1-14)"

# IPv4 & IPv6 - String manipulation
ip a | grep "scope global" | awk '{print $2}' | head -2 | sed 's|/.*||g'

# IPv4, IPv6 & Link-local - JSON
ip -j address | jq '.[2].addr_info' | jq '.[].local'

# Without quotes - JSON
ip -j address | jq '.[2].addr_info' | jq '.[].local' | sed 's|"||g'

# IPv4 - JSON
ip -j address | jq '.[2].addr_info' | jq '.[0].local' | sed 's|"||g'

# IPv6 - JSON
ip -j address | jq '.[2].addr_info' | jq '.[1].local' | sed 's|"||g'

# Link-local - JSON
ip -j address | jq '.[2].addr_info' | jq '.[2].local' | sed 's|"||g'
```

```bash
# PUBLIC IP ADDRESS
# IPv4
curl -sL -m4 -4 https://icanhazip.com
# IPv6
curl -sL -m4 -6 https://icanhazip.com
```
</details>

#### Docker Context

[Docker docs, Manage contexts](https://docs.docker.com/engine/reference/commandline/context/)

#### Docker Buildx

```bash
docker buildx build . \
--file /path/Dockerfile \
--tag ${OWNER}/${REPO}:${TAG}
# In this context it's regarding the docker hub
# Owner, Repo & Tag @DockerHub
```

Options

- `--platform`
  + Architecture(s) for the image
- `--builder`
- `--push`
- `--build-arg`
  + Used to override default environment/argument variables set in a Dockerfile or add new ones.

Create builder

```bash
docker buildx create --use \
--name container \
--driver docker-container \
--platform linux/arm64,linux/amd64,linux/armhf
```

[Docker Driver][docker-driver]

[docker-driver]: https://docs.docker.com/build/building/drivers/docker/

- `docker`
- `docker-container` _Recommended for multiple architecture compatibility_
- `kubernetes` 

[Orchestration][docker-orchestration]

- `Docker Swarm` _Default_
- `Kubernetes` _Deprecated in stack & context @v20.10 [Source](https://docs.docker.com/engine/deprecated/#kubernetes-stack-and-context-support)_


#### Docker Compose 

[Docker docs, Compose extend services][docker-extend-services]  
[Docker docs, Compose networking][compose-networking]  
[Docker docs, Compose in production][compose-production]  
[Docker docs, Compose V2 compatibility][compose-v2-compat]  
[Docker docs, Compose FAQ][compose-faq]  

<!-- START Compose Links -->
[docker-extend-services]: https://docs.docker.com/compose/extends/
[compose-networking]: https://docs.docker.com/compose/networking/
[compose-production]: https://docs.docker.com/compose/production/
[compose-v2-compat]: https://docs.docker.com/compose/cli-command-compatibility/
[compose-faq]: https://docs.docker.com/compose/faq/
<!-- END Compose Links -->

Old syntax - V1  

- `docker-compose`

New syntax - V2  

- `docker compose`

<details><summary>Ex. docker-compose.yml</summary>

```yaml
services:
  nextcloudpi:
    command: "$(ip addr | grep 192 | awk '{print $2}' | cut -b 1-14)"
    container_name: nextcloudpi
    image: ownyourbits/nextcloudpi:latest
    ports:
    - published: 80
      target: 80
    - published: 443
      target: 443
    - published: 4443
      target: 4443
    restart: unless-stopped
    volumes:
    - ncdata:/data:ro
    - /etc/localtime:/etc/localtime:ro
version: '3.3'
volumes:
  ncdata:
    external: false

```
</details>

<!--
[Notes - Installation Commands][cmd-install]
[cmd-install]: https://gist.github.com/ZendaiOwl/9d4184aac07e2f888201d227a0fa2b39
-->

#### Docker Run 

A working `docker run` command with the `--init` flag for PID 1 management and reaping of zombie processes.

```bash
docker run --init \
--publish 4443:4443 \
--publish 443:443 \
--publish 80:80 \
--volume ncdata:/data \
--name nextcloudpi \
--detach ownyourbits/nextcloudpi:latest \
"$(ip addr | grep 192 | awk '{print $2}' | cut -b 1-14)"
```

- `"$(ip addr | grep 192 | awk '{print $2}' | cut -b 1-14)"`

_Greps an IP-address beginning with 192, modify to fit your system, test in terminal._

_See [CMD's to get IP](https://github.com/nextcloud/nextcloudpi/blob/containerize/build/docker/containerize/README.md#notes) above for other examples._

[Nextcloud AIO][nextcloud-aio]

_Used as example and reference_

<details><summary>Docker Run AIO arm64</summary>

```bash
sudo docker run \
--sig-proxy=false \
--name nextcloud-aio-mastercontainer \
--restart always \
--publish 80:80 \
--publish 8080:8080 \
--publish 8443:8443 \
--volume nextcloud_aio_mastercontainer:/mnt/docker-aio-config \
--volume /var/run/docker.sock:/var/run/docker.sock:ro \
nextcloud/all-in-one:latest-arm64
```

</details>

[Reverse proxy AIO][aio-reverse-proxy]

[nextcloud-aio]: https://github.com/nextcloud/all-in-one

[aio-reverse-proxy]: https://github.com/nextcloud/all-in-one/blob/main/reverse-proxy.md

#### Dockerfile

[Docker docs, Dockerfile reference][dockerfile-ref]

[dockerfile-ref]: https://docs.docker.com/engine/reference/builder/

Naming scheme

- `Dockerfile.name`

Use `ADD` in Dockerfile to import scripts

- `ADD ${URL} ${PATH}` 

URL to fetch scripts in raw text

+ `https://raw.githubusercontent.com/`
+ Ex. `https://raw.githubusercontent.com/${OWNER}/${REPO}/${BRANCH}/${PATH}`

Instead of using the ARG example below and getting each individual script.
Use [alpine-git][alpinegit] image instead and clone repo, alternatively clone it beforehand

[alpinegit]: https://hub.docker.com/r/alpine/git

<details><summary>Docker ARG</summary>

ARG|DESCRIPTION
-:|:-
OWNER|Repository owner @ GitHub
REPO|Repository @ GitHub
BRANCH|Branch of repository @ GitHub
PATH|Path to the script directory
CATEGORY|Category in /bin/ncp (PATH)
PATH_BASH|Path to bash binary
URL|GH URL to get scripts in raw text

_ARG Example_
```docker
ARG OWNER ["nextcloud"]
ARG REPO ["nextcloudpi"]
ARG BRANCH ["master"]
ARG PATH ["bin/ncp"]
ARG CATEGORY ["BACKUPS"]
ARG SCRIPT ["nc-backup-auto.sh"]
ARG URL ["https://raw.githubusercontent.com"]
ARG PATH_BASH ["/usr/local/bin/bash"]

ADD ["${URL}/${OWNER}/${REPO}/${BRANCH}/${PATH}/${CATEGORY}/${SCRIPT}","${PATH}/${CATEGORY}/${SCRIPT}"]
COPY --from=bash ["$PATH_BASH", "$PATH_BASH"]
RUN ["$PATH_BASH","-c","chmod +x ${PATH}/${CATEGORY}/${SCRIPT}"]
SHELL ["$PATH_BASH"]
ENTRYPOINT ["$PATH_BASH","-c","${PATH}/${CATEGORY}/${SCRIPT}"]
```
</details>

### Existing Containers

- [Nextcloud][nextcloud]
- [Nextcloud AIO][nextcloud-aio]
- [Linuxserver.io/Nextcloud][linuxserver-nextcloud]
- [MariaDB][mariadb]
- [MySQL][mysql]
- [PHP][php]
- [Debian][debian]
- [Alpine][alpine]
- [Bash][bash]
- [Curl][curl]
- Apache2
- Caddy

<!-- START Container Links -->
[nextcloud]: https://hub.docker.com/_/nextcloud
[linuxserver-nextcloud]: https://hub.docker.com/r/linuxserver/nextcloud  
[mariadb]: https://hub.docker.com/_/mariadb
[mysql]: https://hub.docker.com/_/mysql
[php]: https://hub.docker.com/_/php
[debian]: https://hub.docker.com/_/debian
[alpine]: https://hub.docker.com/_/alpine
[bash]: https://hub.docker.com/_/bash
[curl]: https://hub.docker.com/r/curlimages/curl
<!-- END Container Links -->

#### Dockerized Bash Scripts - Examples

1. [Transforming Bash Script to Docker Compose][ex1]  
2. [Automatic Docker Container creation w/bash script][ex2]  
3. [Docker w/Shell script or Makefile][ex3]  
4. [Run scripts, Docker arguments][ex4]  
5. [Run a scripts inside Docker container using Shell script][ex5]  
6. [Run Script, with dev docker image][ex6]  

[ex1]: https://fiberplane.dev/blog/transforming-bash-scripts-into-docker-compose/
[ex2]: https://assistanz.com/automatic-docker-container-creation-via-linux-bash-script/
[ex3]: https://ypereirareis.github.io/blog/2015/05/04/docker-with-shell-script-or-makefile/
[ex4]: https://devopscube.com/run-scripts-docker-arguments/
[ex5]: https://www.commands.dev/workflows/run_a_script_inside_a_docker_container_using_a_shell_script
[ex6]: https://gist.github.com/austinhyde/2e39c01d6b0ebf4aef7409e129c47ea7

<!-- START Directory links -->
[dirCategories]: https://github.com/nextcloud/nextcloudpi/tree/containerize/bin/ncp
[dirBackups]: https://github.com/nextcloud/nextcloudpi/tree/containerize/bin/ncp/BACKUPS
[dirConfig]: https://github.com/nextcloud/nextcloudpi/tree/containerize/bin/ncp/CONFIG
[dirNetworking]: https://github.com/nextcloud/nextcloudpi/tree/containerize/bin/ncp/NETWORKING
[dirSecurity]: https://github.com/nextcloud/nextcloudpi/tree/containerize/bin/ncp/SECURITY
[dirSystem]: https://github.com/nextcloud/nextcloudpi/tree/containerize/bin/ncp/SYSTEM
[dirTools]: https://github.com/nextcloud/nextcloudpi/tree/containerize/bin/ncp/TOOLS
[dirUpdates]: https://github.com/nextcloud/nextcloudpi/tree/containerize/bin/ncp/UPDATES
<!-- END Directory links -->

---

#### Scripts, Dependencies & Packages

> _IMPORTANT_

Script shebang must be `#!/usr/bin/env bash` and not `#!/bin/bash`, to be compatible with the `bash` [docker image][bash] natively.

> Notes  
> There are a few main things that are important to note regarding this image:
> 
> Bash itself is installed at /usr/local/bin/bash, not /bin/bash, so the recommended shebang is #!/usr/bin/env bash, not #!/bin/bash (or explicitly running your script via bash /.../script.sh instead of letting the shebang invoke Bash automatically). The image does not include /bin/bash, but if it is installed via the package manager included in the image, that package will install to /bin/bash and might cause confusion (although /usr/local/bin is ahead of /bin in $PATH, so as long as plain bash or /usr/bin/env are used consistently, the image-provided Bash will be preferred).
> 
> Bash is the only thing included, so if your scripts rely on external tools (such as jq, for example), those will need to be added manually (via apk add --no-cache jq, for example).

Nextcloudpi repository file-list

<details><summary>File list of Nextcloudpi</summary>

```bash
install.sh
lamp.sh
ncp.sh
post-inst.sh
run_update_history.sh
tag_and_push.sh
update.sh
changelog.md
CONTRIBUTING.md
README.md
file_list.txt
bin/ncp
bin/ncp/BACKUPS
bin/ncp/BACKUPS/nc-backup-auto.sh
bin/ncp/BACKUPS/nc-backup.sh
bin/ncp/BACKUPS/nc-export-ncp.sh
bin/ncp/BACKUPS/nc-import-ncp.sh
bin/ncp/BACKUPS/nc-restore.sh
bin/ncp/BACKUPS/nc-restore-snapshot.sh
bin/ncp/BACKUPS/nc-rsync-auto.sh
bin/ncp/BACKUPS/nc-rsync.sh
bin/ncp/BACKUPS/nc-snapshot-auto.sh
bin/ncp/BACKUPS/nc-snapshot.sh
bin/ncp/BACKUPS/nc-snapshot-sync.sh
bin/ncp-check-nc-version
bin/ncp-check-updates
bin/ncp-check-version
bin/ncp-config
bin/ncp/CONFIG
bin/ncp/CONFIG/nc-admin.sh
bin/ncp/CONFIG/nc-database.sh
bin/ncp/CONFIG/nc-datadir.sh
bin/ncp/CONFIG/nc-httpsonly.sh
bin/ncp/CONFIG/nc-init.sh
bin/ncp/CONFIG/nc-limits.sh
bin/ncp/CONFIG/nc-nextcloud.sh
bin/ncp/CONFIG/nc-passwd.sh
bin/ncp/CONFIG/nc-prettyURL.sh
bin/ncp/CONFIG/nc-previews-auto.sh
bin/ncp/CONFIG/nc-scan-auto.sh
bin/ncp/CONFIG/nc-trusted-domains.sh
bin/ncp/CONFIG/nc-webui.sh
bin/ncp-diag
bin/ncp-dist-upgrade
bin/ncp-docker-hook
bin/ncp/NETWORKING
bin/ncp/NETWORKING/dnsmasq.sh
bin/ncp/NETWORKING/duckDNS.sh
bin/ncp/NETWORKING/freeDNS.sh
bin/ncp/NETWORKING/letsencrypt.sh
bin/ncp/NETWORKING/namecheapDNS.sh
bin/ncp/NETWORKING/nc-forward-ports.sh
bin/ncp/NETWORKING/nc-static-IP.sh
bin/ncp/NETWORKING/nc-trusted-proxies.sh
bin/ncp/NETWORKING/NFS.sh
bin/ncp/NETWORKING/no-ip.sh
bin/ncp/NETWORKING/samba.sh
bin/ncp/NETWORKING/spDYN.sh
bin/ncp/NETWORKING/SSH.sh
bin/ncp-provisioning.sh
bin/ncp-report
bin/ncp/SECURITY
bin/ncp/SECURITY/fail2ban.sh
bin/ncp/SECURITY/modsecurity.sh
bin/ncp/SECURITY/nc-audit.sh
bin/ncp/SECURITY/nc-encrypt.sh
bin/ncp/SECURITY/UFW.sh
bin/ncp-suggestions
bin/ncp/SYSTEM
bin/ncp/SYSTEM/metrics.sh
bin/ncp/SYSTEM/nc-automount.sh
bin/ncp/SYSTEM/nc-hdd-monitor.sh
bin/ncp/SYSTEM/nc-hdd-test.sh
bin/ncp/SYSTEM/nc-info.sh
bin/ncp/SYSTEM/nc-ramlogs.sh
bin/ncp/SYSTEM/nc-swapfile.sh
bin/ncp/SYSTEM/nc-zram.sh
bin/ncp-test-updates
bin/ncp/TOOLS
bin/ncp/TOOLS/nc-fix-permissions.sh
bin/ncp/TOOLS/nc-format-USB.sh
bin/ncp/TOOLS/nc-maintenance.sh
bin/ncp/TOOLS/nc-previews.sh
bin/ncp/TOOLS/nc-scan.sh
bin/ncp-update
bin/ncp-update-nc
bin/ncp/UPDATES
bin/ncp/UPDATES/nc-autoupdate-ncp.sh
bin/ncp/UPDATES/nc-autoupdate-nc.sh
bin/ncp/UPDATES/nc-notify-updates.sh
bin/ncp/UPDATES/nc-update-nc-apps-auto.sh
bin/ncp/UPDATES/nc-update-nc-apps.sh
bin/ncp/UPDATES/nc-update-nextcloud.sh
bin/ncp/UPDATES/nc-update.sh
bin/ncp/UPDATES/unattended-upgrades.sh
bin/nextcloud-domain.sh
build/armbian
build/armbian/armbian.sh
build/armbian/config-odroidc2.conf
build/armbian/config-orangepizeroplus2-h5.conf
build/batch.sh
build/build-docker.sh
build/buildlib.sh
build/build-LXC.sh
build/build-LXD.sh
build/build-SD-armbian.sh
build/build-SD-berryboot.sh
build/build-SD-rpi.sh
build/build-VM.sh
build/docker
build/docker/debian-ncp
build/docker/debian-ncp/run-parts.sh
build/docker/docker-compose-ncpdev.yml
build/docker/docker-compose.yml
build/docker/Dockerfile
build/docker/lamp
build/docker/lamp/010lamp
build/docker/nextcloud
build/docker/nextcloud/020nextcloud
build/docker/nextcloudpi
build/docker/nextcloudpi/000ncp
build/lxc_config
build/Vagrantfile
etc/background
etc/library.sh
etc/logo
etc/ncp-ascii.txt
etc/ncp.cfg
etc/ncp-config.d
etc/ncp-config.d/dnsmasq.cfg
etc/ncp-config.d/duckDNS.cfg
etc/ncp-config.d/fail2ban.cfg
etc/ncp-config.d/freeDNS.cfg
etc/ncp-config.d/l10n
etc/ncp-config.d/l10n/DDNS_duckDNS
etc/ncp-config.d/l10n/DDNS_duckDNS/duckDNS.json
etc/ncp-config.d/l10n/DDNS_duckDNS/es.json
etc/ncp-config.d/l10n/DDNS_duckDNS/pt.json
etc/ncp-config.d/l10n/DDNS_duckDNS/zh.json
etc/ncp-config.d/l10n/DDNS_freeDNS
etc/ncp-config.d/l10n/DDNS_freeDNS/es.json
etc/ncp-config.d/l10n/DDNS_freeDNS/freeDNS.json
etc/ncp-config.d/l10n/DDNS_freeDNS/pt.json
etc/ncp-config.d/l10n/DDNS_freeDNS/zh.json
etc/ncp-config.d/l10n/DDNS_no-ip
etc/ncp-config.d/l10n/DDNS_no-ip/es.json
etc/ncp-config.d/l10n/DDNS_no-ip/no-ip.json
etc/ncp-config.d/l10n/DDNS_no-ip/pt.json
etc/ncp-config.d/l10n/DDNS_no-ip/zh.json
etc/ncp-config.d/l10n/DDNS_spDYN
etc/ncp-config.d/l10n/DDNS_spDYN/es.json
etc/ncp-config.d/l10n/DDNS_spDYN/pt.json
etc/ncp-config.d/l10n/DDNS_spDYN/spDYN.json
etc/ncp-config.d/l10n/DDNS_spDYN/zh.json
etc/ncp-config.d/l10n/dnsmasq
etc/ncp-config.d/l10n/dnsmasq/es.json
etc/ncp-config.d/l10n/dnsmasq/pt.json
etc/ncp-config.d/l10n/dnsmasq/ru.json
etc/ncp-config.d/l10n/dnsmasq/zh.json
etc/ncp-config.d/l10n/fail2ban
etc/ncp-config.d/l10n/fail2ban/es.json
etc/ncp-config.d/l10n/fail2ban/pt.json
etc/ncp-config.d/l10n/fail2ban/ru.json
etc/ncp-config.d/l10n/fail2ban/zh.json
etc/ncp-config.d/l10n/letsencrypt
etc/ncp-config.d/l10n/letsencrypt/es.json
etc/ncp-config.d/l10n/letsencrypt/pt.json
etc/ncp-config.d/l10n/letsencrypt/ru.json
etc/ncp-config.d/l10n/letsencrypt/zh.json
etc/ncp-config.d/l10n/modsecurity
etc/ncp-config.d/l10n/modsecurity/es.json
etc/ncp-config.d/l10n/modsecurity/pt.json
etc/ncp-config.d/l10n/modsecurity/ru.json
etc/ncp-config.d/l10n/modsecurity/zh.json
etc/ncp-config.d/l10n/nc-admin
etc/ncp-config.d/l10n/nc-admin/es.json
etc/ncp-config.d/l10n/nc-admin/pt.json
etc/ncp-config.d/l10n/nc-admin/ru.json
etc/ncp-config.d/l10n/nc-admin/zh.json
etc/ncp-config.d/l10n/nc-audit
etc/ncp-config.d/l10n/nc-audit/de.json
etc/ncp-config.d/l10n/nc-audit/pt.json
etc/ncp-config.d/l10n/nc-audit/zh.json
etc/ncp-config.d/l10n/nc-automount
etc/ncp-config.d/l10n/nc-automount/de.json
etc/ncp-config.d/l10n/nc-automount/es.json
etc/ncp-config.d/l10n/nc-automount/pt.json
etc/ncp-config.d/l10n/nc-automount/ru.json
etc/ncp-config.d/l10n/nc-automount/zh.json
etc/ncp-config.d/l10n/nc-autoupdate-nc
etc/ncp-config.d/l10n/nc-autoupdate-ncp
etc/ncp-config.d/l10n/nc-autoupdate-ncp/de.json
etc/ncp-config.d/l10n/nc-autoupdate-ncp/es.json
etc/ncp-config.d/l10n/nc-autoupdate-ncp/pt.json
etc/ncp-config.d/l10n/nc-autoupdate-ncp/ru.json
etc/ncp-config.d/l10n/nc-autoupdate-nc/pt.json
etc/ncp-config.d/l10n/nc-autoupdate-ncp/zh.json
etc/ncp-config.d/l10n/nc-autoupdate-nc/zh.json
etc/ncp-config.d/l10n/nc-backup
etc/ncp-config.d/l10n/nc-backup-auto
etc/ncp-config.d/l10n/nc-backup-auto/de.json
etc/ncp-config.d/l10n/nc-backup-auto/es.json
etc/ncp-config.d/l10n/nc-backup-auto/pt.json
etc/ncp-config.d/l10n/nc-backup-auto/ru.json
etc/ncp-config.d/l10n/nc-backup-auto/zh.json
etc/ncp-config.d/l10n/nc-backup/de.json
etc/ncp-config.d/l10n/nc-backup/es.json
etc/ncp-config.d/l10n/nc-backup/pt.json
etc/ncp-config.d/l10n/nc-backup/ru.json
etc/ncp-config.d/l10n/nc-backup/zh.json
etc/ncp-config.d/l10n/nc-database
etc/ncp-config.d/l10n/nc-database/de.json
etc/ncp-config.d/l10n/nc-database/es.json
etc/ncp-config.d/l10n/nc-database/pt.json
etc/ncp-config.d/l10n/nc-database/ru.json
etc/ncp-config.d/l10n/nc-database/zh.json
etc/ncp-config.d/l10n/nc-datadir
etc/ncp-config.d/l10n/nc-datadir/de.json
etc/ncp-config.d/l10n/nc-datadir/es.json
etc/ncp-config.d/l10n/nc-datadir/pt.json
etc/ncp-config.d/l10n/nc-datadir/ru.json
etc/ncp-config.d/l10n/nc-datadir/zh.json
etc/ncp-config.d/l10n/nc-export-ncp
etc/ncp-config.d/l10n/nc-export-ncp/de.json
etc/ncp-config.d/l10n/nc-export-ncp/es.json
etc/ncp-config.d/l10n/nc-export-ncp/pt.json
etc/ncp-config.d/l10n/nc-export-ncp/ru.json
etc/ncp-config.d/l10n/nc-export-ncp/zh.json
etc/ncp-config.d/l10n/nc-fix-permissions
etc/ncp-config.d/l10n/nc-fix-permissions/de.json
etc/ncp-config.d/l10n/nc-fix-permissions/es.json
etc/ncp-config.d/l10n/nc-fix-permissions/pt.json
etc/ncp-config.d/l10n/nc-fix-permissions/zh.json
etc/ncp-config.d/l10n/nc-format-USB
etc/ncp-config.d/l10n/nc-format-USB/de.json
etc/ncp-config.d/l10n/nc-format-USB/es.json
etc/ncp-config.d/l10n/nc-format-USB/pt.json
etc/ncp-config.d/l10n/nc-format-USB/ru.json
etc/ncp-config.d/l10n/nc-format-USB/zh.json
etc/ncp-config.d/l10n/nc-forward-ports
etc/ncp-config.d/l10n/nc-forward-ports/de.json
etc/ncp-config.d/l10n/nc-forward-ports/es.json
etc/ncp-config.d/l10n/nc-forward-ports/pt.json
etc/ncp-config.d/l10n/nc-forward-ports/ru.json
etc/ncp-config.d/l10n/nc-forward-ports/zh.json
etc/ncp-config.d/l10n/nc-hdd-monitor
etc/ncp-config.d/l10n/nc-hdd-monitor/pt.json
etc/ncp-config.d/l10n/nc-hdd-monitor/zh.json
etc/ncp-config.d/l10n/nc-hdd-test
etc/ncp-config.d/l10n/nc-hdd-test/pt.json
etc/ncp-config.d/l10n/nc-hdd-test/zh.json
etc/ncp-config.d/l10n/nc-httpsonly
etc/ncp-config.d/l10n/nc-httpsonly/de.json
etc/ncp-config.d/l10n/nc-httpsonly/es.json
etc/ncp-config.d/l10n/nc-httpsonly/pt.json
etc/ncp-config.d/l10n/nc-httpsonly/ru.json
etc/ncp-config.d/l10n/nc-httpsonly/zh.json
etc/ncp-config.d/l10n/nc-import-ncp
etc/ncp-config.d/l10n/nc-import-ncp/de.json
etc/ncp-config.d/l10n/nc-import-ncp/es.json
etc/ncp-config.d/l10n/nc-import-ncp/pt.json
etc/ncp-config.d/l10n/nc-import-ncp/ru.json
etc/ncp-config.d/l10n/nc-import-ncp/zh.json
etc/ncp-config.d/l10n/nc-info
etc/ncp-config.d/l10n/nc-info/de.json
etc/ncp-config.d/l10n/nc-info/es.json
etc/ncp-config.d/l10n/nc-info/pt.json
etc/ncp-config.d/l10n/nc-info/zh.json
etc/ncp-config.d/l10n/nc-init
etc/ncp-config.d/l10n/nc-init/de.json
etc/ncp-config.d/l10n/nc-init/es.json
etc/ncp-config.d/l10n/nc-init/pt.json
etc/ncp-config.d/l10n/nc-init/ru.json
etc/ncp-config.d/l10n/nc-init/zh.json
etc/ncp-config.d/l10n/nc-limits
etc/ncp-config.d/l10n/nc-limits/de.json
etc/ncp-config.d/l10n/nc-limits/es.json
etc/ncp-config.d/l10n/nc-limits/pt.json
etc/ncp-config.d/l10n/nc-limits/ru.json
etc/ncp-config.d/l10n/nc-limits/zh.json
etc/ncp-config.d/l10n/nc-nextcloud
etc/ncp-config.d/l10n/nc-nextcloud/de.json
etc/ncp-config.d/l10n/nc-nextcloud/es.json
etc/ncp-config.d/l10n/nc-nextcloud/pt.json
etc/ncp-config.d/l10n/nc-nextcloud/ru.json
etc/ncp-config.d/l10n/nc-nextcloud/zh.json
etc/ncp-config.d/l10n/nc-notify-updates
etc/ncp-config.d/l10n/nc-notify-updates/de.json
etc/ncp-config.d/l10n/nc-notify-updates/es.json
etc/ncp-config.d/l10n/nc-notify-updates/pt.json
etc/ncp-config.d/l10n/nc-notify-updates/ru.json
etc/ncp-config.d/l10n/nc-notify-updates/zh.json
etc/ncp-config.d/l10n/nc-passwd
etc/ncp-config.d/l10n/nc-passwd/de.json
etc/ncp-config.d/l10n/nc-passwd/es.json
etc/ncp-config.d/l10n/nc-passwd/pt.json
etc/ncp-config.d/l10n/nc-passwd/ru.json
etc/ncp-config.d/l10n/nc-passwd/zh.json
etc/ncp-config.d/l10n/nc-prettyURL
etc/ncp-config.d/l10n/nc-prettyURL/pt.json
etc/ncp-config.d/l10n/nc-prettyURL/zh.json
etc/ncp-config.d/l10n/nc-previews
etc/ncp-config.d/l10n/nc-previews/pt.json
etc/ncp-config.d/l10n/nc-previews/zh.json
etc/ncp-config.d/l10n/nc-ramlogs
etc/ncp-config.d/l10n/nc-ramlogs/de.json
etc/ncp-config.d/l10n/nc-ramlogs/es.json
etc/ncp-config.d/l10n/nc-ramlogs/pt.json
etc/ncp-config.d/l10n/nc-ramlogs/ru.json
etc/ncp-config.d/l10n/nc-ramlogs/zh.json
etc/ncp-config.d/l10n/nc-restore
etc/ncp-config.d/l10n/nc-restore/de.json
etc/ncp-config.d/l10n/nc-restore/es.json
etc/ncp-config.d/l10n/nc-restore/pt.json
etc/ncp-config.d/l10n/nc-restore/ru.json
etc/ncp-config.d/l10n/nc-restore/zh.json
etc/ncp-config.d/l10n/nc-rsync
etc/ncp-config.d/l10n/nc-rsync-auto
etc/ncp-config.d/l10n/nc-rsync-auto/es.json
etc/ncp-config.d/l10n/nc-rsync-auto/pt.json
etc/ncp-config.d/l10n/nc-rsync-auto/ru.json
etc/ncp-config.d/l10n/nc-rsync-auto/zh.json
etc/ncp-config.d/l10n/nc-rsync/es.json
etc/ncp-config.d/l10n/nc-rsync/pt.json
etc/ncp-config.d/l10n/nc-rsync/ru.json
etc/ncp-config.d/l10n/nc-rsync/zh.json
etc/ncp-config.d/l10n/nc-scan
etc/ncp-config.d/l10n/nc-scan-auto
etc/ncp-config.d/l10n/nc-scan-auto/de.json
etc/ncp-config.d/l10n/nc-scan-auto/es.json
etc/ncp-config.d/l10n/nc-scan-auto/pt.json
etc/ncp-config.d/l10n/nc-scan-auto/ru.json
etc/ncp-config.d/l10n/nc-scan-auto/zh.json
etc/ncp-config.d/l10n/nc-scan/de.json
etc/ncp-config.d/l10n/nc-scan/es.json
etc/ncp-config.d/l10n/nc-scan/pt.json
etc/ncp-config.d/l10n/nc-scan/zh.json
etc/ncp-config.d/l10n/nc-snapshot
etc/ncp-config.d/l10n/nc-snapshot-auto
etc/ncp-config.d/l10n/nc-snapshot-auto/de.json
etc/ncp-config.d/l10n/nc-snapshot-auto/es.json
etc/ncp-config.d/l10n/nc-snapshot-auto/pt.json
etc/ncp-config.d/l10n/nc-snapshot-auto/ru.json
etc/ncp-config.d/l10n/nc-snapshot-auto/zh.json
etc/ncp-config.d/l10n/nc-snapshot/de.json
etc/ncp-config.d/l10n/nc-snapshot/es.json
etc/ncp-config.d/l10n/nc-snapshot/pt.json
etc/ncp-config.d/l10n/nc-snapshot/ru.json
etc/ncp-config.d/l10n/nc-snapshot-sync
etc/ncp-config.d/l10n/nc-snapshot-sync/es.json
etc/ncp-config.d/l10n/nc-snapshot-sync/pt.json
etc/ncp-config.d/l10n/nc-snapshot-sync/ru.json
etc/ncp-config.d/l10n/nc-snapshot-sync/zh.json
etc/ncp-config.d/l10n/nc-snapshot/zh.json
etc/ncp-config.d/l10n/nc-static-IP
etc/ncp-config.d/l10n/nc-static-IP/de.json
etc/ncp-config.d/l10n/nc-static-IP/es.json
etc/ncp-config.d/l10n/nc-static-IP/pt.json
etc/ncp-config.d/l10n/nc-static-IP/ru.json
etc/ncp-config.d/l10n/nc-static-IP/zh.json
etc/ncp-config.d/l10n/nc-swapfile
etc/ncp-config.d/l10n/nc-swapfile/de.json
etc/ncp-config.d/l10n/nc-swapfile/es.json
etc/ncp-config.d/l10n/nc-swapfile/pt.json
etc/ncp-config.d/l10n/nc-swapfile/ru.json
etc/ncp-config.d/l10n/nc-swapfile/zh.json
etc/ncp-config.d/l10n/nc-update
etc/ncp-config.d/l10n/nc-update/de.json
etc/ncp-config.d/l10n/nc-update-nextcloud
etc/ncp-config.d/l10n/nc-update-nextcloud/pt.json
etc/ncp-config.d/l10n/nc-update-nextcloud/zh.json
etc/ncp-config.d/l10n/nc-update/pt.json
etc/ncp-config.d/l10n/nc-update/zh.json
etc/ncp-config.d/l10n/nc-webui
etc/ncp-config.d/l10n/nc-webui/de.json
etc/ncp-config.d/l10n/nc-webui/es.json
etc/ncp-config.d/l10n/nc-webui/pt.json
etc/ncp-config.d/l10n/nc-webui/ru.json
etc/ncp-config.d/l10n/nc-webui/zh.json
etc/ncp-config.d/l10n/nc-wifi
etc/ncp-config.d/l10n/nc-wifi/de.json
etc/ncp-config.d/l10n/nc-wifi/pt.json
etc/ncp-config.d/l10n/nc-zram
etc/ncp-config.d/l10n/nc-zram/es.json
etc/ncp-config.d/l10n/nc-zram/pt.json
etc/ncp-config.d/l10n/nc-zram/ru.json
etc/ncp-config.d/l10n/nc-zram/zh.json
etc/ncp-config.d/l10n/NFS
etc/ncp-config.d/l10n/NFS/es.json
etc/ncp-config.d/l10n/NFS/pt.json
etc/ncp-config.d/l10n/NFS/ru.json
etc/ncp-config.d/l10n/NFS/zh.json
etc/ncp-config.d/l10n/samba
etc/ncp-config.d/l10n/samba/es.json
etc/ncp-config.d/l10n/samba/pt.json
etc/ncp-config.d/l10n/samba/ru.json
etc/ncp-config.d/l10n/samba/zh.json
etc/ncp-config.d/l10n/SSH
etc/ncp-config.d/l10n/SSH/es.json
etc/ncp-config.d/l10n/SSH/pt.json
etc/ncp-config.d/l10n/SSH/ru.json
etc/ncp-config.d/l10n/SSH/zh.json
etc/ncp-config.d/l10n/UFW
etc/ncp-config.d/l10n/UFW/es.json
etc/ncp-config.d/l10n/UFW/pt.json
etc/ncp-config.d/l10n/UFW/ru.json
etc/ncp-config.d/l10n/UFW/zh.json
etc/ncp-config.d/l10n/unattended-upgrades
etc/ncp-config.d/l10n/unattended-upgrades/de.json
etc/ncp-config.d/l10n/unattended-upgrades/es.json
etc/ncp-config.d/l10n/unattended-upgrades/pt.json
etc/ncp-config.d/l10n/unattended-upgrades/ru.json
etc/ncp-config.d/l10n/unattended-upgrades/zh.json
etc/ncp-config.d/letsencrypt.cfg
etc/ncp-config.d/metrics.cfg
etc/ncp-config.d/modsecurity.cfg
etc/ncp-config.d/namecheapDNS.cfg
etc/ncp-config.d/nc-admin.cfg
etc/ncp-config.d/nc-audit.cfg
etc/ncp-config.d/nc-automount.cfg
etc/ncp-config.d/nc-autoupdate-nc.cfg
etc/ncp-config.d/nc-autoupdate-ncp.cfg
etc/ncp-config.d/nc-backup-auto.cfg
etc/ncp-config.d/nc-backup.cfg
etc/ncp-config.d/nc-database.cfg
etc/ncp-config.d/nc-datadir.cfg
etc/ncp-config.d/nc-encrypt.cfg
etc/ncp-config.d/nc-export-ncp.cfg
etc/ncp-config.d/nc-fix-permissions.cfg
etc/ncp-config.d/nc-format-USB.cfg
etc/ncp-config.d/nc-forward-ports.cfg
etc/ncp-config.d/nc-hdd-monitor.cfg
etc/ncp-config.d/nc-hdd-test.cfg
etc/ncp-config.d/nc-httpsonly.cfg
etc/ncp-config.d/nc-import-ncp.cfg
etc/ncp-config.d/nc-info.cfg
etc/ncp-config.d/nc-init.cfg
etc/ncp-config.d/nc-limits.cfg
etc/ncp-config.d/nc-maintenance.cfg
etc/ncp-config.d/nc-nextcloud.cfg
etc/ncp-config.d/nc-notify-updates.cfg
etc/ncp-config.d/nc-passwd.cfg
etc/ncp-config.d/nc-prettyURL.cfg
etc/ncp-config.d/nc-previews-auto.cfg
etc/ncp-config.d/nc-previews.cfg
etc/ncp-config.d/nc-ramlogs.cfg
etc/ncp-config.d/nc-restore.cfg
etc/ncp-config.d/nc-restore-snapshot.cfg
etc/ncp-config.d/nc-rsync-auto.cfg
etc/ncp-config.d/nc-rsync.cfg
etc/ncp-config.d/nc-scan-auto.cfg
etc/ncp-config.d/nc-scan.cfg
etc/ncp-config.d/nc-snapshot-auto.cfg
etc/ncp-config.d/nc-snapshot.cfg
etc/ncp-config.d/nc-snapshot-sync.cfg
etc/ncp-config.d/nc-static-IP.cfg
etc/ncp-config.d/nc-swapfile.cfg
etc/ncp-config.d/nc-trusted-domains.cfg
etc/ncp-config.d/nc-trusted-proxies.cfg
etc/ncp-config.d/nc-update.cfg
etc/ncp-config.d/nc-update-nc-apps-auto.cfg
etc/ncp-config.d/nc-update-nc-apps.cfg
etc/ncp-config.d/nc-update-nextcloud.cfg
etc/ncp-config.d/nc-webui.cfg
etc/ncp-config.d/nc-zram.cfg
etc/ncp-config.d/NFS.cfg
etc/ncp-config.d/no-ip.cfg
etc/ncp-config.d/samba.cfg
etc/ncp-config.d/spDYN.cfg
etc/ncp-config.d/SSH.cfg
etc/ncp-config.d/UFW.cfg
etc/ncp-config.d/unattended-upgrades.cfg
etc/ncp-templates
etc/ncp-templates/apache2
etc/ncp-templates/apache2/http2.conf.sh
etc/ncp-templates/mysql
etc/ncp-templates/mysql/90-ncp.cnf.sh
etc/ncp-templates/mysql/91-ncp.cnf.sh
etc/ncp-templates/ncp-metrics.cfg.sh
etc/ncp-templates/nextcloud.conf.sh
etc/ncp-templates/php
etc/ncp-templates/php/90-ncp.ini.sh
etc/ncp-templates/php/opcache.ini.sh
etc/ncp-templates/php/pool.d.www.conf.sh
etc/ncp-templates/systemd
etc/ncp-templates/systemd/notify_push.service.sh
i18n/README-zh_CN.md
i18n/README-zh_TW.md
ncp-activation/CSS.css
ncp-activation/index.php
ncp-activation/JS.js
ncp-app/appinfo
ncp-app/appinfo/info.xml
ncp-app/appinfo/routes.php
ncp-app/COPYING
ncp-app/css
ncp-app/css/style.css
ncp-app/img
ncp-app/img/app.svg
ncp-app/js
ncp-app/js/script.js
ncp-app/lib
ncp-app/lib/Controller
ncp-app/lib/Controller/PageController.php
ncp-app/templates
ncp-app/templates/index.php
ncp-previewgenerator/ncp-previewgenerator-nc20
ncp-previewgenerator/ncp-previewgenerator-nc20/appinfo
ncp-previewgenerator/ncp-previewgenerator-nc20/appinfo/app.php
ncp-previewgenerator/ncp-previewgenerator-nc20/appinfo/info.xml
ncp-previewgenerator/ncp-previewgenerator-nc20/CHANGELOG.md
ncp-previewgenerator/ncp-previewgenerator-nc20/composer
ncp-previewgenerator/ncp-previewgenerator-nc20/composer/autoload.php
ncp-previewgenerator/ncp-previewgenerator-nc20/composer/composer
ncp-previewgenerator/ncp-previewgenerator-nc20/composer/composer/autoload_classmap.php
ncp-previewgenerator/ncp-previewgenerator-nc20/composer/composer/autoload_namespaces.php
ncp-previewgenerator/ncp-previewgenerator-nc20/composer/composer/autoload_psr4.php
ncp-previewgenerator/ncp-previewgenerator-nc20/composer/composer/autoload_real.php
ncp-previewgenerator/ncp-previewgenerator-nc20/composer/composer/autoload_static.php
ncp-previewgenerator/ncp-previewgenerator-nc20/composer/composer/ClassLoader.php
ncp-previewgenerator/ncp-previewgenerator-nc20/composer/composer/installed.json
ncp-previewgenerator/ncp-previewgenerator-nc20/composer/composer.json
ncp-previewgenerator/ncp-previewgenerator-nc20/composer/composer/LICENSE
ncp-previewgenerator/ncp-previewgenerator-nc20/lib
ncp-previewgenerator/ncp-previewgenerator-nc20/lib/AppInfo
ncp-previewgenerator/ncp-previewgenerator-nc20/lib/AppInfo/Application.php
ncp-previewgenerator/ncp-previewgenerator-nc20/lib/Command
ncp-previewgenerator/ncp-previewgenerator-nc20/lib/Command/DeleteOld.php
ncp-previewgenerator/ncp-previewgenerator-nc20/lib/Command/Generate.php
ncp-previewgenerator/ncp-previewgenerator-nc20/lib/Command/PreGenerate.php
ncp-previewgenerator/ncp-previewgenerator-nc20/lib/Command/TimestampFormatter.php
ncp-previewgenerator/ncp-previewgenerator-nc20/lib/Migration
ncp-previewgenerator/ncp-previewgenerator-nc20/lib/Migration/Version020000Date20180823071939.php
ncp-previewgenerator/ncp-previewgenerator-nc20/lib/Migration/Version020200Date20190608205303.php
ncp-previewgenerator/ncp-previewgenerator-nc20/lib/SizeHelper.php
ncp-previewgenerator/ncp-previewgenerator-nc20/lib/Watcher.php
ncp-previewgenerator/ncp-previewgenerator-nc20/LICENSE
ncp-previewgenerator/ncp-previewgenerator-nc20/Makefile
ncp-previewgenerator/ncp-previewgenerator-nc20/README.md
ncp-previewgenerator/ncp-previewgenerator-nc20/tests
ncp-previewgenerator/ncp-previewgenerator-nc20/tests/bootstrap.php
ncp-previewgenerator/ncp-previewgenerator-nc20/tests/phpunit.xml
ncp-previewgenerator/ncp-previewgenerator-nc20/tests/WatcherTest.php
ncp-previewgenerator/ncp-previewgenerator-nc21
ncp-previewgenerator/ncp-previewgenerator-nc21/appinfo
ncp-previewgenerator/ncp-previewgenerator-nc21/appinfo/info.xml
ncp-previewgenerator/ncp-previewgenerator-nc21/CHANGELOG.md
ncp-previewgenerator/ncp-previewgenerator-nc21/composer.json
ncp-previewgenerator/ncp-previewgenerator-nc21/krankerl.toml
ncp-previewgenerator/ncp-previewgenerator-nc21/lib
ncp-previewgenerator/ncp-previewgenerator-nc21/lib/AppInfo
ncp-previewgenerator/ncp-previewgenerator-nc21/lib/AppInfo/Application.php
ncp-previewgenerator/ncp-previewgenerator-nc21/lib/Command
ncp-previewgenerator/ncp-previewgenerator-nc21/lib/Command/DeleteOld.php
ncp-previewgenerator/ncp-previewgenerator-nc21/lib/Command/Generate.php
ncp-previewgenerator/ncp-previewgenerator-nc21/lib/Command/PreGenerate.php
ncp-previewgenerator/ncp-previewgenerator-nc21/lib/Command/TimestampFormatter.php
ncp-previewgenerator/ncp-previewgenerator-nc21/lib/Listeners
ncp-previewgenerator/ncp-previewgenerator-nc21/lib/Listeners/PostWriteListener.php
ncp-previewgenerator/ncp-previewgenerator-nc21/lib/Migration
ncp-previewgenerator/ncp-previewgenerator-nc21/lib/Migration/Version020000Date20180823071939.php
ncp-previewgenerator/ncp-previewgenerator-nc21/lib/Migration/Version020200Date20190608205303.php
ncp-previewgenerator/ncp-previewgenerator-nc21/lib/SizeHelper.php
ncp-previewgenerator/ncp-previewgenerator-nc21/LICENSE
ncp-previewgenerator/ncp-previewgenerator-nc21/README.md
ncp-previewgenerator/ncp-previewgenerator-nc21/tests
ncp-previewgenerator/ncp-previewgenerator-nc21/tests/bootstrap.php
ncp-previewgenerator/ncp-previewgenerator-nc21/tests/phpunit.xml
ncp-previewgenerator/ncp-previewgenerator-nc21/tests/WatcherTest.php
ncp-web/activate
ncp-web/activate/CSS.css
ncp-web/activate/index.php
ncp-web/activate/JS.js
ncp-web/backups.php
ncp-web/csrf.php
ncp-web/css
ncp-web/css/ncp.css
ncp-web/decrypt
ncp-web/decrypt/CSS.css
ncp-web/decrypt/index.php
ncp-web/decrypt/JS.js
ncp-web/download_logs.php
ncp-web/download.php
ncp-web/elements.php
ncp-web/img
ncp-web/img/background.png
ncp-web/img/clippy.svg
ncp-web/img/close.svg
ncp-web/img/dashboard.svg
ncp-web/img/defaults.svg
ncp-web/img/defaults-white.svg
ncp-web/img/delete.svg
ncp-web/img/download.svg
ncp-web/img/favicon.png
ncp-web/img/files.svg
ncp-web/img/green-circle.svg
ncp-web/img/info.svg
ncp-web/img/info-white.svg
ncp-web/img/loading-small.gif
ncp-web/img/logs.svg
ncp-web/img/menu.svg
ncp-web/img/nc-button.svg
ncp-web/img/ncp-logo.svg
ncp-web/img/poweroff.svg
ncp-web/img/reboot.svg
ncp-web/img/red-circle.svg
ncp-web/img/search.svg
ncp-web/img/settings-white.svg
ncp-web/img/toggle.svg
ncp-web/img/toggle-white.svg
ncp-web/img/view-close.svg
ncp-web/img/wizard.svg
ncp-web/index.php
ncp-web/js
ncp-web/js/minified.js
ncp-web/js/ncp.js
ncp-web/l10n
ncp-web/l10n/de.json
ncp-web/l10n/es.json
ncp-web/L10N.php
ncp-web/l10n/zh.json
ncp-web/langs.cfg
ncp-web/ncp-launcher.php
ncp-web/ncp-output.php
ncp-web/upload.php
ncp-web/wizard
ncp-web/wizard/bootstrap
ncp-web/wizard/bootstrap/css
ncp-web/wizard/bootstrap/css/bootstrap.css
ncp-web/wizard/bootstrap/css/bootstrap.css.map
ncp-web/wizard/bootstrap/css/bootstrap.min.css
ncp-web/wizard/bootstrap/css/bootstrap-theme.css
ncp-web/wizard/bootstrap/css/bootstrap-theme.css.map
ncp-web/wizard/bootstrap/css/bootstrap-theme.min.css
ncp-web/wizard/bootstrap/fonts
ncp-web/wizard/bootstrap/fonts/glyphicons-halflings-regular.eot
ncp-web/wizard/bootstrap/fonts/glyphicons-halflings-regular.svg
ncp-web/wizard/bootstrap/fonts/glyphicons-halflings-regular.ttf
ncp-web/wizard/bootstrap/fonts/glyphicons-halflings-regular.woff
ncp-web/wizard/bootstrap/img
ncp-web/wizard/bootstrap/img/glyphicons-halflings.png
ncp-web/wizard/bootstrap/img/glyphicons-halflings-white.png
ncp-web/wizard/bootstrap/js
ncp-web/wizard/bootstrap/js/bootstrap.js
ncp-web/wizard/bootstrap/js/bootstrap.min.js
ncp-web/wizard/bootstrap/js/npm.js
ncp-web/wizard/CSS
ncp-web/wizard/CSS/wizard.css
ncp-web/wizard/img
ncp-web/wizard/img/nc-logo.png
ncp-web/wizard/img/ncp-logo.svg
ncp-web/wizard/index.php
ncp-web/wizard/JS
ncp-web/wizard/JS/jquery.bootstrap.wizard.js
ncp-web/wizard/JS/jquery-latest.js
ncp-web/wizard/JS/wizard.js
tests/activation_tests.py
tests/libvirt_forwarding.sh
tests/lxd_forwarding.sh
tests/nextcloud_tests.py
tests/system_tests.py
updates/1.13.6.sh
updates/1.16.0.sh
updates/1.18.0.sh
updates/1.20.0.sh
updates/1.25.0.sh
updates/1.30.0.sh
updates/1.36.4.sh
updates/1.39.0.sh
updates/1.40.0.sh
updates/1.43.0.sh
updates/1.45.0.sh
updates/1.46.0.sh
updates/1.47.0.sh
updates/1.48.2.sh
updates/1.50.0.sh
updates/1.50.1.sh
```
</details>

Packages in Docker environment/build

<details><summary> Docker Packages</summary>

DOCKER PACKAGES||
:-:|:-:
`git`|`bash`
</details>

Extraction of the different environment variables, dependencies on/in other scripts & their dependencies in turn and which packages are required together with their location.

<details><summary>File & location</summary>

|File|Repository|Installed|Dependencies
:-:|:-:|:-:|:-:
`library.sh`|`/etc/library.sh`|`/usr/local/etc/library.sh`|`$ncc`,`$ARCH`,`$NCPCFG`,`$CFGDIR`,`$BINDIR`,`$NCDIR`
`ncc`|`/bin/ncc`|`/usr/local/bin/ncc`|`occ`,`$NCDIR`
`ncp.cfg`|`/etc/ncp.cfg`|`/usr/local/etc/ncp.cfg`|`-`
`occ`|`-`|`/var/www/nextcloud/`|`$NCDIR`
</details>

<details><summary>Environment variables</summary>

|ENVIRONMENT VARIABLE|VALUE|
-:|:-
`$ncc`|`/usr/local/bin/ncc`
`$CFGDIR`|`/usr/local/etc/ncp-config.d/`
`$BINDIR`|`/usr/local/bin/ncp/`
`$NCDIR`|`/var/www/nextcloud/`
`$NCPCFG`|`"${NCPCFG:-etc/ncp.cfg}"`
`$ARCH`|`"$(dpkg --print-architecture)"`
`$DESTDIR`|``
`$INCLUDEDATA`|``
`$COMPRESS`|``
  ncp-tools:
`$BACKUPLIMIT`|``
`$BACKUPDAYS`|``
`$NCLATESTVER`|`$(jq -r .nextcloud_version < "$NCPCFG")`
`$PHPVER`|`$(jq -r .php_version < "$NCPCFG")`
`$RELEASE`|`$(jq -r .release < "$NCPCFG")`
`$NEXTCLOUD_URL`|`https://localhost sudo -E -u www-data "/var/www/nextcloud/apps/notify_push/bin/${ARCH}/notify_push" --allow-self-signed /var/www/nextcloud/config/config.php &>/dev/null &`
</details>

<details><summary>Packages</summary>

||PACKAGES||
:-:|:-:|:-:
`dpkg`|`bash`|`jq`|
`apt`|`dialog`|`cat`|
`awk`|`mktemp`|`sudo`|
</details>

<details><summary>Users</summary>

USERS|
:-:
`www-data`|
</details>

<details><summary>Permissions</summary>

PERMISSIONS|
:-:
`sudo`|
</details>

<!-- 

#### [BACKUPS][dirBackups]
 
<details><summary>Status</summary>

+ [ ] Stopped
+ [ ] Not started
+ [X] Research
+ [ ] Testing
+ [X] Ongoing
+ [ ] Paused
+ [ ] Completed
</details>

<details><summary>Scripts</summary>

- [ ] 1. [nc-backup-auto.sh][nc-backup-auto.sh]
  <details><summary>Dependencies & Packages</summary>
    
    - library.sh
    - ncp-backup
    - metrics.sh
    </details>
- [ ] 2. [nc-backup.sh][nc-backup.sh]
  <details><summary>Dependencies & Packages</summary>
  - TODO
  </details>
- [ ] 3. [nc-export-ncp.sh][nc-export-ncp.sh]
- [ ] 4. [nc-import-ncp.sh][nc-import-ncp.sh]
- [ ] 5. [nc-restore-snapshot.sh][nc-restore-snapshot.sh]
- [ ] 6. [nc-restore.sh][nc-restore.sh]
- [ ] 7. [nc-rsync-auto.sh][nc-rsync-auto.sh]
- [ ] 8. [nc-rsync.sh][nc-rsync.sh]
- [ ] 9. [nc-snapshot-auto.sh][nc-snapshot-auto.sh]
- [ ] 10. [nc-snapshot-sync.sh][nc-snapshot-sync.sh]
- [ ] 11. [nc-snapshot.sh][nc-snapshot.sh]

[nc-backup-auto.sh]: https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/BACKUPS/nc-backup-auto.sh
[nc-backup.sh]: https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/BACKUPS/nc-backup.sh
[nc-export-ncp.sh]: https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/BACKUPS/nc-export-ncp.sh
[nc-import-ncp.sh]: https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/BACKUPS/nc-import-ncp.sh
[nc-restore-snapshot.sh]: https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/BACKUPS/nc-restore-snapshot.sh
[nc-restore.sh]: https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/BACKUPS/nc-restore.sh
[nc-rsync-auto.sh]: https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/BACKUPS/nc-rsync-auto.sh
[nc-rsync.sh]: https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/BACKUPS/nc-rsync.sh
[nc-snapshot-auto.sh]: https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/BACKUPS/nc-snapshot-auto.sh
[nc-snapshot-sync.sh]: https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/BACKUPS/nc-snapshot-sync.sh
[nc-snapshot.sh]: https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/BACKUPS/nc-snapshot.sh
</details>

#### [CONFIG][dirConfig]

<details><summary>Scripts</summary>

- [ ] 1. [nc-admin.sh][nc-admin]
- [ ] 2. [nc-database.sh][nc-database]
- [ ] 3. [nc-datadir.sh][nc-datadir]
- [ ] 4. [nc-httpsonly.sh][nc-httpsonly]
- [ ] 5. [nc-init.sh][nc-init]
- [ ] 6. [nc-limits.sh][nc-limits]
- [ ] 7. [nc-nextcloud.sh][nc-nextcloud]
- [ ] 8. [nc-passwd.sh][nc-passwd]
- [ ] 9. [nc-prettyURL.sh][nc-prettyURL]
- [ ] 10. [nc-previews-auto.sh][nc-previews-auto]
- [ ] 11. [nc-scan-auto.sh][nc-scan-auto]
- [ ] 12. [nc-trusted-domains.sh][nc-trusted-domains]
- [ ] 13. [nc-webui.sh][nc-webui]

[nc-admin]: https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/CONFIG/nc-admin.sh
[nc-database]: https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/CONFIG/nc-database.sh
[nc-datadir]: https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/CONFIG/nc-datadir.sh
[nc-httpsonly]: https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/CONFIG/nc-httpsonly.sh
[nc-init]: https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/CONFIG/nc-init.sh
[nc-limits]: https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/CONFIG/nc-limits.sh
[nc-nextcloud]: https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/CONFIG/nc-nextcloud.sh
[nc-passwd]: https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/CONFIG/nc-passwd.sh
[nc-prettyURL]: https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/CONFIG/nc-prettyURL.sh
[nc-previews-auto]: https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/CONFIG/nc-previews-auto.sh
[nc-scan-auto]: https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/CONFIG/nc-scan-auto.sh
[nc-trusted-domains]: https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/CONFIG/nc-trusted-domains.sh
[nc-webui]: https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/CONFIG/nc-webui.sh
</details>

#### [NETWORKING][dirNetworking]

<details><summary>Scripts</summary>

- [ ] 1. [NFS.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/NETWORKING/NFS.sh)
- [ ] 2. [SSH.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/NETWORKING/SSH.sh)
- [ ] 3. [dnsmasq.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/NETWORKING/dnsmasq.sh)
- [ ] 4. [duckDNS.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/NETWORKING/duckDNS.sh)
- [ ] 5. [freeDNS.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/NETWORKING/freeDNS.sh)
- [ ] 6. [letsencrypt.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/NETWORKING/letsencrypt.sh)
- [ ] 7. [namecheapDNS.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/NETWORKING/namecheapDNS.sh)
- [ ] 8. [nc-forward-ports.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/NETWORKING/nc-forward-ports.sh)
- [ ] 9. [nc-static-IP.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/NETWORKING/nc-static-IP.sh)
- [ ] 10. [nc-trusted-proxies.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/NETWORKING/nc-trusted-proxies.sh)
- [ ] 11. [no-ip.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/NETWORKING/no-ip.sh)
- [ ] 12. [samba.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/NETWORKING/samba.sh)
- [ ] 13. [spDYN.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/NETWORKING/spDYN.sh)
</details>

#### [SECURITY][dirSecurity]

<details><summary>Scripts</summary>

- [ ] 1. [UFW.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/SECURITY/UFW.sh)
- [ ] 2. [fail2ban.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/SECURITY/fail2ban.sh)
- [ ] 3. [modsecurity.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/SECURITY/modsecurity.sh)
- [ ] 4. [nc-audit.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/SECURITY/nc-audit.sh)
- [ ] 5. [nc-encrypt.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/SECURITY/nc-encrypt.sh)
</details>

#### [SYSTEM][dirSystem]

<details><summary>Scripts</summary>

- [ ] 1. [metrics.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/SYSTEM/metrics.sh)
- [ ] 2. [nc-automount.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/SYSTEM/nc-automount.sh)
- [ ] 3. [nc-hdd-monitor.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/SYSTEM/nc-hdd-monitor.sh)
- [ ] 4. [nc-hdd-test.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/SYSTEM/nc-hdd-test.sh)
- [ ] 5. [nc-info.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/SYSTEM/nc-info.sh)
- [ ] 6. [nc-ramlogs.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/SYSTEM/nc-ramlogs.sh)
- [ ] 7. [nc-swapfile.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/SYSTEM/nc-swapfile.sh)
- [ ] 8. [nc-zram.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/SYSTEM/nc-zram.sh)
</details>

#### [TOOLS][dirTools]

<details><summary>Scripts</summary>

- [ ] 1. [nc-fix-permissions.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/TOOLS/nc-fix-permissions.sh)
- [ ] 2. [nc-format-USB.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/TOOLS/nc-format-USB.sh)
- [ ] 3. [nc-maintenance.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/TOOLS/nc-maintenance.sh)
- [ ] 4. [nc-previews.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/TOOLS/nc-previews.sh)
- [ ] 5. [nc-scan.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/TOOLS/nc-scan.sh)
</details>

#### [UPDATES][dirUpdates]

<details><summary>Scripts</summary>

- [ ] 1. [nc-autoupdate-nc.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/UPDATES/nc-autoupdate-nc.sh)
- [ ] 2. [nc-autoupdate-ncp.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/UPDATES/nc-autoupdate-ncp.sh)
- [ ] 3. [nc-notify-updates.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/UPDATES/nc-notify-updates.sh)
- [ ] 4. [nc-update-nc-apps-auto.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/UPDATES/nc-update-nc-apps-auto.sh)
- [ ] 5. [nc-update-nc-apps.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/UPDATES/nc-update-nc-apps.sh)
- [ ] 6. [nc-update-nextcloud.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/UPDATES/nc-update-nextcloud.sh)
- [ ] 7. [nc-update.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/UPDATES/nc-update.sh)
- [ ] 8. [unattended-upgrades.sh](https://github.com/nextcloud/nextcloudpi/blob/containerize/bin/ncp/UPDATES/unattended-upgrades.sh)
</details>

-->

---
