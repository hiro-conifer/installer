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
$aur -S --noconfirm xorg-xwayland {qt5,qt6}-wayland \
                    sway{fx,lock-effects,idle,bg} waybar grim slurp kanshi mako \
                    nwg-look {materia-gtk,papirus-icon}-theme \
                    lightdm{,-webkit2-{greeter,theme-glorious}} \
                    polkit{,-gnome} \
                    noto-fonts{,-{cjk,emoji,extra}} ttf-{defavu,jetbrains-mono-nerd,liberation}\
                    kitty wofi nnn neofetch cli-visualizer \
                    pipewire wireplumber pipewire-{alsa,pulse} pavucontrol playerctl \
                    bluez{,-utils} blueman \
                    fcitx5{,-{configtool,gtk,mozc,qt}} \
                    xdg-desktop-portal{,-{gtk,wlr}} \
                    exa bat \
                    chezmoi vivaldi chromium \
                    steam{,tinkerlaunch} heroic-games-launcher

# Chezmoi
mkdir -p $dotdir && git clone https://github.com/hiro-conifer/dotfiles $dotdir
chezmoi apply
chmod -R 775 ${userdir}/.local/bin

# Vivaldi
ln -sf ${userdir}/.config/chromium-flags.conf ${userdir}/.config/vivaldi-stable.conf

# Change user & Disable nopassword
__EOF__
sudo sed -e "s/${sudoop}//g" /etc/sudoers | EDITOR=tee visudo > /dev/null

# Sway
sed -i -e "s/\(Exec=\)sway/\1\/usr\/local\/bin\/sway.sh/" /usr/share/wayland-sessions/sway.desktop
mv ${userdir}/.local/bin/sway.sh /usr/local/bin/ && chmod 775 /usr/local/bin/sway.sh

#lightdm
mv ${userdir}/.local/bin/Wsession /etc/lightdm/

_EOF_
