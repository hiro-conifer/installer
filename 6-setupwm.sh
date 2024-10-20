#!/bin/bash
# Value
usernm=$1
aur=$2
sudoop="$usernm ALL=NOPASSWD: ALL"
userdir=/home/${usernm}
dotdir=${userdir}/.local/share/chezmoi

# arch-chroot
arch-chroot /mnt << _EOF_

# Enable nopassword & Change user
echo ${sudoop} | EDITOR='tee -a' visudo > /dev/null
su $usernm << __EOF__

# Install AUR Helper
$aur -S --noconfirm xorg-xwayland qt5-wayland \
                    sway{fx,lock-effects,idle,bg} waybar grim slurp kanshi \
                    nwg-look {materia-gtk,papirus-icon}-theme \
                    noto-fonts{,-{cjk,emoji,extra}} \
                    kitty wofi nnn neofetch \
                    pipewire wireplumber pipewire-{alsa,pulse} pavucontrol playerctl \
                    bluez{,-utils} blueman \
                    fcitx5-mozc \
                    xdg-desktop-portal{,-{gtk,wlr}} \
                    exa bat \
                    chezmoi vivaldi

# Neovim(Install vim-jetpack)
curl -fLo ${userdir}/.local/share/nvim/site/pack/jetpack/opt/vim-jetpack/plugin/jetpack.vim --create-dirs https://raw.githubusercontent.com/tani/vim-jetpack/master/plugin/jetpack.vim

# Chezmoi
mkdir -p $dotdir && git clone https://github.com/hiro-conifer/dotfiles $dotdir
chezmoi apply

# Change user & Disable nopassword
__EOF__
sudo sed -e "s/${sudoop}//g" /etc/sudoers | EDITOR=tee visudo > /dev/null

# Sway
sed -i -e "s/\(Exec=\)sway/\1\/usr\/local\/bin\/sway.sh/" /usr/share/wayland-sessions/sway.desktop
mv ${userdir}/Documents/sway.sh /usr/local/bin/ && chmod 775 /usr/local/bin/sway.sh

# Vivaldi
sed -i -e "s/\(Exec=\/usr\/bin\/vivaldi-stable\) \(%U\)/\1 --disk-cache-dir=\/tmp --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime \2/" /usr/share/applications/vivaldi-stable.desktop

_EOF_
