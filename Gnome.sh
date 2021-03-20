#!/bin/bash

sudo timedatectl set-ntp true
sudo hwclock --systohc
cd /tmp

git clone https://aur.archlinux.org/yay.git
cd yay/
makepkg -si --noconfirm
cd /

sudo pacman -S --noconfirm xorg gdm baobab eog evince file-roller gedit gnome-backgrounds gnome-calculator gnome-calendar gnome-characters gnome-clocks gnome-color-manager gnome-control-center gnome-disk-utility gnome-documents gnome-font-viewer gnome-getting-started-docs gnome-keyring gnome-logs gnome-maps gnome-menus gnome-music gnome-photos gnome-remote-desktop gnome-screenshot gnome-session gnome-settings-daemon gnome-shell gnome-shell-extensions gnome-system-monitor gnome-terminal gnome-themes-extra gnome-user-docs gnome-user-share gnome-video-effects 	grilo-plugins gvfs gvfs-afc gvfs-goa gvfs-google gvfs-gphoto2 gvfs-mtp gvfs-nfs gvfs-smb mutter nautilus rygel simple-scan sushi tracker tracker3 tracker3-miners tracker-miners vino xdg-user-dirs-gtk totem gnome-tweaks chrome-gnome-shell neofetch fish imwheel 

sudo systemctl enable gdm
/bin/echo -e "\e[1;32mREBOOTING IN 5..4..3..2..1..\e[0m"
sleep 5
sudo reboot
