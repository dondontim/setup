#!/bin/bash
#
# Create new (sudo) user, setup firewall, manage SSH keys

# Initial commands
# apt update -y && apt upgrade -y && apt install -y git curl
# git clone https://github.com/dondontim/setup.git && cd setup


# This need to be run as root!
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi


function command_exists() {
  command -v "$@" >/dev/null 2>&1
}

function install_nonexisting_command() {
  if command_exists "$1"; then
    echo "$1 exists"
  else
    sudo apt-get install -y "$1"
  fi
}


################################################################################
# Initial Server Setup                                                         #
################################################################################
# https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-20-04  


echo "--> Creating New User"
echo "Type username you want to create:"
echo "or press CTRL + C to quit"
echo -n ">>>"
read user_to_create

# set new user home path variable
new_user_home="/home/${user_to_create}"

# Create a new user
adduser "$user_to_create"
# Granting Administrative Privileges
usermod -aG sudo "$user_to_create"
echo "--> Done"




################################################################################
# Setting Up a Basic Firewall                                                  #
################################################################################
# https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-with-ufw-on-ubuntu-20-04

echo "--> Setting Up a Basic Firewall"
install_nonexisting_command ufw

# Set the Default Policies
ufw default deny incoming
ufw default allow outgoing
# Allowing SSH Connections
ufw allow OpenSSH

ufw allow 22

ufw allow 7822 # custom port for ssh and sftp

# Allowing HTTP 
ufw allow 80 # http

ufw allow 443 # https

# Allowing file transfer
ufw allow 21 # ftp

# As SFTP runs as a subsystem of SSH it runs on whatever port 
# the SSH daemon is listening on and that is administrator configurable.

# To debug
# ufw status numbered 

# Enable ufw
ufw enable
echo "--> Done"


################################################################################
# Set up SSH keys                                                              #
################################################################################
# https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys-on-ubuntu-20-04#step-3-—-authenticating-to-your-ubuntu-server-using-ssh-keys


# before changing here to be able to run ssh-copy-id you need to have 
# PasswordAuthentication enabled. So ask user here to create his SSH keys and
# run ssh-copy-id someuser@<my-ip> or copy paste here

echo "Copy and paste below command on your local machine"
echo "This will create your ssh private and public key and copy to clipboard the public key:"
echo "ssh-keygen && cat ~/.ssh/id_rsa.pub | pbcopy && echo 'Copied to clipboard'"
echo ""
echo "If you execute above command then copy and paste it here using CTRL + V and press Enter"

read public_key_string

# Create dir if not exists
[ -d "${new_user_home}/.ssh" ] || mkdir -p "${new_user_home}/.ssh"

# Push the passed ssh public key to authorized
echo "$public_key_string" >> "${new_user_home}/.ssh/authorized_keys"

# Set appropriate permissions
#
# It’s important that the ~/.ssh directory belongs to the user and not to root:
chown -R "$user_to_create":"$user_to_create" "${new_user_home}/.ssh"
#chmod -R go= ~/.ssh # This recursively removes all “group” and “other” permissions for the ~/.ssh/ directory.



echo ""
echo "logout and login once again with ssh key"
echo "Finished!"