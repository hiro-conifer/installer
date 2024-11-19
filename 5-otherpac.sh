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
cd && git clone https://aur.archlinux.org/$aur.git
cd $aur && makepkg -si --noconfirm
$aur -Sy

# Change user & Disable nopassword
__EOF__
sudo sed -e "s/${sudoop}//g" /etc/sudoers | EDITOR=tee visudo > /dev/null

# Remove AUR Installer
rm -rf /home/${usernm}/$aur

# Install other packages
pacman -S --noconfirm clamav ufw opendoas networkmanager pacman-contrib

# Setting Packages
# Clamav
echo -e "\
DatabaseDirectory /var/lib/clamav\n\
UpdateLogFile /var/log/clamav/freshclam.log\n\
LogTime yes\n\
LogSyslog no\n\
PidFile /run/clamav/freshclam.pid\n\
DatabaseOwner clamav\n\
DatabaseMirror db.jp.clamav.net" > /etc/clamav/freshclam.conf
touch /var/log/clamav/freshclam.log && chown -R clamav:clamav /var/log/clamav
freshclam

# Ufw
ufw default deny
sed -i -e "s/\(ENABLED=\)no/\1yes/" /etc/ufw/ufw.conf

# Opendoas
echo -e "permit setenv {PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin} :wheel\npermit persist :wheel" > /etc/doas.conf && chmod -c 0400 /etc/doas.conf

# Enable Services
systemctl enable {ufw,NetworkManager,systemd-{resolved,timesyncd},sshd}.service {paccache,fstrim,clamav-freshclam-once}.timer

# GPU Setting(AMD)
if [ -n "`lspci | grep AMD`" ]; then
  pacman -S --noconfirm xf86-video-amdgpu mesa lib32-mesa libva-mesa-driver mesa-vdpau vulkan-radeon
  echo -e "DISABLE_LAYER_AMD_SWITCHABLE_GRAPHICS_1=1\nVK_ICD_FILENAMES=/usr/share/vulkan/icd.d/radeon_icd.i686.json:/usr/share/vulkan/icd.d/radeon_icd.x86_64.json\nRADV_PERFTEST=rt,gpl,nv_ms" >> /etc/environment
fi
_EOF_
