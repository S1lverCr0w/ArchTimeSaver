#!/bin/bash

#Start script
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
sed -i "s/^#Color = 5$/Color/" /etc/pacman.conf

loadkeys us #or uk etc
timedatectl set-ntp true

#Filesystem formatting
rootpart="/dev/nvme0n1p4"
homepart="/dev/nvme0n1p2"
mkfs.fat -F 32 /dev/nvme0n1p1
mkfs.ext4 $rootpart
#home partition below if needed
# mkfs.ext4 /dev/nvme0n1p3 # usually I just reuse my existing partition

#Mount root and home partition --Important--
mount $rootpart /mnt
mkdir /mnt/home
mount $homepart /mnt/home

#Mount extra partitions WIP/Tetsing
#mkdir /mnt/mnt/Main
#mount /dev/nvme0n1p4 /mnt/mnt/Main
#mkdir /mnt/mnt/Win
#mount /dev/nvme0n1p2 /mnt/mnt/Win
#mkdir /mnt/mnt/Work
#mount /dev/nvme1n1p2/ /mnt/mnt/Work

#installing system
pacstrap -K /mnt base linux linux-firmware
genfstab -U /mnt >>/mnt/etc/fstab

scriptname="archInstall_P2"
sed '1,/^#script2$/d' $(basename $0) >/mnt/$scriptname.sh
chmod +x /mnt/$scriptname.sh
arch-chroot /mnt ./$scriptname.sh
exit

#script2
pacman -S --noconfirm sed linux-lts
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
sed -i "s/^#Color$/Color/" /etc/pacman.conf
sed -i 's/^#MAKEFLAGS="-j2"$/MAKEFLAGS="-j$(nproc)"/' /etc/makepkg.conf
sed -i 's/^#VerbosePkgLists$/VerbosePkgLists/' /etc/pacman.conf


# Set according to your region
ln -sf /usr/share/zoneinfo/Europe/Dublin /etc/localtime
hwclock --sytohc
echo "en_GB.UTF-8 UTF-8" >>/etc/locale.gen
locale-gen

echo "insert hostname / pc name, can also use capitals"
read hostname
echo $hostname >/etc/hostname
echo "127.0.0.1		localhost" >>/etc/hosts
echo "::1		        localhost" >>/etc/hosts
echo "127.0.1.1		$hostname.localdomain $hostname" >>/etc/hosts
mkinitcpio -P

#adding user
echo "set root password and make sure numlock is enabled"
passwd
echo "set login username. no capitals allowed"
read username
useradd -m $username
echo "set password for $username"
passwd $username
usermod -aG wheel,audio,video,storage $username

#install following packages
pacman -S --noconfirm doas grub efibootmgr os-prober dosfstools mtools
echo "permit $username as root" >/etc/doas.conf
mkdir /boot/EFI
mount /dev/nvme0n1p1 /boot/EFI

#for windows dualboot only
mkdir /boot/WINDOWS
mount /dev/nvme2n1p5 /boot/WINDOWS

grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
sed -i "s/^GRUB_GFXMODE=auto$/GRUB_GFXMODE=1920x1080/" /etc/default/grub
sed -i "s/^#GRUB_DISABLE_OS_PROBER=false$/GRUB_DISABLE_OS_PROBER=false/" /etc/default/grub
sed -i 's/^GRUB_DEFAULT=0$/GRUB_DEFAULT="1>2"/' /etc/default/grub
sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"$/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet apparmor=1 lsm=landlock,lockdown,yama,integrity,apparmor,bpf"/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

#install nvim and clipboard manager to make copy/paste from/to sys clipboard
pacman -S --noconfirm nvim xclip
#last install of needed tools
pacman -S --noconfirm --needed networkmanager nano git git-lfs rustup alacritty firefox gnome ufw firejail
# Basedevel  excluding Sudo
pacman -S --noconfirm --needed archlinux-keyring autoconf automake bison debugedit flex gc gcc groff guile libisl m4 make patch pkgconf texinfo which
#pacman -S --noconfirm --needed archlinux-keyring autoconf automake binutils bison debugedit fakeroot file findutils flex gawk gcc gettext grep groff gzip libtool m4 make pacman patch pkgconf sed texinfo which
#add japanese chinese font support 
pacman -S --noconfirm wqy-zenhei ibus-libpinyin
# Rustup init (not sure but it was needed)
rustup default stable
pacman -S --noconfirm --needed btop
firecfg

#install paru
sed -i "s/^COMPRESSZST=(zstd -c -T0 --ultra -20 -)/COMPRESSZST=(zstd -c -T0 --fast -)/" /etc/makepkg.conf
git clone https://aur.archlinux.org/paru.git
cd paru
runuser -unobody makepkg -si
cd ..
rm -rf paru
sed -i "s/^#[bin]/[bin]/" /etc/paru.conf
sed -i "s/^#Sudo/Sudo/" /etc/paru.conf

systemctl enable NetworkManager
systemctl enable gdm
systemctl enable ufw
ufw enable
systemctl enable fstrim.timer

: '

scriptname3="Arch_InstallPart3" # WIP
sed '1,/^#script2$/d' `basename $0` > /mnt/$scriptname3.sh
chmod +x /mnt/$scriptname3.sh

#part3
#post install / reboot
grub-mkconfig -o /boot/grub/grub.cfg
#mount /dev/nvme1n1p4 /mnt/home
#download dotfiles wip


paru apparmor.d-git

'
