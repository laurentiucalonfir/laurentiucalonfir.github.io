#!/bin/bash

sudo reflector -c Romania -a 12 --sort rate --save /etc/pacman.d/mirrorlist

sudo pacman -S --noconfirm xorg gdm baobab eog evince file-roller gedit gnome-backgrounds gnome-calculator gnome-calendar gnome-characters gnome-clocks gnome-color-manager gnome-tweaks chrome-gnome-shell 

sudo systemctl enable gdm
/bin/echo -e "\e[1;32mREBOOTING IN 5..4..3..2..1..\e[0m"
sleep 5
sudo reboot
