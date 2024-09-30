#!/bin/bash
# Value
part_root=$1
hostnm=$2
usernm=$3
userpw=$4
rootpw=$5
ucode=$6

# Gen-fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Resolv
rm /mnt/etc/resolv.conf
ln -sf /run/systemd/resolve/resolv.conf /mnt/etc/resolv.conf

# arch-chroot
arch-chroot /mnt << _EOF_

# Setting Clock
hwclock --systohc
ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# Setting locale / vconsole
echo LANG=\"en_US.UTF-8\" > /etc/locale.conf
echo KEYMAP=\"jp106\"     > /etc/vconsole.conf

# Locale-gen
sed -i -e '/^#\(ja_JP\|en_US\).UTF-8/s/^#//' /etc/locale.gen
locale-gen

# Setting Hosts
echo $hostnm > /etc/hostname
echo -e "127.0.0.1 localhost\n::1 localhost\n127.0.1.1 ${hostnm}.localdomain ${hostnm}" > /etc/hosts

# Setting zram
echo zram > /etc/modules-load.d/zram.conf
echo ACTION=="add", KERNEL=="zram0", ATTR{comp_algorithm}="zstd", ATTR{disksize}="4G", RUN="/usr/bin/mkswap -U clear /dev/%k", TAG+="systemd" > /etc/udev/rules.d/99-zram.rules
echo dev/zram0 none swap defaults,pri=100 0 0 >> /etc/fstab

# Create User
useradd -m -s /bin/zsh -G wheel $usernm
echo root:${rootpw} | chpasswd
echo ${usernm}:${userpw} | chpasswd

# Install bootctl
bootctl install
echo -e "default arch.conf\ntimeout 4\nconsole-mode max\neditor no" > /boot/loader/loader.conf
echo -e "title Arch Linux\nlinux /vmlinuz-linux-zen\ninitrd ${ucode}.img\ninitrd /booster-linux-zen.img\noptions root=$(blkid -o export ${part_root} | grep ^PARTUUID) rw" > /boot/loader/entries/arch.conf

# Setting sudoers
sed -e '/%wheel ALL=(ALL:ALL) ALL/s/^# //' /etc/sudoers | EDITOR=tee visudo > /dev/null

_EOF_
