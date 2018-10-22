# -*- mode: ruby -*-
# vi: set ft=ruby :

#
# Vagrantfile test the NCP curl installer
#
# Instructions: vagrant up; vagrant ssh
#
# Notes: User/Pass is ubnt/ubnt.
# $HOME is accessible as /external. CWD is accessible as /cwd
#

Vagrant.configure("2") do |config|

  vmname = "NCP Debian VM"
  config.vm.box = "debian/stretch64"
  config.vm.box_check_update = false
  config.vm.hostname = "ncp-vm"

  $script = <<-SHELL
    sudo su
    BRANCH=master
    #BRANCH=devel  # uncomment to install devel
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends git

    # indicate that this will be an image build
    touch /.ncp-image

    # install
    git clone -b "$BRANCH" https://github.com/nextcloud/nextcloudpi.git /tmp/nextcloudpi
    cd /tmp/nextcloudpi

    # uncomment to install devel
    #sed -i 's|^BRANCH=master|BRANCH=devel|' install.sh ncp.sh

    bash install.sh

    # cleanup
    source etc/library.sh
    install_script post-inst.sh
    cd -
    rm -r /tmp/nextcloudpi
    poweroff
  SHELL

  # Provision the VM
  config.vm.provision "shell", inline: $script

end
