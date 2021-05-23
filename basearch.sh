#!/bin/bash

(
echo g # Create a new empty gpt partition table
echo n # Add a new partition
echo
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
echo
echo   # Last sector (Accept default: varies)
echo w # Write changes
) | fdisk /dev/sda

mkfs.vfat /dev/sda1
mkswap /dev/sda2
mkfs.ext4 /dev/sda3
swapon /dev/sda2
mount /dev/sda3 /mnt

pacstrap /mnt base base-devel linux-lts linux-firmware nano
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt mkdir /boot/efi
arch-chroot /mnt mount /dev/sda1 /boot/efi

arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Bucharest /etc/localtime
arch-chroot /mnt hwclock --systohc
sed -i '177s/.//' /etc/locale.gen
arch-chroot /mnt locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "arch" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 arch.localdomain arch" >> /etc/hosts
echo root:x | chpasswd

arch-chroot /mnt pacman -S --noconfirm grub efibootmgr networkmanager linux-headers pacman-contrib git

# pacman -S --noconfirm xf86-video-amdgpu
# pacman -S --noconfirm nvidia nvidia-utils nvidia-settings



arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

arch-chroot /mnt systemctl enable NetworkManager

arch-chroot /mnt useradd -m laurentiu
arch-chroot /mnt echo laurentiu:x | chpasswd

echo "laurentiu ALL=(ALL) ALL" >> /etc/sudoers.d/laurentiu


/bin/echo -e "\e[1;32mDone! Type exit, umount -a and reboot.\e[0m"

