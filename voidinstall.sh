#!/bin/bash

# # before running the script
# # set keyboard layout to uk
# loadkey uk

# # connect to wifi
# wpa_cli i- wlp5s0
# scan
# scan_results
# add_network 0 # 0 is the index of the network in the network list
# set_network 0 ssid "NoWifiHereKeepLooking"
# set_network 0 psk "password"
# enable_network 0
# save_config
# quit

# dhcpcd wlp5s0
# ping -c 3 voidlinux.org

# # laptop partitions
# mkfs.ext4 /dev/nvme1n1p6
# mkfs.ext4 /dev/nvme1n1p7

mount /dev/nvme1n1p6 /mnt/
mkdir -p /mnt/boot/efi/
mount /dev/nvme1n1p3 /mnt/boot/efi/

mkdir -p /mnt/var/db/cbps/keys
cp /var/db/xbps/keys/* /mnt/var/db/xbps/keys/

XBPS_ARCH=x86_64 xbps-install -S -r /mnt/ -R https://repo-fi.voidlinux.org/current base-system
# XBPS_ARCH=x86_64 xbps-install -S -r /mnt/ -R https://repo-de.voidlinux.org/current base-system

# # mount home partition
mount /dev/nvme1n1p7 /mnt/home/

xgenfstab -U /mnt > /mnt/etc/fstab
xchroot /mnt /bin/bash

