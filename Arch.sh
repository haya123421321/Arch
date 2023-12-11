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
echo "$password" | sudo -S pacman -S base noto-fonts-emoji gimp python-pipx python-pip mlocate virtualbox virtualbox-guest-utils wine sqlitebrowser spotify-launcher ttf-dejavu lutris vlc base-devel fontconfig shotwell steam discord bitwarden dolphin binutils linux-headers zsh gcc ntfs-3g git make zsh-autosuggestions zsh-completions zsh-syntax-highlighting vim --noconfirm 

# Update font cache
fc-cache

# Install yay AUR helper
cd /opt
echo "$password" | sudo -S git clone https://aur.archlinux.org/yay-git.git
echo "$password" | sudo -S chown -R $User:$User ./yay-git
cd /opt/yay-git
yes | makepkg -si > /dev/null 

# Install AUR packages using yay
echo "$password" | yay -S --noconfirm zsh-theme-powerlevel10k-git sublime-text-4 freedownloadmanager konsave libunity google-chrome dracula-kde-theme-git
pip install bs4 selenium requests pytube ffmpeg --break-system-packages 

# Clone configuration files from GitHub repository
cd ~
git clone https://github.com/haya123421321/Arch.git

# Copy configuration files to the appropriate locations
echo "$password" | sudo -S cat Arch/configs/zshrc > ~/.zshrc
echo "$password" | sudo -S cat Arch/configs/p10k.zsh > ~/.p10k.zsh
echo 'export PATH=$PATH:/usr/sbin:$(echo ~)/Scripts/Scripts' >> ~/.zshrc
mkdir -p ~/.config/sublime-text/Packages/User
cat Arch/configs/Keybinds.txt > '.config/sublime-text/Packages/User/Default (Linux).sublime-keymap'
cat Arch/configs/Settings.txt > .config/sublime-text/Packages/User/Preferences.sublime-settings
mkdir -p ~/.local/share/wallpapers/MnEGJu-Dracula-Wallpapers/ && cp Arch/configs/dracula-purplish.png ~/.local/share/wallpapers/MnEGJu-Dracula-Wallpapers/
mkdir -p ~/.config/konsave/profiles && cp -r Arch/configs/Main ~/.config/konsave/profiles/
plasma-apply-lookandfeel -a Dracula
plasma-apply-wallpaperimage ~/.local/share/wallpapers/MnEGJu-Dracula-Wallpapers/dracula-purplish.png
konsave -a Main

# Change default shell to Zsh
printf "$password\n/bin/zsh" | chsh

# Clean up cloned repository
echo "$password" | sudo -S rm -R Arch

# Get the Scripts folder
git clone https://github.com/haya123421321/Scripts
for file in $(ls ~/Scripts/Youtube/*.py);do ln -sf $file ~/Scripts/Scripts/$(basename $file);done
for file in $(ls ~/Scripts/MN/*);do ln -sf $file ~/Scripts/Scripts/$(basename $file);done

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

echo -e "$anichecker" > /tmp/anichecker_temp
sudo mv /tmp/anichecker_temp /etc/systemd/system/anichecker.service
echo "$password" | sudo -S systemctl enable anichecker 

echo -e "$discord" > ~/.config/autostart/discord.desktop
echo -e "$FDM" > ~/.config/autostart/FDM.desktop
echo -e "$steam" > ~/.config/autostart/steam.desktop
echo -e "$spotify" > ~/.config/autostart/spotify.desktop
echo -e "$nvidia" > ~/.config/autostart/'NVIDIA X Server Settings.desktop'

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
