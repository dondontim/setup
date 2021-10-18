#!/usr/bin/env bash



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


apt_install curl
apt_install highlight
apt_install xclip
apt_install vim
apt_install htop
apt_install nodejs 
apt_install npm && {
  # If npm will not throw errors delete below line
  sudo chmod -R a+rw /usr/local/lib # Add read and write permissions for all users
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




# Enable neovim repository
sudo add-apt-repository ppa:neovim-ppa/unstable

sudo apt update
apt_install neovim 

apt_install colordiff
# Install gdrive: https://linuxhint.com/google_drive_installation_ubuntu/



















# Make symlinks
. $PWD/make_symlinks.sh

##### Install .zsh, .vim

# Copy dotdirs to $HOME
cp -R $PWD/dotdirs/.zsh $PWD/dotdirs/.vim $HOME/ && {
  # Copy custom zsh per machine
  cp $PWD/linux/server/.zshrc_linux_server $HOME/.zsh/.zshrc
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


