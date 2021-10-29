#!/usr/bin/env bash


# https://www.makeuseof.com/best-productivity-apps-for-linux/


# Install apps and binaries with apt


# TODO(tim): finish the list of apps to install






# Disable welcome message - https://askubuntu.com/a/676381 
if [ -d "etc/update-motd.d" ]; then 
  sudo chmod -x /etc/update-motd.d/* 
fi;





LOG_FILE="linux_server_setup.log"
sudo cat /dev/null > $LOG_FILE

echo -e 'Updating system...'
if [[ "$RELEASE" == "centos" ]]; then
  yum -y -q update
  . yum_install.sh
else
  # q quiet
  sudo apt-get update -y -qq && apt-get upgrade -y -qq
  #. apt_install.sh
fi

function apt_install() {
  sudo apt-get install -y "$1" >> $LOG_FILE && {
    echo "[+] $1"
  } || {
    echo "[!] $1"
  }
}




apt_install zsh

# Switch to zsh as default shell
chsh -s "$(which zsh)"

# Command to unzip an archive (COMMENTED CUZ WE HAVE EXTRACT FUNCTION)
#apt_install unzip # Example: unzip file.zip -d destination_folder
apt_install p7zip-full
apt_install tree
apt_install python
apt_install python3
apt_install python-pip
apt_install python3-pip

apt_install screen
apt_install curl
apt_install highlight
apt_install xclip
apt_install vim
apt_install htop
apt_install nodejs 
apt_install npm && {
  # Install fx
  sudo npm install -g fx
  echo "[+] npm fx"
} || { 
  echo "[!] npm fx"
}


# Midnight Commander ( lightwaight (config) file manager ) 
# check_existance_and_install mc

# Donwload standalone fx (json viewer) binary for linux
#wget https://github.com/antonmedv/fx/releases/download/20.0.2/fx-linux.zip




# Dependencies for vscode
sudo apt-get install software-properties-common apt-transport-https wget
# import the Microsoft GPG key
wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
# Enable visualstudio code repository
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"

# Enable neovim repository
sudo add-apt-repository ppa:neovim-ppa/unstable


# Install VScode
sudo apt-get update
apt_install code #vscode
apt_install neovim 

apt_install colordiff
# Install gdrive: https://linuxhint.com/google_drive_installation_ubuntu/


apt_install ffmpeg
apt_install youtube-dl






# Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb

# Tor Browser
sudo add-apt-repository ppa:micahflee/ppa
apt-get update 
apt_install torbrowser-launcher
# You can run tor browser via: $ torbrowser-launcher

# MS Teams
wget –O teams.deb https://packages.microsoft.com/repos/ms-teams/pool/main/t/teams/teams_1.3.00.5153_amd64.deb
apt_install ./teams.deb

# Brave Browser, Burp-Suite, Zoom
# Only via GUI






# IP lookup command line tools that use the GeoIP library (ex. get ip location)
apt_install geoip-bin

apt_install command-not-found

apt_install cargo # rust package manager (required to install viu)

# Awsome image viewer from terminal
# https://github.com/atanunq/viu
# Other such tools: https://askubuntu.com/questions/97542/how-do-i-make-my-terminal-display-graphical-pictures
cargo install viu 


apt_install ack # grep-like text finder
apt_install gawk










############################ DESKTOP ###########################################

### Command-line translator
# Ref: https://github.com/soimort/translate-shell
# Download the self-contained executable and place it into your path.
mkdir -p ~/bin
wget git.io/trans && chmod +x ./trans && mv ./trans ~/bin

# FTP Client and talk other protocols
apt_install lftp





# Make symlinks
. $PWD/make_symlinks.sh


##### Install .zsh, .vim

# Copy dotdirs to $HOME
cp -R $PWD/dotdirs/.zsh $PWD/dotdirs/.vim $user_to_setup_for_home_directory/ && {
  # Copy custom zsh per machine
  cp $PWD/linux/desktop/.zshrc_linux_desktop $user_to_setup_for_home_directory/.zsh/.zshrc
} || {
  echo "problem with dotdirs copying"
}

# Install Vundle
# $ git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
#
# Install Plugins:
# * Launch vim and run :PluginInstall
# * To install from command line: 
# $ vim +PluginInstall +qall



# TODO(tim): Import vscode settings and stuff