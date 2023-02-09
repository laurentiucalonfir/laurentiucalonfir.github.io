#!/bin/bash

# Set variables for partition names and file systems
root_partition=root
swap_partition=swap
root_filesystem=ext4
swap_filesystem=swap

# Update the system clock
timedatectl set-ntp true

# Partition the disk
parted /dev/sda mklabel gpt
parted /dev/sda mkpart primary $root_filesystem 1MiB 100%
parted /dev/sda mkpart primary $swap_filesystem 100% 100%
parted /dev/sda set 2 swap on

# Format the partitions
mkfs.$root_filesystem /dev/sda1
mkswap /dev/sda2
swapon /dev/sda2

# Mount the file system
mount /dev/sda1 /mnt

# Select the mirrors
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
rankmirrors -n 6 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist

# Install the base packages
pacstrap /mnt base linux-lts linux-lts-headers networkmanager

# Generate the fstab file
genfstab -U /mnt >> /mnt/etc/fstab

# Create the system configuration script
cat <<EOF > /mnt/install-config.sh
#!/bin/bash

# Set the hostname
echo "archlinux" > /etc/hostname
sudo systemctl enable NetworkManager 

# Set the time zone
ln -sf /usr/share/zoneinfo/Europe/Bucharest /etc/localtime

# Set the locale
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Configure the initramfs
mkinitcpio -p linux-lts

# Install the bootloader
bootctl install

# Configure the boot loader
cat <<EOF > /boot/loader/entries/arch.conf
title   Arch Linux
linux   /vmlinuz-linux-lts
initrd  /initramfs-linux-lts.img
options root=PARTUUID=$(blkid -s PARTUUID -o value /dev/sda1) rw
EOF

# Set the root password
echo "root:root" | chpasswd

# Create a new user
useradd -m -G wheel -s /bin/bash user
echo "user:user" | chpasswd

# Configure sudo
echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel
EOF

# Chroot into the new system
arch-chroot /mnt /bin/bash /install-config.sh

# Unmount and reboot
umount /mnt
reboot
