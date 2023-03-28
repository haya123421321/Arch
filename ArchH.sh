#!/bin/bash

read -p "Type your password for sudo: " password
User=$(whoami)

echo "$password" | sudo -S sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
curl -O https://blackarch.org/strap.sh;chmod +x strap.sh
echo "$password" | sudo -S ./strap.sh
rm strap.sh

echo "$password" | sudo -S pacman -Syyu --noconfirm
echo "$password" | sudo -S pacman -S base noto-fonts-emoji virtualbox virtualbox-guest-utils  vlc base-devel fontconfig ttf-droid shotwell dolphin binutils linux-headers zsh gcc git make zsh-completions zsh-syntax-highlighting vim --noconfirm # Downloading useful packages.
echo "$password" | sudo -S pacman -S nmap freerdp2-x11 wireshark aircrack-ng wget gdb vim man sqlmap python2 nfs-common ruby-full terminator binwalk steghide exiftool ffuf hydra hashcat ftp python3-pip hashid net-tools --noconfirm # Tools

fc-cache
cd /opt
echo "$password" | sudo -S git clone https://aur.archlinux.org/yay-git.git
echo "$password" | sudo -S chown -R $User:$User ./yay-git
cd /opt/yay-git
echo "Y" | makepkg -si
echo "Y" | makepkg -si
yay -S --noconfirm zsh-theme-powerlevel10k-git sublime-text-4 freedownloadmanager libunity

cd ~
git clone https://haya123421321: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@github.com/haya123421321/Arch
echo "$password" | sudo -S cat Arch/zshrc > ~/.zshrc
echo "$password" | sudo -S cat Arch/p10k.zsh > ~/.p10k.zsh
mkdir -p ~/.config/fontconfig/conf.d
cat Arch/1-fonts.conf > ~/.config/fontconfig/conf.d/1-fonts.conf
echo "$password" | sudo -S cp Arch/1920x1080.jpg /usr/share/wallpapers/Next/contents/images/1920x1080.jpg
echo 'change shell to zsh'
printf "$password\n/bin/zsh" | chsh
echo "$password" | sudo -S rm -R Arch

echo "Taskbar icons: <WebBrowser> Dolphin SystemSettings SystemMonitor" > TaskbarIcons
