#!/usr/bin/env bash



# Install apps and binaries with apt


# TODO(tim): finish the list of apps to install



function update_and_upgrade() {
  sudo apt-get update -y && sudo apt-get upgrade -y
}









LOG_FILE="linux_server_setup.log"
sudo cat /dev/null > $LOG_FILE

echo -e 'Updating system...'
if [[ "$RELEASE" == "centos" ]]; then
  yum -y -q update
  . yum_install.sh
else
  update_and_upgrade
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
#apt_install python-pip # E: Package 'python-pip' has no installation candidate
apt_install python3-pip

apt_install screen
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

update_and_upgrade
apt_install neovim 

apt_install colordiff
# Install gdrive: https://linuxhint.com/google_drive_installation_ubuntu/




# IP lookup command line tools that use the GeoIP library (ex. get ip location)
apt_install geoip-bin

apt_install command-not-found

apt_install cargo # rust package manager (required to install viu)

# Awsome image viewer from terminal
# https://github.com/atanunq/viu
# Other such tools: https://askubuntu.com/questions/97542/how-do-i-make-my-terminal-display-graphical-pictures
cargo install viu 










# Make symlinks
. $PWD/make_symlinks.sh

##### Install .zsh, .vim

# Copy dotdirs to user_to_setup_for_home_directory
cp -R $PWD/dotdirs/.zsh $PWD/dotdirs/.vim $user_to_setup_for_home_directory/ && {
  # Copy custom zsh per machine
  cp $PWD/linux/server/.zshrc_linux_server $user_to_setup_for_home_directory/.zsh/.zshrc
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


