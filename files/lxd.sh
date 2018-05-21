#!/bin/bash
set -x

sudo apt-get update -qq
sudo apt-get install -y snapd
sudo apt-get install -y build-essential
sudo snap install lxd

_lxc="/snap/bin/lxc"
_lxd="/snap/bin/lxd"
sudo $_lxd waitready --timeout 60
sudo /snap/bin/lxd.migrate -yes
sudo ln -s /snap/bin/lxc /usr/bin/
sudo $_lxc config set core.https_address [::]
#sudo $_lxc config set core.trust_password password
#sudo $_lxc storage create default dir source=/mnt
sudo $_lxc storage create default btrfs source=/dev/sdb
sudo $_lxc profile device add default root disk path=/ pool=default
sudo $_lxc network create lxdbr1 ipv6.address=none ipv4.address=192.168.244.1/24 ipv4.nat=true
sudo $_lxc network attach-profile lxdbr1 default eth0
sudo $_lxc image copy images:ubuntu/xenial/amd64 local: --alias ubuntu
sudo usermod -a -G lxd ubuntu

sudo modprobe br_netfilter
echo br_netfilter | sudo tee -a /etc/modules

sudo swapon /dev/sdc
sudo sed -i -e 's/sdb/sdc/' /etc/fstab
