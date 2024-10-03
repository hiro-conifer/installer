#!/bin/bash
# Value
usernm=$1
aur=$2
sudoop="$usernm ALL=NOPASSWD: ALL"
dotdir=/home/${usernm}/.local/share/chezmoi

# arch-chroot
arch-chroot /mnt << _EOF_

# Enable nopassword & Change user
echo ${sudoop} | EDITOR='tee -a' visudo > /dev/null
su $usernm << __EOF__

# Install AUR Helper
$aur -S --noconfirm xorg-xwayland qt5-wayland \
                    sway{fx,lock-effects,idle,bg} waybar grim slurp \
                    kitty wofi nnn \
                    pipewire wireplumber pipewire-{alsa,pulse} pavucontrol playerctl \
                    bluez{,-utils} blueman \
                    fcitx5-mozc \
                    xdg-desktop-portal{,-{gtk,wlr}} \
                    exa bat \
                    chezmoi vivaldi

# Chezmoi
mkdir -p $dotdir && git clone https://github.com/hiro-conifer/dotfiles $dotdir
chezmoi apply

# Change user & Disable nopassword
__EOF__
sudo sed -e "s/${sudoop}//g" /etc/sudoers | EDITOR=tee visudo > /dev/null

# Vivaldi
sed -i -e "s/\(Exec=\/usr\/bin\/vivaldi-stable\) \(%U\)/\1 --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime \2/" /usr/share/applications/vivaldi-stable.desktop

_EOF_
