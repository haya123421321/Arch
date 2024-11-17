#!/bin/bash

if [ "$(id -u)" = "0" ]; then
    echo "Please do not use sudo to run this script. Run it as a regular user."
    exit 1
fi

# Prompt the user for the sudo password
read -p "Type your password for sudo: " password

# Get the current user
User=$(whoami)

# Update pacman.conf to enable multilib repository
echo "$password" | sudo -S sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf 

# Update system and install packages
echo "$password" | sudo -S pacman -Syyu --noconfirm 
echo "$password" | sudo -S pacman -S i3 dmenu dunst ttf-font-awesome xclip rofi adobe-source-code-pro-fonts picom redshift base alacritty network-manager-applet tmux neovim noto-fonts-emoji gimp python-pipx python-pip mlocate virtualbox virtualbox-guest-utils wine sqlitebrowser spotify-launcher ttf-hack ttf-dejavu lutris vlc base-devel fontconfig shotwell steam discord bitwarden dolphin binutils linux-headers zsh gcc ntfs-3g git make zsh-autosuggestions zsh-completions zsh-syntax-highlighting vim --noconfirm 

# Update font cache
fc-cache

# Install yay AUR helper
cd /opt
echo "$password" | sudo -S git clone https://aur.archlinux.org/yay-git.git
echo "$password" | sudo -S chown -R $User:$User ./yay-git
cd /opt/yay-git
yes | makepkg -si > /dev/null 

# Install AUR packages using yay
echo "$password" | yay -S --noconfirm autotiling zsh-theme-powerlevel10k-git sublime-text-4 freedownloadmanager konsave libunity google-chrome dracula-kde-theme-git
pip install bs4 selenium requests pytube ffmpeg --break-system-packages 

# Clone configuration files from GitHub repository
cd ~
if [ -d Arch ]; then
  echo "Git Directory exists."
else
    git clone https://github.com/haya123421321/Arch.git
fi

if [ -d .dotfiles ]; then
  echo "Git Directory exists."
else
    clone git@github.com:haya123421321/.dotfiles.git
fi

# Copy configuration files to the appropriate locations
cat .dotfiles/.zshrc > ~/.zshrc
echo 'export PATH=$PATH:/usr/sbin:$(echo ~)/Scripts/Scripts' >> ~/.zshrc
cat .dotfiles/.p10k.zsh > ~/.p10k.zsh
cat .dotfiles/.tmux.conf ~/.tmux.conf
cp .dotfiles/Wallpaper.jpeg ~/Pictures/
cp -rf .dotfiles/config/. .config/

# Sublime
mkdir -p ~/.config/sublime-text/Packages/User
cat Arch/configs/Default (Linux).sublime-keymap > '.config/sublime-text/Packages/User/Default (Linux).sublime-keymap'
cat Arch/configs/Preferences.sublime-settings > '.config/sublime-text/Packages/User/Preferences.sublime-settings'

# Change default shell to Zsh
printf "$password\n/bin/zsh" | chsh

# Clean up cloned repository
echo "$password" | sudo -S rm -R Arch .dotfiles

# Get the Scripts folder
if [ -d Scripts ]; then
  echo "Git Directory exists."
else
    git clone https://github.com/haya123421321/Scripts
fi
for file in ~/Scripts/Youtube/*.py;do ln -sf $file ~/Scripts/Scripts/$(basename $file);done
for file in ~/Scripts/Viewer/*.py;do ln -sf $file ~/Scripts/Scripts/$(basename $file);done
cd ~/Scripts/GoScripts/
for file in *.go;do
    base_name="${file%.*}"
    go build $file
    mv $base_name ../Scripts
done
cd
chmod +x ~/Scripts/Scripts/*

# Setup PhotoGIMP
git clone https://github.com/Diolinux/PhotoGIMP
mkdir -p ~/.config/GIMP/2.10/
cp -r PhotoGIMP/.var/app/org.gimp.GIMP/config/GIMP/2.10/* ~/.config/GIMP/2.10/
sed -i '/(toolbox-group-menu-mode click)/a (icon-size medium)' ~/.config/GIMP/2.10/gimprc
rm -rf PhotoGIMP

# Set SDDM theme to 'Dracula'
if [ -f /etc/sddm.conf ]; then
    sudo sed -i "/^\[Theme\]/,/^\[/ s/^Current=.*/Current=Dracula/" /etc/sddm.conf
else
    echo -e "[Theme]\nCurrent=Dracula" | sudo tee /etc/sddm.conf
fi

# Set up autostart entries for various applications
mkdir -p ~/.config/autostart
discord="[Desktop Entry]\n\
Categories=Network;InstantMessaging;\n\
Comment=All-in-one voice and text chat for gamers that's free, secure, and works on both your desktop and phone.\n\
Exec=$(which discord)\n\
GenericName=Internet Messenger\n\
Icon=discord\n\
Name=Discord\n\
Path=$(dirname $(which discord))\n\
StartupWMClass=discord\n\
Type=Application\n\
"

