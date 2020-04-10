#!/bin/sh

#Get optional arguments
while getopts ":d:u:n:h" o; do case "${o}" in
	h) printf "Optional Arguments: \\n -h: Display this message\\n -d: specify Disk to install to\\n -n: specify hostname\\n -u: specify username" && exit ;;
	d) DISK=${OPTARG} ;;
	n) HOSTN=${OPTARG} ;;
	u) USERN=${OPTARG} ;;
	*) printf "Invalid Arguments" && exit ;;
esac done

#Check if arguments are present
[ -z "$DISK" ] && DISK="/dev/sda"
[ -z "$HOSTN" ] && HOSTN="krypton"
[ -z "$USERN" ] && USERN="gabriel"

partition() {
	parted -s "$DISK" mklabel gpt mkpart primary fat32 1MiB 261MiB set 1 esp on mkpart primary ext4 261MiB 100%
	mkfs.fat -F32 "${DISK}1"
	mkfs.ext4 "${DISK}2"
}

createSwap() {
	RAMSZ=$(cat /proc/meminfo | grep MemTotal | awk -F ' ' '{print $2}')
	fallocate -l "${RAMSZ}k" /mnt/swapfile
	chmod 600 /mnt/swapfile
	mkswap /mnt/swapfile
	swapon /mnt/swapfile
}

install() {
	#Set Systemclock
	timedatectl set-ntp true
	partition

	#Mount Partitions
	mount "${DISK}2" /mnt
	mkdir /mnt/boot
	mount "${DISK}1" /mnt/boot

	#Create Swapfile
	createSwap



}
