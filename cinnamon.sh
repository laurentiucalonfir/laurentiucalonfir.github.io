#!/bin/bash

sudo timedatectl set-ntp true
sudo hwclock --systohc


git clone https://aur.archlinux.org/yay.git
cd yay/
makepkg -si --noconfirm

yay -S --noconfirm xviewer
yay-S --noconfirm xplayer
yay -S --noconfirm pix

#pikaur -S --noconfirm system76-power
#sudo systemctl enable --now system76-power
#sudo system76-power graphics integrated
#pikaur -S --noconfirm gnome-shell-extension-system76-power-git
#pikaur -S --noconfirm auto-cpufreq
#sudo systemctl enable --now auto-cpufreq

sudo pacman -S --noconfirm xorg lightdm-gtk-greeter lightdm-gtk-greeter-settings cinnamon arc-gtk-theme arc-icon-theme xed metacity gnome-terminal


sudo systemctl enable lightdm
/bin/echo -e "\e[1;32mREBOOTING IN 5..4..3..2..1..\e[0m"
sleep 5
sudo reboot
