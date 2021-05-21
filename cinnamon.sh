#!/bin/bash

sudo timedatectl set-ntp true
sudo hwclock --systohc


git clone https://aur.archlinux.org/yay.git
cd yay/
makepkg -si --noconfirm

sudo pacman -S --noconfirm xorg lightdm-gtk-greeter lightdm-gtk-greeter-settings cinnamon arc-gtk-theme arc-icon-theme xed metacity gnome-terminal

sudo systemctl enable lightdm
/bin/echo -e "\e[1;32mREBOOTING IN 5..4..3..2..1..\e[0m"
sleep 5
sudo reboot
