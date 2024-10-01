#!/bin/bash
# Input value
function typeVal() {
	while :
	do
		echo -n -e "$1\n > " >&2 && read rtn && echo "" >&2

		if [ -n "$rtn" ]; then
			break
		fi
	done
	echo $rtn
}

# Search CPU vendor
if [ -n "`lscpu | grep Intel`" ]; then
	ucode=intel-ucode
elif [ -n "`lscpu | grep AMD`" ]; then
	ucode=amd-ucode
fi

# Input install partition
while :
do
	part=/dev/$(typeVal "Type the partition.")

	if [[ -e $part ]]; then
		if [[ $part == /dev/nvme* ]]; then
			part_boot=${part}p1
			part_root=${part}p2
		else
			part_boot=${part}1
			part_root=${part}2
		fi
		break
	else
		echo -e "Not found \"${part}\"."
	fi
done

# Value
rootpw=$(typeVal "Type root password")
usernm=$(typeVal "Type user name.")
userpw=$(typeVal "Type $usernm password.")
hostnm=$(typeVal "type host name")
aur=yay
