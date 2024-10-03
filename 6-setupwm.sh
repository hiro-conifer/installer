#!/bin/bash
# Value
usernm=$1
aur=$2
sudoop="$usernm ALL=NOPASSWD: ALL"

# arch-chroot
arch-chroot /mnt << _EOF_

# Enable nopassword & Change user
echo ${sudoop} | EDITOR='tee -a' visudo > /dev/null
su $usernm << __EOF__

# Install AUR Helper
$aur -S --noconfirm sway{fx,lock-effects,idle,bg} waybar grim slurp \
                 kitty wofi nnn \
                 pipewire wireplumber pipewire-{alsa,pulse} pavucontrol playerctl \
                 bluez{,-utils} blueman \
                 chezmoi vivaldi

# Chezmoi
mkdir -p /home/${usernm}/.local/share/chezmoi && git clone https://github.com/hiro-conifer/dotfiles
chezmoi apply

# Change user & Disable nopassword
__EOF__
sudo sed -e "s/${sudoop}//g" /etc/sudoers | EDITOR=tee visudo > /dev/null

# Vivaldi
sed -i -e "s/\(Exec=\/usr\/bin\/vivaldi-stable\) \(%U\)/\1 --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime \2/" /usr/share/applications/vivaldi-stable.desktop

_EOF_
