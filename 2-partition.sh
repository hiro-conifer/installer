#!/bin/bash
# Values
part=$1
part_boot=$2
part_root=$3

# Create partition
sgdisk -Z $part
sgdisk -o $part
sgdisk -n 1:0:+512M -t 1:ef00 $part
sgdisk -n 2:0: -t 2:8304 $part

# Format partitions
mkfs.vfat -F32 $part_boot
mkfs.ext4 $part_root
