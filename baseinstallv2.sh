#!/bin/sh

#Get optional arguments
while getopts ":d:u:n:p:r:h" o; do case "${o}" in
	h) printf "Optional Arguments: \\n -h: Display this message\\n -d: specify Disk to install to\\n -n: specify hostname\\n -u: specify username\\n -r: specify root password\\n -p: specify user password" && exit ;;
	d) DISK=${OPTARG} ;;
	n) HOSTN=${OPTARG} ;;
	u) USERN=${OPTARG} ;;
	r) ROOTPW=${OPTARG} ;;
	p) USERPW=${OPTARG} ;;
	*) printf "Invalid Arguments" && exit ;;
esac done

#Check if arguments are present
[ -z "$DISK" ] && DISK="/dev/sda"
[ -z "$HOSTN" ] && HOSTN="krypton"
[ -z "$USERN" ] && USERN="gabriel"
[ -z "$ROOTPW" ] && ROOTPW=$(dialog --no-cancel --passwordbox "Enter root password" 10 60 3>&1 1>&2 2>&3 3>&1)
[ -z "$USERPW" ] && USERPW=$(dialog --no-cancel --passwordbox "Enter password for $USERN" 10 60 3>&1 1>&2 2>&3 3>&1)

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

installBase() {
	cat >>/etc/pacman.conf <<EOF
	[g4bri3l]
	SigLevel = Optional TrustAll
	Server = https://g4bri3l.de/arch-pkgs
EOF

	pacstrap /mnt base base-devel linux linux-firmware g4bri3l-full
	mv /mnt/etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist.bak
	printf "Ranking Mirrors..."
	/mnt/usr/bin/rankmirrors -n 4 /mnt/etc/pacman.d/mirrorlist.bak > /mnt/etc/pacman.d/mirrorlist

	cat >>/mnt/etc/pacman.conf <<EOF
	[g4bri3l]
	SigLevel = Optional TrustAll
	Server = https://g4bri3l.de/arch-pkgs
EOF
}

installBootloader() {
	arch-chroot /mnt bootctl --path=/boot install
	echo "default arch-*" > /mnt/boot/loader/loader.conf
	echo -e "title\tArch Linux\nlinux\tvmlinuz-linux\ninitrd\t/initramfs-linux.img\noptions\troot=${DISK}2 rw" > /mnt/boot/loader/entries/arch.conf

}

chrootTasks() {
	wget https://raw.githubusercontent.com/g4bri3lDev/archstuff/master/chrootTasks.sh
	chmod +x chrootTasks.sh
	cp chrootTasks.sh /mnt/
	arch-chroot /mnt ./chrootTasks.sh -n "$HOSTN" -u "$USERN" -r "$ROOTPW" -p "$USERPW"
	rm /mnt/chrootTasks.sh
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

	installBase

	#Generate FSTab
	genfstab -L /mnt >> /mnt/etc/fstab

	chrootTasks

	installBootloader

	rmmod pcspkr
	echo "blacklist pcspkr" > /mnt/etc/modprobe.d/nobeep.conf

}
installBootloader() {
	arch-chroot /mnt bootctl --path=/boot install
	echo "default arch-*" > /mnt/boot/loader/loader.conf
	echo -e "title\tArch Linux\nlinux\tvmlinuz-linux\ninitrd\t/initramfs-linux.img\noptions\troot=${DISK}2 rw" > /mnt/boot/loader/entries/arch.conf

}


install
