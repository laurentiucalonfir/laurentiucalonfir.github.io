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
) | fdisk /dev/sdb

mkfs.vfat /dev/sdb1
mkswap /dev/sdb2
mkfs.ext4 /dev/sdb3
swapon /dev/sdb2
mount /dev/sdb3 /mnt
mkdir -p /mnt/boot/efi
mount /dev/sdb1 /mnt/boot/efi

pacstrap /mnt base base-devel linux-lts linux-firmware nano
genfstab -U /mnt >> /mnt/etc/fstab


arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Bucharest /etc/localtime
arch-chroot /mnt hwclock --systohc
sed -i '177s/.//' /mnt/etc/locale.gen
arch-chroot /mnt locale-gen
echo "LANG=en_US.UTF-8" >> /mnt/etc/locale.conf
echo "arch" >> /mnt/etc/hostname
echo "127.0.0.1 localhost" >> /mnt/etc/hosts
echo "::1       localhost" >> /mnt/etc/hosts
echo "127.0.1.1 arch.localdomain arch" >> /mnt/etc/hosts
arch-chroot /mnt echo root:x | chpasswd
printf "x\nx" | arch-chroot /mnt passwd


arch-chroot /mnt pacman -S --noconfirm grub efibootmgr networkmanager pacman-contrib git

# pacman -S --noconfirm xf86-video-amdgpu
# pacman -S --noconfirm nvidia nvidia-utils nvidia-settings



arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
arch-chroot /mnt systemctl enable NetworkManager


arch-chroot /mnt useradd -m laurentiu
printf "x\nx" | arch-chroot /mnt  passwd laurentiu
echo "laurentiu ALL=(ALL) ALL" >> /mnt/etc/sudoers.d/laurentiu



umount -a
echo -e "\e[1;32mRebooting in 5..4..3..2..1\e[0m"
sleep 5
reboot



