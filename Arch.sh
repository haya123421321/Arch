#!/bin/bash

read -p "Type your password for sudo: " password
User=$(whoami)

echo "$password" | sudo -S sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
echo "$password" | sudo -S pacman -Syyu --noconfirm
echo "$password" | sudo -S pacman -S base noto-fonts-emoji virtualbox virtualbox-guest-utils wine lutris spotify-launcher vlc base-devel fontconfig ttf-droid shotwell steam discord bitwarden dolphin binutils linux-headers zsh gcc ntfs-3g git make zsh-completions zsh-syntax-highlighting vim --noconfirm

fc-cache
cd /opt
echo "$password" | sudo -S git clone https://aur.archlinux.org/yay-git.git
echo "$password" | sudo -S chown -R $User:$User ./yay-git
cd /opt/yay-git
echo "Y" | makepkg -si
echo "Y" | makepkg -si
yay -S --noconfirm zsh-theme-powerlevel10k-git sublime-text-4 freedownloadmanager libunity google-chrome

cd ~
git clone https://haya123421321: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@github.com/haya123421321/Arch
echo "$password" | sudo -S cat Arch/zshrc > ~/.zshrc
echo "$password" | sudo -S cat Arch/p10k.zsh > ~/.p10k.zsh
mkdir -p ~/.config/fontconfig/conf.d
cat Arch/1-fonts.conf > ~/.config/fontconfig/conf.d/1-fonts.conf
echo "$password" | sudo -S mv Arch/1920x1080.png /usr/share/wallpapers/Next/contents/images_dark/1920x1080.png
mkdir -p .config/sublime-text/Packages/User
cat Arch/Keybinds.txt > '.config/sublime-text/Packages/User/Default (Linux).sublime-keymap'
cat Arch/Settings.txt > .config/sublime-text/Packages/User/Preferences.sublime-settings
echo 'change shell to zsh'
printf "$password\n/bin/zsh" | chsh
echo "$password" | sudo -S rm -R Arch

echo "Taskbar icons: <WebBrowser> Steam Spotify Discord Bitwarden Dolphin SystemSettings SystemMonitor Konsole" > TaskbarIcons
echo "Desktop: <WebBroser> Steam Discord Dolphin VirtualBox" > DesktopIcons
