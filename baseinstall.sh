#!/bin/sh

while getopts ":d:h:n:u" o; do case "${o}" in
	h) printf "Optional Arguments: \\n -h: Display this message\\n -d: specify Disk to install to\\n -n: specify hostname\\n -u: specify username" && exit ;;
	d) DISK=${OPTARG} ;;
	n) HOSTN=${OPTARG} ;;
	u) USERN=${OPTARG} ;;
	*) printf "Invalid Arguments" && exit ;;
esac done


