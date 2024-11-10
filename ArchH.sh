#!/bin/bash

# Check if the script is being run with sudo
if [ "$(id -u)" = "0" ]; then
    echo "Please do not use sudo to run this script. Run it as a regular user."
    exit 1
fi

# Prompt the user to enter their password for sudo access
read -p "Type your password for sudo: " password

# Get the current username
User=$(whoami)

# Enable [multilib] repository in /etc/pacman.conf
echo "$password" | sudo -S sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf 
echo "Enabled [multilib] repository in /etc/pacman.conf"

echo "Updating the system"
echo "$password" | sudo -S pacman -Syyu --noconfirm  

# Download BlackArch Linux bootstrap script and set permissions
curl -O https://blackarch.org/strap.sh  
chmod +x strap.sh
echo "Downloaded BlackArch Linux bootstrap script and set permissions"

# Run the BlackArch bootstrap script with sudo access
yes | sudo ./strap.sh  
echo "Executed BlackArch bootstrap script"

# Remove the bootstrap script after it's been executed
rm strap.sh
echo "Removed BlackArch bootstrap script"

echo "$password" | sudo -S pacman -S git alacritty xclip rofi adobe-source-code-pro-fonts noto-fonts-emoji ttf-hack neovim tmux firefox sddm base noto-fonts-emoji python-pipx mlocate spike-fuzzer wpscan gnu-netcat cewl crunch ttf-dejavu sqlitebrowser vlc base-devel fontconfig shotwell dolphin binutils linux-headers whois zsh gcc enum4linux make p7zip zsh-completions zsh-syntax-highlighting openvpn nmap freerdp wireshark-qt aircrack-ng wget gdb vim man sqlmap python2 nikto nfs-utils ruby-irb terminator gobuster binwalk steghide perl-image-exiftool inetutils curlftpfs burpsuite john exploitdb metasploit ffuf hydra hashcat python-pip python2-pip hashid net-tools --noconfirm  
echo "Updated and installed packages from official repositories"

echo "$password" | sudo -S pacman -Rsn lightdm --noconfirm  

# Enable and start SDDM
echo "$password" | sudo -S systemctl enable sddm

# Check if the system is a VM and enable guest
if [ $(sudo dmidecode | grep -m 1 "Product Name" | cut -d ":" -f 2 | tr -d " ") == "VirtualBox" ]
then
    echo "$password" | sudo -S pacman -S virtualbox-guest-utils --noconfirm
    echo "$password" | sudo -S systemctl enable vboxservice
else
	echo "Not a VM"
fi

# Clear font cache
fc-cache
echo "Cleared font cache"

# Clone yay AUR helper from Arch User Repository and install it
echo "Installing yay"
cd /opt
echo "$password" | sudo -S git clone https://aur.archlinux.org/yay-git.git  
echo "$password" | sudo -S chown -R $User:$User ./yay-git
cd /opt/yay-git
yes | makepkg -si  
echo "$password" | sudo -S rm -R /opt/yay-git

# Install AUR packages using yay
echo "$password" | yay -S --noconfirm zsh-theme-powerlevel10k-git sublime-text-4 sddm-slice-git libunity konsave
echo "Cloned yay AUR helper and installed some packages from AUR"

# Set SDDM theme to 'slice'
if [ -f /etc/sddm.conf ]; then
    sudo sed -i "/^\[Theme\]/,/^\[/ s/^Current=.*/Current=slice/" /etc/sddm.conf
else
    echo -e "[Theme]\nCurrent=slice" | sudo tee /etc/sddm.conf  
fi
echo "Set SDDM theme to 'slice'."

# Allow write permissions to certain Python directories
echo "$password" | sudo -S chmod 777 /usr/lib/python*/site-packages
echo "Granted write permissions to Python site-packages directory"

# Clone a GitHub repository containing some custom configurations
echo "Cloning Github repository"
cd ~
if [ -d Arch ]; then
  echo "Git Directory exists."
else
    git clone --recurse-submodules https://github.com/haya123421321/Arch.git
    echo "Cloned custom configurations from GitHub repository"
fi

if [ -d .dotfiles ]; then
  echo "Git Directory exists."
else
    clone git@github.com:haya123421321/.dotfiles.git
fi

# Copy the dotfiles
cat .dotfiles/.zshrc > ~/.zshrc
cat .dotfiles/.p10k.zsh > ~/.p10k.zsh
cat .dotfiles/.tmux.conf ~/.tmux.conf
cp -rf .dotfiles/config/. .config/
rm -rf .dotfiles
echo "Copied custom Zsh configuration and powerlevel10k theme"

# Sublime
mkdir -p ~/.config/sublime-text/Packages/User
cat Arch/configs/Default (Linux).sublime-keymap > '.config/sublime-text/Packages/User/Default (Linux).sublime-keymap'
cat Arch/configs/Preferences.sublime-settings > '.config/sublime-text/Packages/User/Preferences.sublime-settings'
echo "Copied configuration files for Sublime Text"

# Copy other custom scripts and wordlists
echo "$password" | sudo -S cp -r Arch/Tepz .
echo "$password" | sudo -S mv Arch/KaliLists Arch/wordlists
echo "$password" | sudo -S mv Arch/SecLists Arch/wordlists
gunzip Arch/wordlists/rockyou.txt.gz
rm Arch/wordlists/README.md Arch/wordlists/dnsmap.txt Arch/wordlists/sqlmap.txt
mv Arch/Command-injection-bypass Arch/wordlists/SecLists/Payloads
sudo mv Arch/wordlists /usr/share/
echo "Moved custom configurations to their respective locations"

cp Arch/configs/Wallpaper.jpeg ~/Pictures/

for file in $(ls /opt/metasploit/tools/exploit/*.rb);do echo "$password" | sudo -S ln -sf $file /usr/bin/$(basename $file);done

# Change the default shell to Zsh for the current user
echo 'Changing shell to zsh'
printf "$password\n/bin/zsh" | chsh  
echo "Changed default shell to Zsh"

# Add wireshark group
echo "$password" | sudo -S usermod -a -G wireshark $User
echo "Added group 'wireshark' to user"

# Remove the cloned GitHub repository
echo "$password" | sudo -S rm -R Arch
echo "Removed cloned GitHub repository"

# Create a note for firefox extensions
echo "Get Bitwarden, FoxyProxy and Hacktools" > Firefox_extension

# Display a message indicating the completion of the script
echo "Finished!"

# Prompt the user if they want to reboot the system
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
