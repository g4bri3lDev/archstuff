#!/bin/bash

USERN=$1
git clone https://github.com/g4bri3lDev/dotfiles.git "/home/$USERN/Documents/dotfiles"

shopt -s dotglob
rm -rf /home/$USERN/.*
for file in /home/$USERN/Documents/dotfiles/* ;
do
	 ln -sf /home/$USERN/Documents/dotfiles/$file -t /home/$USERN/
 done
