#!/bin/bash

hostname="EnryuL"

: '
#Start script
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf

loadkeys us #or uk etc.
timedatectl set-ntp true
#sleep 5

mkfs.fat -F 32 /dev/nvme0n1p1
mkfs.ext4 /dev/nvme0n1p2
#home partition below
# mkfs.ext4 /dev/nvme0n1p3 
echo "partitions written"
sleep 1
mount /dev/nvme0n1p2 /mnt

#installing system
pacstrap -K /mnt base linux linux-firmware

genfstab -U /mnt >> /mnt/etc/fstab

'

sed '1,/^#script2$/d' `basename $0` > /mnt/enryu_script2.sh
chmod +x /mnt/enryu_script2.sh
arch-chroot /mnt ./enryu_script2.sh
exit

#script2
pacman -S --noconfirm sed
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
ln -sf /usr/share/zoneinfo/Europe/Dublin /etc/localtime
hwclock --sytohc
echo "en_GB.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

echo $hostname > /etc/hostname
echo "127.0.0.1		localhost" >> /etc/hosts
echo "::1		localhost" >> /etc/hosts
echo "127.0.1.1		$hostname.localdomain $hostname" >> /etc/hosts
mkinitcpio -P

#adding user
echo "set root password"
passwd
echo "set login username"
read username
useradd -m $username
echo "set password for $username"
passwd $username
usermod -aG wheel,audio,video,storage $username

#install following packages
pacman -S --noconfirm doas grub efibootmgr os-prober dosfstools mtools
echo "permit $username as root" > /etc/doas.conf
mkdir /boot/EFI
mount /dev/nvme0n1p1 /boot/EFI

#for windows dualboot only
mkdir /boot/WINDOWS
mount /dev/nvme1n1p3 /boot/WINDOWS

grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
grub-mkconfig -o /boot/grub/grub.cfg

#last install of needed tools
pacman -S --noconfirm --needed networkmanager nano git alacritty firefox gnome xorg

systemctl enable NetworkManager
systemctl enable gdm

exit
