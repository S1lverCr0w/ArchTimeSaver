#!/bin/bash

#Start script
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
sed -i "s/^#Color = 5$/Color/" /etc/pacman.conf

loadkeys us #or uk etc.
timedatectl set-ntp true

#Filesystem formatting.
mkfs.fat -F 32 /dev/nvme0n1p1
mkfs.ext4 /dev/nvme0n1p2
#home partition below if needed
# mkfs.ext4 /dev/nvme0n1p3 

#Mount home partition Important
mount /dev/nvme0n1p2 /mnt

#installing system
pacstrap -K /mnt base linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab

scriptname = "Arch_InstallPart2"
sed '1,/^#script2$/d' `basename $0` > /mnt/$scriptname.sh
chmod +x /mnt/$scriptname.sh
arch-chroot /mnt ./$scriptname.sh
exit

#script2
pacman -S --noconfirm sed
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
sed -i "s/^#Color = 5$/Color/" /etc/pacman.conf
sed -i 's/^#MAKEFLAGS="-j2"$/MAKEFLAGS="-j$(nproc)"/' /etc/makepkg.conf
sed -i 's/^#VerbosePkgLists$/VerbosePkgLists/' /etc/pacman.conf
ln -sf /usr/share/zoneinfo/Europe/Dublin /etc/localtime
hwclock --sytohc
echo "en_GB.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

echo "insert hostname / pc name"
read hostname
echo $hostname > /etc/hostname
echo "127.0.0.1		localhost" >> /etc/hosts
echo "::1		        localhost" >> /etc/hosts
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
sed -i "s/^GRUB_GFXMODE=auto$/GRUB_GFXMODE=1920x1080/" /etc/default/grub
sed -i "s/^#GRUB_DISABLE_OS_PROBER=false$/GRUB_DISABLE_OS_PROBER=false/" /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

#last install of needed tools
pacman -S --noconfirm --needed networkmanager nano git alacritty firefox gnome ufw

systemctl enable NetworkManager
systemctl enable gdm
systemctl enable ufw
systemctl enable fstrim.timer
scriptname3="Arch_InstallPart3"
sed '1,/^#script2$/d' `basename $0` > /mnt/$scriptname3.sh
chmod +x /mnt/$scriptname3.sh

#part3
#post install / reboot
grub-mkconfig -o /boot/grub/grub.cfg
#mount /dev/nvme1n1p4 /home


#download dotfiles wip

