#!/bin/bash

# Library to install software on Raspbian ARM through QEMU
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at ownyourbits.com
#

DBG=x

# $IMG    is the source image
# $IP     is the IP of the QEMU images
# $IMGOUT will contain the name of the generated image
function launch_install_qemu()
{
  local IMG=$1
  local IP=$2
  [[ "$IP"      == ""  ]] && { echo "usage: launch_install_qemu <img> <IP>"; return 1; }
  test -f "$IMG"          || { echo "input file $IMG not found";             return 1; }

  IMGOUT="$IMG-$( date +%s )"
  cp --reflink=auto -v "$IMG" "$IMGOUT" || return 1

  pgrep qemu-system-arm &>/dev/null && { echo -e "QEMU instance already running. Abort..."; return 1; }
  launch_qemu "$IMGOUT" &
  sleep 10
  wait_SSH "$IP"
  launch_installation_qemu "$IP" || return 1 # uses $INSTALLATION_CODE
  wait 
  echo "$IMGOUT generated successfully"
}

function launch_qemu()
{
  local IMG=$1
  test -f "$1" || { echo "Image $IMG not found"; return 1; }
  test -d qemu-raspbian-network || git clone https://github.com/nachoparker/qemu-raspbian-network.git
  sed -i '30s/NO_NETWORK=1/NO_NETWORK=0/' qemu-raspbian-network/qemu-pi.sh
  sed -i '35s/NO_GRAPHIC=0/NO_GRAPHIC=1/' qemu-raspbian-network/qemu-pi.sh
  echo "Starting QEMU image $IMG"
  ( cd qemu-raspbian-network && sudo ./qemu-pi.sh ../"$IMG" 2>/dev/null )
}

function ssh_pi()
{
  local IP=$1
  local ARGS=${@:2}
  local PIUSER=${PIUSER:-pi}
  local PIPASS=${PIPASS:-raspberry}
  local SSH=( ssh -q  -o UserKnownHostsFile=/dev/null\
                      -o StrictHostKeyChecking=no\
                      -o ServerAliveInterval=20\
                      -o ConnectTimeout=20\
                      -o LogLevel=quiet                  )
  type sshpass &>/dev/null && local SSHPASS=( sshpass -p$PIPASS )
  if [[ "${SSHPASS[@]}" == "" ]]; then
    ${SSH[@]} ${PIUSER}@$IP $ARGS; 
  else
    ${SSHPASS[@]} ${SSH[@]} ${PIUSER}@$IP $ARGS 
    local RET=$?
    [[ $RET -eq 5 ]] && { ${SSH[@]} ${PIUSER}@$IP $ARGS; return $?; }
    return $RET
  fi
}

function wait_SSH()
{
  local IP=$1
  echo "Waiting for SSH to be up on $IP..."
  while true; do
    ssh_pi "$IP" : && break
    sleep 1
  done
  echo "SSH is up"
}

function launch_installation()
{
  local IP=$1
  [[ "$INSTALLATION_CODE"  == "" ]] && { echo "Need to run config first"    ; return 1; }
  [[ "$INSTALLATION_STEPS" == "" ]] && { echo "No installation instructions"; return 1; }
  local PREINST_CODE="
set -e$DBG
sudo su
set -e$DBG
"
  echo "Launching installation"
  echo -e "$PREINST_CODE\n$INSTALLATION_CODE\n$INSTALLATION_STEPS" | ssh_pi "$IP" || { echo "Installation to $IP failed" && return 1; }
}

function launch_installation_qemu()
{
  local IP=$1
  [[ "$NO_CFG_STEP"  != "1" ]] && local CFG_STEP=configure
  [[ "$NO_CLEANUP"   != "1" ]] && local CLEANUP_STEP="if [[ \$( type -t cleanup ) == function ]];then cleanup; fi"
  [[ "$NO_HALT_STEP" != "1" ]] && local HALT_STEP="nohup halt &>/dev/null &"
  local INSTALLATION_STEPS="
install
$CFG_STEP
$CLEANUP_STEP
$HALT_STEP
"
  launch_installation "$IP" # uses $INSTALLATION_CODE
}

function launch_installation_online()
{
  local IP=$1
  [[ "$NO_CFG_STEP" != "1" ]]  && local CFG_STEP=configure
  local INSTALLATION_STEPS="
install
$CFG_STEP
"
  launch_installation "$IP" # uses $INSTALLATION_CODE
}

function prepare_dirs()
{
  [[ "$CLEAN" == "0" ]] || rm -rf cache
  rm -rf tmp
  mkdir -p tmp output cache
}

