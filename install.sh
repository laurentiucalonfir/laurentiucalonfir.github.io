#!/bin/bash


# FDISK 

timedatectl set-ntp true
pacstrap /mnt base base-devel git linux-lts linux-firmware nano networkmanager
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
ln -sf /usr/share/zoneinfo/Europe/Bucharest /etc/localtime
hwclock --systohc
sed -i '177s/.//' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "arch" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 arch.localdomain arch" >> /etc/hosts
echo root:x | chpasswd

pacman -S --noconfirm grub efibootmgr 
mkdir /boot/efi
mount /dev/sda1 /boot/efi

# pacman -S --noconfirm xf86-video-amdgpu
# pacman -S --noconfirm nvidia nvidia-utils nvidia-settings

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager

useradd -m laurentiu
echo laurentiu:x | chpasswd
usermod -aG libvirt laurentiu

echo " ALL=(ALL) ALL" >> /etc/sudoers.d/laurentiu

git clone https://aur.archlinux.org/yay.git
cd yay/
makepkg -si --noconfirm

/bin/echo -e "\e[1;32mDone! Type exit, umount -a and reboot.\e[0m"

