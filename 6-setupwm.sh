#!/bin/bash
# Value
usernm=$1
aur=yay
sudoop="$usernm ALL=NOPASSWD: ALL"

# arch-chroot
arch-chroot /mnt << _EOF_

# Enable nopassword
echo ${sudoop} | EDITOR='tee -a' visudo > /dev/null

# Install AUR Helper
su $usernm << __EOF__
$aur --noconfirm swayfx vivaldi
__EOF__

# Disable nopassword
sudo sed -e "s/${sudoop}//g" /etc/sudoers | EDITOR=tee visudo > /dev/null

# Vivaldi
sed -i -e "s/\(Exec=\/usr\/bin\/vivaldi-stable\) \(%U\)/\1 --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime \2/" /usr/share/applications/vivaldi-stable.desktop
