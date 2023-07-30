#!/bin/bash

# Check if the script is being run with sudo
if [ "$(id -u)" = "0" ]; then
    echo "Please do not use sudo to run this script. Run it as a regular user."
    exit 1
fi

# Prompt the user to enter their password for sudo access
read -p "Type your password for sudo: " password
DesktopEnvs=("xfce4" "lxde" "gnome" "kde" "plasma" "cinnamon" "mate" "deepin" "xfce4-goodies")
# Ask the user if they want to remove their desktop environment
read -p "Do you want to remove your current desktop environment if you have one? [Y/n]: " choice
choice=${choice^^}

if [[ "$choice" == "N" ]]; then
    continue
elif [[ "$choice" == "Y" ]]; then
    for pkg in "${DesktopEnvs[@]}"; do
        sudo pacman -Rsn "$pkg" --noconfirm > /dev/null 2>&1
    echo "Other desktop environments have been removed."
else
    echo "Invalid choice. Please enter 'Y' or 'n'."
fi





# Get the current username
User=$(whoami)

# Enable [multilib] repository in /etc/pacman.conf
echo "$password" | sudo -S sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
echo "Enabled [multilib] repository in /etc/pacman.conf"

# Download BlackArch Linux bootstrap script and set permissions
curl -O https://blackarch.org/strap.sh
chmod +x strap.sh
echo "Downloaded BlackArch Linux bootstrap script and set permissions"

# Run the BlackArch bootstrap script with sudo access
echo "$password" | sudo -S ./strap.sh > /dev/null 2>&1
echo "Executed BlackArch bootstrap script"

# Remove the bootstrap script after it's been executed
rm strap.sh
echo "Removed BlackArch bootstrap script"

# Update and install packages from official repositories
echo "Updating and installing some packages"
echo "$password" | sudo -S pacman -Syyu --noconfirm > /dev/null 2>&1
echo "$password" | sudo -S pacman -S git firefox sddm base noto-fonts-emoji gnu-netcat virtualbox i3-wm i3status i3lock dmenu virtualbox-guest-utils sqlitebrowser vlc base-devel fontconfig ttf-droid shotwell dolphin binutils linux-headers whois zsh gcc enum4linux make p7zip zsh-completions zsh-syntax-highlighting openvpn nmap freerdp wireshark-qt aircrack-ng wget gdb vim man sqlmap python2 nikto nfs-utils ruby-irb terminator gobuster binwalk steghide perl-image-exiftool inetutils curlftpfs burpsuite john exploitdb metasploit ffuf hydra hashcat python-pip python2-pip hashid net-tools --noconfirm > /dev/null 2>&1
echo "Updated and installed packages from official repositories"

sudo pacman -Rsn lightdm --noconfirm > /dev/null 2>&1

# Enable and start SDDM
sudo systemctl enable sddm

# Clear font cache
fc-cache
echo "Cleared font cache"

# Clone yay AUR helper from Arch User Repository and install it
cd /opt
echo "$password" | sudo -S git clone https://aur.archlinux.org/yay-git.git > /dev/null 2>&1
echo "$password" | sudo -S chown -R $User:$User ./yay-git
cd /opt/yay-git
yes | makepkg -si > /dev/null 2>&1
yay -S --noconfirm zsh-theme-powerlevel10k-git sublime-text-4 sddm-slice-git libunity > /dev/null 2>&1
echo "Cloned yay AUR helper and installed some packages from AUR"

# Set SDDM theme to 'slice'
if [ -f /etc/sddm.conf ]; then
    sudo sed -i "/^\[Theme\]/,/^\[/ s/^Current=.*/Current=slice/" /etc/sddm.conf
else
    echo -e "[Theme]\nCurrent=slice" | sudo tee /etc/sddm.conf > /dev/null 2>&1
fi
echo "Set SDDM theme to 'slice'."

# Check if ~/.xinitrc already exists
if [ -e ~/.xinitrc ]; then
    # If it exists, make a backup with the current timestamp
    mv ~/.xinitrc ~/.xinitrc.backup.$(date +%Y%m%d%H%M%S)
    echo "Existing ~/.xinitrc backed up to ~/.xinitrc.backup.$(date +%Y%m%d%H%M%S)"
fi

echo "exec i3" > ~/.xinitrc
echo "i3 has been set as the default window manager in ~/.xinitrc"

# Allow write permissions to certain Python directories
echo "$password" | sudo -S chmod 777 /usr/lib/python*/site-packages
echo "Granted write permissions to Python site-packages directory"

# Clone a GitHub repository containing some custom configurations
cd ~
git clone --recurse-submodules https://github.com/haya123421321/Arch.git > /dev/null 2>&1
echo "Cloned custom configurations from GitHub repository"

# Copy the custom Zsh configuration and powerlevel10k theme to the user's home directory
echo "$password" | sudo -S cat Arch/configs/zshrc > ~/.zshrc
echo "$password" | sudo -S cat Arch/configs/p10k.zsh > ~/.p10k.zsh
echo "Copied custom Zsh configuration and powerlevel10k theme"

# Create the necessary directory for font configuration and copy the font configuration file
mkdir -p ~/.config/fontconfig/conf.d
cat Arch/configs/1-fonts.conf > ~/.config/fontconfig/conf.d/1-fonts.conf
echo "Created font configuration directory and copied font configuration file"

# Copy other custom configurations to their respective directories
echo "$password" | sudo -S cp -r Arch/Tepz .
mkdir -p .config/terminator
mkdir -p .config/sublime-text/Packages/User
echo "$password" | sudo -S mv Arch/KaliLists Arch/wordlists
echo "$password" | sudo -S mv Arch/SecLists Arch/wordlists
gunzip Arch/wordlists/rockyou.txt.gz
rm Arch/wordlists/README.md Arch/wordlists/dnsmap.txt Arch/wordlists/sqlmap.txt
mv Arch/Command-injection-bypass Arch/wordlists/SecLists/Payloads
sudo mv Arch/wordlists /usr/share/
echo "Moved custom configurations to their respective locations"

# Copy configuration files for Terminator and Sublime Text
cat Arch/configs/Terminator_config.txt > .config/terminator/config
cat Arch/configs/Keybinds.txt > '.config/sublime-text/Packages/User/Default (Linux).sublime-keymap'
cat Arch/configs/Settings.txt > .config/sublime-text/Packages/User/Preferences.sublime-settings
echo "Copied configuration files for Terminator and Sublime Text"

# Change the default shell to Zsh for the current user
echo 'change shell to zsh'
printf "$password\n/bin/zsh" | chsh > /dev/null 2>&1
echo "Changed default shell to Zsh"

# Remove the cloned GitHub repository
echo "$password" | sudo -S rm -R Arch
echo "Removed cloned GitHub repository"

# Create some text files with specific content
echo "Taskbar icons: Firefox Dolphin SystemSettings SystemMonitor" > TaskbarIcons
echo "Get Bitwarden, FoxyProxy and Hackbar" > Firefox_extension

# Display a message indicating the completion of the script
echo "Finished!"

# Prompt the user if they want to reboot the system
read -p "Do you want to reboot now? [Y/n]" choice
choice=${choice^^}

# If the user chooses 'Y', reboot the system; if 'N', print "Ok."; otherwise, show an error message
if [[ "$choice" == "Y" ]]; then
    echo "Rebooting..."
    reboot
elif [[ "$choice" == "N" ]]; then
    echo "Ok."
else
    echo "Invalid choice. Please enter 'Y' or 'n'."
fi
