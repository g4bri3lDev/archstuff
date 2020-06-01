
#Get optional arguments
while getopts ":u:n:p:r:h" o; do case "${o}" in
		h) printf "Optional Arguments: \\n -h: Display this message\\n -d: specify Disk to install to\\n -n: specify hostname\\n -u: specify username\\n -r: specify root password\\n -p: specify user password" && exit ;;
		n) HOSTN=${OPTARG} ;;
		u) USERN=${OPTARG} ;;
		r) ROOTPW=${OPTARG} ;;
		p) USERPW=${OPTARG} ;;
		*) printf "Invalid Arguments" && exit ;;
esac done

ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo "$HOSTN" > /etc/hostname
echo "root:$ROOTPW" | chpasswd
useradd -m -g wheel -s /usr/bin/zsh "$USERN"
echo "$USERN:$USERPW" | chpasswd
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers
systemctl enable dhcpcd

#curl https://raw.githubusercontent.com/g4bri3lDev/archstuff/master/deployDots.sh -o deployDots.sh
#chmod +x deployDots.sh
#./deployDots.sh $USERN
#chown -R $USERN /home/$USERN/
su "$USERN" -c xdg-user-dirs-update
