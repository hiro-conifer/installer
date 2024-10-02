#!/bin/bash
# Edit pacman.conf
function confPacman() {
	sed -i -e "/^#\(Color\|VerbosePkgLists\|ParallelDownloads\)/s/^#//" $1
	sed -i -e "/\[multilib\]/,/Include/"'s/^#//' $1
}

# Values
part_boot=$1
part_root=$2
ucode=$3

# Mount Partition
mount $part_root /mnt
mount --mkdir $part_boot /mnt/boot

# setting pacman / Install Base packages
confPacman "/etc/pacman.conf"
pacman --noconfirm -Sy archlinux-keyring
pacstrap /mnt base{,-devel} linux-{zen{,-headers},firmware} 
pacstrap /mnt booster $ucode git go wget neovim zsh starship \
              man{,-db,-pages} \
              rclone openssh \
              unarchiver \
              btop
confPacman "/mnt/etc/pacman.conf"
