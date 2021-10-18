#!/bin/bash
#
# Create new (sudo) user, setup firewall, manage SSH keys

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
echo "1-------------------"
ufw allow 22
echo "2-------------------"
ufw allow 7822 # custom port for ssh and sftp
echo "3-------------------"
# Allowing HTTP 
ufw allow 80 # http
echo "4-------------------"
ufw allow 443 # https
echo "5-------------------"
# Allowing file transfer
ufw allow 21 # ftp
echo "6-------------------"
ufw allow 22 # sftp
echo "7-------------------"

# To debug
# ufw status numbered 

# Enable ufw
ufw enable
echo "--> Done"


################################################################################
# Set up SSH keys                                                              #
################################################################################
# https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys-on-ubuntu-20-04#step-3-—-authenticating-to-your-ubuntu-server-using-ssh-keys

sshd_config='/etc/ssh/sshd_config'

echo "--> Copying ${sshd_config} to ${sshd_config}.bak"
cp "${sshd_config}" "${sshd_config}.bak"
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



remote_machine_public_ip=$(curl https://ipecho.net/plain; echo)
echo ""
echo "Run below command on local machine to setup SSH keys and upload them here"
echo "After this creat passphrase and pass passowrd for the user you created"
echo ""
echo "ssh-keygen && ssh-copy-id ${user_to_create}@${remote_machine_public_ip} -p 7822"



echo ""
echo "--> Finished!"
echo "Now you should logout and connect again now using SSH keys"


