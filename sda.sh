#!/bin/bash

# Variables
DISK="/dev/sda"
EFI_PART="${DISK}1"
ROOT_PART="${DISK}2"
EFI_MOUNT="/mnt/boot"
ROOT_MOUNT="/mnt"

# 1. Partition the disk
echo "Partitioning the disk..."
parted -s $DISK mklabel gpt
parted -s $DISK mkpart primary fat32 1MiB 512MiB
parted -s $DISK set 1 esp on
parted -s $DISK mkpart primary ext4 512MiB 100%

# 2. Format the partitions
echo "Formatting the partitions..."
mkfs.fat -F32 $EFI_PART
mkfs.ext4 $ROOT_PART

# 3. Mount the filesystems
echo "Mounting the filesystems..."
mount $ROOT_PART $ROOT_MOUNT
mkdir -p $EFI_MOUNT
mount $EFI_PART $EFI_MOUNT

# 4. Install the base system
echo "Installing the base system..."
pacstrap $ROOT_MOUNT base linux linux-firmware

# 5. Generate fstab
echo "Generating fstab..."
genfstab -U $ROOT_MOUNT >> $ROOT_MOUNT/etc/fstab

# 6. Chroot into the new system
echo "Chrooting into the new system..."
arch-chroot $ROOT_MOUNT /bin/bash <<EOF

# 7. Set the time zone
echo "Setting the time zone..."
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
hwclock --systohc

# 8. Localization
echo "Setting up localization..."
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# 9. Network configuration
echo "Setting up the hostname and hosts file..."
echo "myhostname" > /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 myhostname.localdomain myhostname" >> /etc/hosts

# 10. Set the root password
echo "Setting the root password..."
echo "root:password" | chpasswd

# 11. Install and configure systemd-boot
echo "Installing systemd-boot..."
bootctl --path=$EFI_MOUNT install

# Create loader configuration
echo "default arch" > /boot/loader/loader.conf
echo "timeout 3" >> /boot/loader/loader.conf
echo "editor 0" >> /boot/loader/loader.conf

# Create boot entry
PARTUUID=$(blkid -s PARTUUID -o value $ROOT_PART)
echo "title   Arch Linux" > /boot/loader/entries/arch.conf
echo "linux   /vmlinuz-linux" >> /boot/loader/entries/arch.conf
echo "initrd  /initramfs-linux.img" >> /boot/loader/entries/arch.conf
echo "options root=PARTUUID=$PARTUUID rw" >> /boot/loader/entries/arch.conf

EOF

# 12. Unmount filesystems and reboot
echo "Unmounting filesystems and rebooting..."
umount -R $ROOT_MOUNT
reboot

echo "Arch Linux installation with systemd-boot is complete!"
