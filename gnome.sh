#!/bin/bash

# Variables
DISK="/dev/sda"
EFI_PART="${DISK}1"
ROOT_PART="${DISK}2"
HOSTNAME="archlinux"
USERNAME="laurentiu"
PASSWORD="x"  # replace with desired password or prompt for it securely
TIMEZONE="Europe/Bucharest"

# Update system clock
timedatectl set-ntp true

# Partition the disk
parted -s $DISK mklabel gpt
parted -s $DISK mkpart primary fat32 1MiB 1GB
parted -s $DISK set 1 esp on
parted -s $DISK mkpart primary ext4 1GB 100%

# Format the partitions
mkfs.fat -F32 $EFI_PART
mkfs.ext4 $ROOT_PART

# Mount the file systems
mount $ROOT_PART /mnt
mkdir /mnt/boot
mount $EFI_PART /mnt/boot

# Install base system and linux-lts kernel
pacstrap /mnt base base-devel linux-lts linux-lts-headers linux-firmware intel-ucode pipewire pipewire-alsa pacman-contrib networkmanager vim git

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot into the new system
arch-chroot /mnt /bin/bash <<EOF

# Set the time zone
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc

# Localization
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Network configuration
echo "$HOSTNAME" > /etc/hostname
cat <<EOT > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
EOT

# Initramfs
mkinitcpio -P

# Root password
echo -e "$PASSWORD\n$PASSWORD" | passwd

# Bootloader installation
bootctl install
cat <<EOT > /boot/loader/loader.conf
default arch
timeout 3
editor 0
EOT

cat <<EOT > /boot/loader/entries/arch.conf
title   Arch-Linux lts
linux   /vmlinuz-linux-lts
initrd  /initramfs-linux-lts.img
initrd  /intel-ucode.img
options root=PARTUUID=$(blkid -s PARTUUID -o value $ROOT_PART) rw
EOT

# Create a new user
useradd -m -G wheel $USERNAME
echo -e "$PASSWORD\n$PASSWORD" | passwd $USERNAME

# Configure sudo
pacman -S --noconfirm sudo
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

#Configure reflector
pacman -Syu --noconfirm reflector
reflector --verbose --latest 5 --sort rate --save /etc/pacman.d/mirrorlist

#Configure chaotic-aur
pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
pacman-key --lsign-key 3056513887B78AEB
pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
echo [chaotic-aur] >> /etc/pacman.conf
echo Include = /etc/pacman.d/chaotic-mirrorlist >> /etc/pacman.conf

# Enable necessary services
systemctl enable systemd-networkd
systemctl enable systemd-resolved
systemctl enable NetworkManager

# Install gnome
pacman -Sy --noconfirm archlinux-wallpaper google-chrome extension-manager anydesk stremio kdeconnect gnome-tweaks seahorse baobab evince gdm gnome-calculator gnome-calendar gnome-characters gnome-clocks gnome-color-manager gnome-connections gnome-terminal 	gnome-control-center gnome-disk-utility gnome-font-viewer gnome-keyring gnome-logs gnome-maps gnome-menus gnome-music gnome-remote-desktop gnome-session gnome-settings-daemon gnome-shell gnome-shell-extensions gnome-system-monitor gnome-text-editor gnome-user-docs gnome-user-share gnome-weather grilo-plugins gvfs gvfs-afc gvfs-dnssd gvfs-goa gvfs-google gvfs-gphoto2 gvfs-mtp gvfs-nfs 	gvfs-onedrive gvfs-smb gvfs-wsdd loupe malcontent nautilus orca rygel simple-scan snapshot sushi tecla totem xdg-desktop-portal-gnome xdg-user-dirs-gtk
systemctl enable gdm
EOF

# Unmount and reboot
umount -R /mnt
echo "Instalation finished. Rebooting in 5 seconds"
for i in {5..1}
do 
echo -ne "$i.."
sleep 1
done
echo "Rebooting now..."
reboot
