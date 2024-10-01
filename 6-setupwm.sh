#!/bin/bash

# Install Packages
pacman -S --noconfirm vivaldi

# Vivaldi
sed -i -e "s/\(Exec=\/usr\/bin\/vivaldi-stable\) \(%U\)/\1 --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime \2/" /usr/share/applications/vivaldi-stable.desktop
