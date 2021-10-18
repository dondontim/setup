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

# echo "Copy and paste below command on your local machine"
# echo "This will create your ssh private and public key and copy to clipboard the public key:"
# echo ""
# echo "ssh-keygen && cat ~/.ssh/id_rsa.pub | tr -d '\n' | pbcopy && echo '\n--> Copied to clipboard'"
# # TODO(tim): make check for OS and their copy command
# echo ""
# echo "If you execute above command then copy and paste it here using CTRL + V and press Enter"
# 
# read public_key_string
# 
# # Create dir if not exists
# [ -d "${new_user_home}/.ssh" ] || mkdir -p "${new_user_home}/.ssh"
# 
# # Push the passed ssh public key to authorized
# echo "$public_key_string" >> "${new_user_home}/.ssh/authorized_keys"
# 
# # Set appropriate permissions
# #
# # It’s important that the ~/.ssh directory belongs to the user and not to root:
# chown -R "$user_to_create":"$user_to_create" "${new_user_home}/.ssh"
# #chmod -R go= ~/.ssh # This recursively removes all “group” and “other” permissions for the ~/.ssh/ directory.



remote_machine_public_ip=$(curl https://ipecho.net/plain; echo)


echo ""
echo "Run:"
# TODO(tim): check in /etc/ssh/sshd_config for port number
echo "ssh-keygen && ssh-copy-id ${user_to_create}@${remote_machine_public_ip} -p 7822"


echo "press enter if you are good"
read tmp_enter_to_continue

# TODO(tim): add here check if the ~/.ssh/authorized_keys exist








sshd_config='/etc/ssh/sshd_config'

echo "--> Copying ${sshd_config} to ${sshd_config}.bak"
sudo cp "${sshd_config}" "${sshd_config}.bak"
echo "--> Done"


echo "--> Disabling Password Authentication"

echo "PasswordAuthentication no" >> "$sshd_config"
echo "PermitEmptyPasswords no"   >> "$sshd_config"
echo "PermitRootLogin no"        >> "$sshd_config" # PermitRootLogin without-password


# Use more cryptographicaly secure protocol
#echo "Protocol 2" >> "$sshd_config"
# To test if SSH protocol 1 is supported any more, run the command:
# ssh -1 user@remote-IP
#
# ssh -2 user@remote-IP # for Protocol 2


# Set SSH Connection Timeout Idle Value
#echo "ClientAliveInterval 600" >> "$sshd_config"

# Total number of checkalive message sent by the ssh server 
# without getting any response from the ssh client
#echo "ClientAliveCountMax 0" >> "$sshd_config"

# Limit SSH Access to Certain Users
#echo "AllowUsers ${user_to_create}" >> "$sshd_config" # after space add other users
# AllowGroups sysadmin dba

# Configure a Limit for Password Attempts
#echo "MaxAuthTries 3" >> "$sshd_config"

# Allow 20 sec to login, if not disconnect
#echo "LoginGraceTime 20" >> "$sshd_config"

# Set non default port
#echo "Port 7822" >> "$sshd_config"


# TODO(tim): More about hardening sshd_config:
# https://www.digitalocean.com/community/tutorials/how-to-harden-openssh-on-ubuntu-18-04







# Restart ssh
echo ""
echo "--> Restarting ssh"
sudo systemctl restart ssh # sshd on other distros than debian/ubuntu



#remote_machine_public_ip=$(curl https://ipecho.net/plain; echo)
#echo ""
#echo "Run below command on local machine to setup SSH keys and upload them here"
#echo "After this creat passphrase and pass passowrd for the user you created"
#echo ""
#echo "ssh-keygen && ssh-copy-id ${user_to_create}@${remote_machine_public_ip} -p 7822"



#echo ""
#echo "--> Finished!"
#echo "Now you should logout and connect again now using SSH keys"

























echo ""
echo "Authenticating to Your Ubuntu Server Using SSH Keys"
echo "Now you should logout and connect again now using SSH keys"
echo "Finished!"





################################################################################
################################################################################
################################################################################
################################################################################
################################################################################