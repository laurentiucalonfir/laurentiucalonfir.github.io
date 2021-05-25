#!/bin/bash

sudo timedatectl set-ntp true
sudo hwclock --systohc


git clone https://aur.archlinux.org/yay.git
cd yay/
makepkg -si --noconfirm

sudo pacman -S --noconfirm xorg lightdm-gtk-greeter cinnamon arc-gtk-theme arc-icon-theme xed xreader nemo-fileroller nemo-preview metacity gnome-terminal gnome-screenshot gnome-system-monitor gnome-disk-utility imwheel numlockx archlinux-wallpaper neofetch xdg-user-dirs ttf-dejavu ttf-roboto ttf-liberation ttf-ubuntu-font-family

yay -S --noconfirm google-chrome
yay -S --noconfirm xviewer
yay -S --noconfirm stremio
yay -S --noconfirm wol-systemd
yay -S --noconfirm anydesk-bin

sudo systemctl enable lightdm
sudo systemctl enable anydesk
/bin/echo -e "\e[1;32mREBOOTING IN 5..4..3..2..1..\e[0m"
sleep 5
sudo reboot