function mount_raspbian()
{
  local IMG="$1"
  local MP=raspbian_root

  [[ -f "$IMG"        ]] || { echo "no image";  return 1; }
  [[ -e "$MP" ]] && { echo "$MP already exists"; return 1; }

  local SECTOR=$( fdisk -l "$IMG" | grep Linux | awk '{ print $2 }' )
  local OFFSET=$(( SECTOR * 512 ))
  mkdir -p "$MP"
  sudo mount $IMG -o offset=$OFFSET "$MP" || return 1
  echo "Raspbian image mounted"
}

function mount_raspbian_boot()
{
  local IMG="$1"
  local MP=raspbian_boot

  [[ -f "$IMG" ]] || { echo "no image";           return 1; }
  [[ -e "$MP"  ]] && { echo "$MP already exists"; return 1; }

  local SECTOR=$( fdisk -l "$IMG" | grep FAT32 | awk '{ print $2 }' )
  local OFFSET=$(( SECTOR * 512 ))
  mkdir -p "$MP"
  sudo mount $IMG -o offset=$OFFSET "$MP" || return 1
  echo "Raspbian image mounted"
}

function umount_raspbian()
{
  [[ -d raspbian_root ]] || [[ -d raspbian_boot ]] || { echo "Nothing to umount"; return 0; }
  [[ -d raspbian_root ]] && { sudo umount -l raspbian_root; rmdir raspbian_root || return 1; }
  [[ -d raspbian_boot ]] && { sudo umount -l raspbian_boot; rmdir raspbian_boot || return 1; }
  echo "Raspbian image umounted"
}

function prepare_chroot_raspbian()
{
  local IMG="$1"
  mount_raspbian "$IMG" || return 1
  sudo mount -t proc proc     raspbian_root/proc/
  sudo mount -t sysfs sys     raspbian_root/sys/
  sudo mount -o bind /dev     raspbian_root/dev/
  sudo mount -o bind /dev/pts raspbian_root/dev/pts

  sudo cp /usr/bin/qemu-arm-static raspbian_root/usr/bin

  # Prevent services from auto-starting
  sudo bash -c "echo -e '#!/bin/sh\nexit 101' > raspbian_root/usr/sbin/policy-rc.d"
  sudo chmod +x raspbian_root/usr/sbin/policy-rc.d
}

function clean_chroot_raspbian()
{
  sudo rm -f raspbian_root/usr/bin/qemu-arm-static
  sudo rm -f raspbian_root/usr/sbin/policy-rc.d
  sudo umount -l raspbian_root/{proc,sys,dev/pts,dev}
  umount_raspbian
}

# sets DEV
function resize_image()
{
  local IMG="$1"
  local SIZE="$2"
  local DEV
  echo -e "\n\e[1m[ Resize Image ]\e[0m"
  fallocate -l$SIZE "$IMG"
  parted "$IMG" -- resizepart 2 -1s
  DEV="$( sudo losetup -f )"
  mount_raspbian "$IMG"
  sudo resize2fs -f "$DEV"
  echo "Image resized"
  umount_raspbian
}

function update_boot_uuid()
{
  local IMG="$1"
  local PTUUID="$( sudo blkid -o export "$IMG" | grep PTUUID | sed 's|.*=||' )"

  echo -e "\n\e[1m[ Update Raspbian Boot UUIDS ]\e[0m"
  mount_raspbian "$IMG" || return 1
  sudo bash -c "cat > raspbian_root/etc/fstab" <<EOF
PARTUUID=${PTUUID}-01  /boot           vfat    defaults          0       2
PARTUUID=${PTUUID}-02  /               ext4    defaults,noatime  0       1
EOF
  umount_raspbian

  mount_raspbian_boot "$IMG"
  sudo bash -c "sed -i 's|root=[^[:space:]]*|root=PARTUUID=${PTUUID}-02 |' raspbian_boot/cmdline.txt"
  umount_raspbian
}

function prepare_sshd()
{
  local IMG="$1"
  mount_raspbian_boot "$IMG" || return 1
  sudo touch raspbian_boot/ssh   # this enables ssh
  umount_raspbian
}

function set_static_IP()
{
  local IMG="$1"
  local IP="$2"
  mount_raspbian "$IMG" || return 1
  sudo bash -c "cat > raspbian_root/etc/dhcpcd.conf" <<EOF
interface eth0
static ip_address=$IP/24
static routers=192.168.0.1
static domain_name_servers=8.8.8.8

# Local loopback
auto lo
iface lo inet loopback
EOF
  umount_raspbian
}

function copy_to_image()
{
  local IMG=$1
  local DST=$2
  local SRC=${@: 3 }

  mount_raspbian "$IMG" || return 1
  sudo cp --reflink=auto -v "$SRC" raspbian_root/"$DST" || return 1
  sync
  umount_raspbian
}