FDM="[Desktop Entry]\n\
Comment=Free Download Manager\n\
Exec=$(which fdm) --hidden\n\
Hidden=false\n\
Name=FDM\n\
NoDisplay=false\n\
Type=Application\n\
X-GNOME-Autostart-enabled=true\n\
"

steam="Exec=steam steam://open/bigpicture\n\
Name=Big Picture\n\
\n\
[Desktop Action Community]\n\
Exec=steam steam://url/SteamIDControlPage\n\
Name=Community\n\
\n\
[Desktop Action Friends]\n\
Exec=steam steam://open/friends\n\
Name=Friends\n\
\n\
[Desktop Action Library]\n\
Exec=steam steam://open/games\n\
Name=Library\n\
\n\
[Desktop Action News]\n\
Exec=steam steam://open/news\n\
Name=News\n\
\n\
[Desktop Action Screenshots]\n\
Exec=steam steam://open/screenshots\n\
Name=Screenshots\n\
\n\
[Desktop Action Servers]\n\
Exec=steam steam://open/servers\n\
Name=Servers\n\
\n\
[Desktop Action Settings]\n\
Exec=steam steam://open/settings\n\
Name=Settings\n\
\n\
[Desktop Action Store]\n\
Exec=steam steam://store\n\
Name=Store\n\
\n\
[Desktop Entry]\n\
Actions=Store;Community;Library;Servers;Screenshots;News;Settings;BigPicture;Friends;\n\
Categories=Network;FileTransfer;Game;\n\
Comment=Application for managing and playing games on Steam\n\
Exec=$(which steam-runtime) %U\n\
Icon=steam\n\
MimeType=x-scheme-handler/steam;x-scheme-handler/steamlink;\n\
Name=Steam (Runtime)\n\
PrefersNonDefaultGPU=true\n\
Terminal=false\n\
Type=Application\n\
X-KDE-RunOnDiscreteGpu=true\n\
"

spotify="[Desktop Entry]\n\
Categories=Audio;Music;Player;AudioVideo;\n\
Exec=$(which spotify-launcher) %U\n\
GenericName=Music Player\n\
Icon=spotify-launcher\n\
MimeType=x-scheme-handler/spotify;\n\
Name=Spotify (Launcher)\n\
StartupWMClass=spotify\n\
Terminal=false\n\
TryExec=$(which spotify-launcher)\n\
Type=Application\n\
"

nvidia="[Desktop Entry]\n\
Exec=nvidia-settings --load-config-only\n\
Icon=nvidia-settings\n\
Name=NVIDIA X Server Settings\n\
Path=\n\
Terminal=False\n\
Type=Application\n\
"

anichecker="[Unit]\n\
Description=Anichecker\n\
Wants=network-online.target\n\
After=network-online.target\n\
\\n\
[Service]\n\
Type=simple\n\
User=$User\n\
ExecStart=$(which python) $(echo ~)/Scripts/Anichecker/Anichecker.py\n\
Restart=always\n\
RestartSec=3600\n\
\\n\
[Install]\n\
WantedBy=multi-user.target\n\
"

Viewer="[Desktop Entry]\n
Name=Viewer\n
Exec=$(echo ~)/Scripts/Viewer/Viewer.py\n
Icon=$(echo ~)/.local/share/icons/viewer.jpg\n
Type=Application\n
Categories=Utility;\n
"


echo -e "$anichecker" > /tmp/anichecker_temp
sudo mv /tmp/anichecker_temp /etc/systemd/system/anichecker.service
echo "$password" | sudo -S systemctl enable anichecker 

echo -e "$Viewer" > ~/.local/share/applications/Viewer.desktop
echo -e "$discord" > ~/.config/autostart/discord.desktop
echo -e "$FDM" > ~/.config/autostart/FDM.desktop
echo -e "$steam" > ~/.config/autostart/steam.desktop
echo -e "$spotify" > ~/.config/autostart/spotify.desktop
echo -e "$nvidia" > ~/.config/autostart/'NVIDIA X Server Settings.desktop'

update-desktop-database ~/.local/share/applications

# Make some notes
echo "Taskbar icons: <WebBrowser> Steam Spotify Discord Bitwarden Dolphin SystemSettings SystemMonitor Konsole" > Note
echo "Desktop: <WebBroser> Steam Discord Dolphin VirtualBox" >> Note
echo "Put night color to 4500" >> Note

echo "Finished!"

while true; do
    read -p "do you wanna reboot now? [Y/n]" choice
    choice=${choice^^}

    if [[ "$choice" == "Y" ]]; then
        reboot
    elif [[ "$choice" == "N" ]]; then
        echo "Ok."
        break
    else
        echo "Invalid choice. Please enter 'Y' or 'n'."
    fi
done
