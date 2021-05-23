#!/bin/bash
(
echo g # Create a new empty DOS partition table
echo n # Add a new partition
echo   # First sector (Accept default: 1)
echo +512M  # Last sector (Accept default: varies) 
echo t
echo 1
echo n # Add a new partition
echo 2 # Partition number
echo   # First sector
echo +4G # Last sector
echo t
echo 2
echo 19
echo n # Add a new partition
echo   # First sector
echo   # Last sector (Accept default: varies)
echo w # Write changes
) | sudo fdisk


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

pacman -S --noconfirm grub efibootmgr networkmanager linux-headers pacman-contrib git

# pacman -S --noconfirm xf86-video-amdgpu
# pacman -S --noconfirm nvidia nvidia-utils nvidia-settings

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager

useradd -m laurentiu
echo laurentiu:x | chpasswd

echo "laurentiu ALL=(ALL) ALL" >> /etc/sudoers.d/laurentiu


/bin/echo -e "\e[1;32mDone! Type exit, umount -a and reboot.\e[0m"