function deactivate_unattended_upgrades()
{
  local IMG=$1

  mount_raspbian "$IMG" || return 1
  sudo rm -f raspbian_root/etc/apt/apt.conf.d/20ncp-upgrades
  umount_raspbian
}

function download_raspbian()
{
  local IMGFILE=$1
  local IMG_CACHE=cache/raspbian_lite.img
  local ZIP_CACHE=cache/raspbian_lite.zip

  echo -e "\n\e[1m[ Download Raspbian ]\e[0m"
  mkdir -p cache
  test -f $IMG_CACHE && \
    echo -e "INFO: $IMG_CACHE already exists. Skipping download ..." && \
    cp -v --reflink=auto $IMG_CACHE "$IMGFILE" && \
    return 0

  test -f "$ZIP_CACHE" && {
    echo -e "INFO: $ZIP_CACHE already exists. Skipping download ..."
  } || {
    wget https://downloads.raspberrypi.org/raspbian_lite_latest -O "$ZIP_CACHE" || return 1
  }

  unzip -o "$ZIP_CACHE" && \
    mv *-raspbian-*.img $IMG_CACHE && \
    cp -v --reflink=auto $IMG_CACHE "$IMGFILE" 
}

function pack_image()
{
  local IMG="$1"
  local TAR="$2"
  local DIR="$( dirname  "$IMG" )"
  local IMGNAME="$( basename "$IMG" )"
  echo -e "\n\e[1m[ Pack Image ]\e[0m"
  echo "packing $IMG → $TAR"
  tar -I pbzip2 -C "$DIR" -cvf "$TAR" "$IMGNAME" && \
    echo -e "$TAR packed successfully"
}

function create_torrent()
{
  local TAR="$1"
  echo -e "\n\e[1m[ Create Torrent ]\e[0m"
  [[ -f "$TAR" ]] || { echo "image $TAR not found"; return 1; }
  local IMGNAME="$( basename "$TAR" .tar.bz2 )"
  local DIR="torrent/$IMGNAME"
  [[ -d "$DIR" ]] && { echo "dir $DIR already exists"; return 1; }
  mkdir -p torrent/"$IMGNAME" && cp -v --reflink=auto "$TAR" torrent/"$IMGNAME"
  md5sum "$DIR"/*.bz2 > "$DIR"/md5sum
  createtorrent -a udp://tracker.opentrackr.org -p 1337 -c "NextCloudPi. Nextcloud ready to use image" "$DIR" "$DIR".torrent
  transmission-remote -w $(pwd)/torrent -a "$DIR".torrent
}

function generate_changelog()
{
  git log --graph --oneline --decorate \
    --pretty=format:"[%<(13)%D](https://github.com/nextcloud/nextcloudpi/commit/%h) (%ad) %s" --date=short | \
    grep 'tag: v' | \
    sed '/HEAD ->\|origin/s|\[.*\(tag: v[0-9]\+\.[0-9]\+\.[0-9]\+\).*\]|[\1]|' | \
    sed 's|* \[tag: |\n[|' > changelog.md
}

function upload_ftp()
{
  local IMGNAME="$1"
  echo -e "\n\e[1m[ Upload FTP ]\e[0m"
  [[ -f torrent/"$IMGNAME"/"$IMGNAME".tar.bz2 ]] || { echo "No image file found, abort"; return 1; }
  [[ "$FTPPASS" == "" ]] && { echo "No FTPPASS variable found, abort"; return 1; }

  cd torrent

  ftp -np ftp.ownyourbits.com <<EOF
user root@ownyourbits.com $FTPPASS
mkdir testing
mkdir testing/$IMGNAME
cd testing/$IMGNAME
binary
rm  $IMGNAME.torrent
put $IMGNAME.torrent
bye
EOF
  cd - 
  cd torrent/$IMGNAME

  ftp -np ftp.ownyourbits.com <<EOF
user root@ownyourbits.com $FTPPASS
cd testing/$IMGNAME
binary
rm  $IMGNAME.tar.bz2
put $IMGNAME.tar.bz2
rm  md5sum
put md5sum
bye
EOF
  cd -
}

function test_image()
{
  local IMG="$1"
  local IP="$2"
  echo -e "\e[1m\n[ QEMU Test ]\e[0m"
  [[ -f "$IMG" ]] || { echo "No image file found, abort"; return 1; }
  launch_qemu "$IMG" &
  sleep 10
  wait_SSH "$IP"
  sleep 180            # Wait for the services to start. Improve this ( wait HTTP && trusted domains )
  tests/tests.py "$IP"
  ssh_pi "$IP" sudo halt
  wait
}

# License
#
# This script is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This script is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this script; if not, write to the
# Free Software Foundation, Inc., 59 Temple Place, Suite 330,
# Boston, MA  02111-1307  USA
