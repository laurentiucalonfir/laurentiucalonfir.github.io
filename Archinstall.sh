

#!/bin/bash

This script will install Arch Linux with Linux LTS, user account, systemd bootloader, NetworkManager, and swap partition.
Define the root and home partitions
root_partition=sda1
home_partition=sda2

Format the partitions
mkfs.ext4 /dev/$root_partition
mkfs.ext4 /dev/$home_partition

Mount the root and home partitions
mount /dev/$root_partition /mnt
mkdir /mnt/home
mount /dev/$home_partition /mnt/home

Create a swap partition
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

Install base packages and Linux LTS kernel
pacstrap /mnt base base-devel linux-lts

Generate fstab file
genfstab -U /mnt >> /mnt/etc/fstab

Configure the system
arch-chroot /mnt /bin/bash << EOF

Set the time zone
ln -sf /usr/share/zoneinfo/Europe/Bucharest etc/localtime
hwclock --systohc

Localization
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

Hostname
echo "archlinux" >> /etc/hostname

Networking
systemctl enable NetworkManager

Add a user account
useradd -m -g users -G wheel -s /bin/bash user
echo "user:password" | chpasswd
echo "user ALL=(ALL) ALL" >> /etc/sudoers

Bootloader
bootctl install
echo "default arch" >> /boot/loader/loader.conf
echo "timeout 3" >> /boot/loader/loader.conf
echo "editor 0" >> /boot/loader/loader.conf
echo "title Arch Linux" >> /boot/loader/entries/arch.conf
echo "linux /vmlinuz-linux-lts" >> /boot/loader/entries/arch.conf
echo "initrd /initramfs-linux-lts.img" >> /boot/loader/entries/arch.conf
echo "options root=PARTUUID=$(blkid -s PARTUUID -o value /dev/$root_partition) rw" >> /boot/loader/entries/arch.conf

Exit chroot and reboot
exit
reboot
