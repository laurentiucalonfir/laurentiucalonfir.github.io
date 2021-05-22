#!/bin/sh

CONFIG_FILE="uefi.conf"
. "./$CONFIG_FILE"

printf "\n" | timedatectl set-ntp true

BOOT_PARTITION=""
ROOT_PARTITION=""
if [ -n "$(echo $DEVICE | grep "^/dev/[a-z]d[a-z]")" ]; then
    BOOT_PARTITION="${DEVICE}1"
    ROOT_PARTITION="${DEVICE}2"
elif [ -n "$(echo $DEVICE | grep "^dev/nvme")" ]; then
    BOOT_PARTITION="${DEVICE}p1"
    ROOT_PARTITION="${DEVICE}p2"
fi

printf "n\n\n\n+300M\nef00\nn\n\n\n\n\nw\ny\n" | gdisk $DEVICE

mkfs.fat -F32 $BOOT_PARTITION
mkfs.ext4 $ROOT_PARTITION

mount $ROOT_PARTITION /mnt
mkdir -p /mnt/boot/efi
mount $BOOT_PARTITION /mnt/boot/efi

pacstrap /mnt base base-devel linux-lts linux-firmware nano

genfstab -U /mnt >> /mnt/etc/fstab

# setup timezone
arch-chroot /mnt ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
arch-chroot /mnt hwclock --systohc

# localization
sed -i '177s/.//' /mnt/etc/locale.gen
arch-chroot /mnt locale-gen
echo "LANG=$LOCALE" >> /mnt/etc/locale.conf 
echo "KEYMAP=$KEYMAP" >> /mnt/etc/vconsole.conf

# network configuration
echo "$HOSTNAME" >> /mnt/etc/hostname
echo "127.0.0.1 localhost" >> /mnt/etc/hosts
echo "::1       localhost" >> /mnt/etc/hosts
echo "127.0.0.1 $HOSTNAME.localdomain $HOSTNAME" >> /mnt/etc/hosts

# set root password
# echo root:$ROOT_PASS | chpasswd
printf "$ROOT_PASS\n$ROOT_PASS" | arch-chroot /mnt passwd

# install packages
arch-chroot /mnt pacman -S --noconfirm grub efibootmgr networkmanager xdg-user-dirs xdg-utils neofetch linux-headers pacman-contrib git

# optional gpu packages
# pacman -S --noconfirm xf86-video-amdgpu
# pacman -S --noconfirm nvidia nvidia-utils nvidia-settings

# install grub bootloader
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

# enable services
arch-chroot /mnt systemctl enable NetworkManager


# add new user
arch-chroot /mnt useradd -m $USERNAME
# echo $USERNAME:$USER_PASS | chpasswd
printf "$USER_PASS\n$USER_PASS" | arch-chroot /mnt passwd $USERNAME
echo "$USERNAME ALL=(ALL) ALL" >> /mnt/etc/sudoers.d/$USERNAME




umount -a
echo -e "\e[1;32mRebooting in 5..4..3..2..1\e[0m"
sleep 5
reboot
