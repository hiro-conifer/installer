#!/bin/bash
# Value
usernm=$1
aur=$2
sudoop="$usernm ALL=NOPASSWD: ALL"

# arch-chroot
arch-chroot /mnt << _EOF_

# Enable nopassword
echo ${sudoop} | sudo EDITOR='tee -a' visudo > /dev/null

# Install AUR Helper
su $usernm << __EOF__
cd && git clone https://aur.archlinux.org/$aur.git
cd $aur && makepkg -si --noconfirm
__EOF__
rm -rf /home/${usernm}/$aur

# Disable nopassword
sudo sed -e "s/${sudoop}//g" /etc/sudoers | sudo EDITOR=tee visudo > /dev/null

# Install other packages
pacman -S --noconfirm clamav ufw opendoas networkmanager pacman-contrib

# Setting Packages
# Clamav
touch /var/log/clamav/freshclam.log && chown -R clamav:clamav /var/log/clamav
freshclam

# Ufw
ufw default deny

# Opendoas
echo permit setenv {PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin} :wheel > /etc/doas.conf && chmod -c 0400 /etc/doas.conf

# Enable Services
systemctl enable {ufw,NetworkManager,systemd-{resolved,timesyncd},sshd}.service {paccache,fstrim}.timer

_EOF_
