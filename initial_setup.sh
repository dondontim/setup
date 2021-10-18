#!/bin/bash
#
# Create new (sudo) user, setup firewall, manage SSH keys

# Initial commands

# Updates, upgrades the packages, removes unused packages, then removes old versions of packages.
# apt-get update && apt-get upgrade -y && apt-get autoremove && apt-get autoclean
# apt-get install -y git curl
# git clone https://github.com/dondontim/setup.git && cd setup


# apt update -y && apt upgrade -y && apt install -y git curl
# OR BELOW
# noninteractive \
#   apt-get \
#   -o Dpkg::Options::=--force-confold \
#   -o Dpkg::Options::=--force-confdef \
#   -y --allow-downgrades --allow-remove-essential --allow-change-held-packages




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


function press_anything_to_continue() {
  read -n 1 -s -r -p "Press any key to continue"
  # -n defines the required character count to stop reading
  # -s hides the user's input
  # -r causes the string to be interpreted "raw" (without considering backslash escapes)
}


function apt_install() {
  sudo apt-get install -y "$@"
}

function update_and_upgrade() {
  sudo apt-get update -y && sudo apt-get upgrade -y
}

function ufw_allow() {
  sudo ufw allow "$@"
}




init() {
  # check release
  if [ -f /etc/redhat-release ]; then
      RELEASE="centos"
  elif cat /etc/issue | grep -Eqi "debian"; then
      RELEASE="debian"
  elif cat /etc/issue | grep -Eqi "ubuntu"; then
      RELEASE="ubuntu"
  elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
      RELEASE="centos"
  elif cat /proc/version | grep -Eqi "debian"; then
      RELEASE="debian"
  elif cat /proc/version | grep -Eqi "ubuntu"; then
      RELEASE="ubuntu"
  elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
      RELEASE="centos"
  fi
}

init


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
echo "--> Finished!"
echo "Authenticating to Your Ubuntu Server Using SSH Keys"
echo "Now you should logout and connect again now using SSH keys"


echo ""
echo "Now will begin LEMP stack installation"
echo ""
press_anything_to_continue




################################################################################
################################################################################
################################################################################
################################################################################
################################################################################






################################################################################
# Install Linux, Nginx, MySQL, PHP (LEMP stack)                                #
################################################################################
# https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mysql-php-lemp-stack-on-ubuntu-20-04


file_templates_dir="${PWD}/z_file_templates"

update_and_upgrade


### Stop, remove apache2 and all dependencies
# TODO(tim): check if apache2 is present
if [[ "$RELEASE" == "centos" ]]; then
  # On RHEL/CentOS/Oracle/Fedora Linux.
  systemctl disable httpd && systemctl stop httpd

  # Remove the installed httpd packages
  yum remove "httpd*" -y
  # Remove the Document root directory
  #rm -rf /var/www
  # Remove the Configuration Files
  rm -rf /etc/httpd
  # Remove the Supporing files and httpd modules
  rm -rf /usr/lib64/httpd
  # delete the Apache user
  userdel -r apache
else
  # On Debian/Ubuntu
  systemctl disable apache2 && systemctl stop apache2

  apt-get purge -y apache2 apache2-utils 
  
  apt-get purge -y apache2-bin apache2.2-bin
  apt-get purge -y apache2-common apache2.2-common

  # Get rid of other dependencies of unexisting packages
  apt-get autoremove

  # Remove the Configuration Files
  rm -rf /etc/apache2 
  # Remove the Supporing files and httpd modules # /usr/lib/apache2/modules
  rm -rf /usr/lib/apache2

fi




# Installing the Nginx Web Server
apt_install nginx

ufw_allow 'Nginx Full'
ufw_allow 'Nginx HTTP'
ufw_allow 'Nginx HTTPS'



# Installing MySQL
apt_install mysql-server





echo ""
echo "Running 'mysql_secure_installation'"
echo ""
echo "This will ask if you want to configure the VALIDATE PASSWORD PLUGIN."
echo "choose No"
echo "Next select and confirm a password for the MySQL root user."
mysql_secure_installation

# TODO(tim): create a dedicated user for databases





# Installing PHP

# While Apache embeds the PHP interpreter in each request, 
# Nginx requires an external program to handle PHP processing and act
# as a bridge between the PHP interpreter itself and the web server. 
# This allows for a better overall performance in most PHP-based websites, 
# but it requires additional configuration. 
#
# You’ll need to install php-fpm, which stands for “PHP fastCGI process manager”,
# and tell Nginx to pass PHP requests to this software for processing. 
# Additionally, you’ll need php-mysql, a PHP module that allows PHP
# to communicate with MySQL-based databases

apt_install php-fpm php-mysql


# Get the domain name to create a directory structure
echo ""
echo "Type your domain name, without http(s) scheme:"
read domain_name


# Instead of modifying /var/www/html, we’ll create a directory structure 
# within /var/www for the 'your_domain' website, leaving /var/www/html in place 
# as the default directory to be served if a client request doesn’t match any other sites.
#
# It is better and easier to manage multiple domains on one server that way

domain_root_dir="/var/www/${domain_name}"

# Create the root web directory for 'your_domain' if not exists:
[ -d "$domain_root_dir" ] || mkdir "$domain_root_dir"


# Next, assign ownership of the directory with the $USER environment variable,
# which will reference your current system user:
#echo "$ USER = $USER"
#echo "Type username which have to be owner to ${domain_root_dir}"
#read username

username="$user_to_create"

chown -R $username:$username "$domain_root_dir"



# Copy already created example nginx configuration to /etc/nginx/sites-available/your_domain
cp "${file_templates_dir}/nginx_your_domain" "/etc/nginx/sites-available/${domain_name}"

# Replace in above file 'your_domain' to passed $domain_name
sed -i "s/your_domain/${domain_name}/" "/etc/nginx/sites-available/${domain_name}"
# -i option is used to modify the content of the original file.
#  s indicates the substitute command.


# Activate your configuration by linking to the config file from Nginx’s sites-enabled directory:
ln -s "/etc/nginx/sites-available/${domain_name}" /etc/nginx/sites-enabled/

# Then, unlink the default configuration file from the /sites-enabled/ directory:
unlink /etc/nginx/sites-enabled/default

# Note: If you ever need to restore the default configuration, 
# you can do so by recreating the symbolic link, like this:
#   sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/
echo "Testing configuration for syntax errors..."
nginx -t


# If everything is correct reload Nginx
systemctl reload nginx




# Create new MySQL user
echo ""
echo "--> Creating new mysql user"
echo ""

read -p "Username: " db_username

echo ""

while true; do
  read -s -p "Password: " db_password
  echo
  read -s -p "Password (again): " db_password2
  echo
  [ "$db_password" = "$db_password2" ] && break
  echo "Please try again"
done



# TODO(tim): think of copying "${file_templates_dir}/test_mysql_php_connection.sql"
cp "${file_templates_dir}/test_mysql_php_connection.sql" "${domain_root_dir}/test_mysql_php_connection.sql"


# Replace username
sed -i "s/example_user/${db_username}/" "${domain_root_dir}/test_mysql_php_connection.sql"
# Replace password
sed -i "s/example_password/${db_password}/" "${domain_root_dir}/test_mysql_php_connection.sql"

# Create a user and test database
mysql -u root < "${domain_root_dir}/test_mysql_php_connection.sql"

# To manually log in to mysql new user and check the records
#
# mysql -u example_user -p
# SHOW DATABASES;
# SELECT * FROM example_database.todo_list;



rm "${domain_root_dir}/test_mysql_php_connection.sql"





################################################################################
# Tests
################################################################################



# Testing HTML with Nginx
echo "--> Testing HTML with Nginx"
# Copy an index.html template to test
cp "${file_templates_dir}/index.html" "${domain_root_dir}/index.html"


echo "--> Done"
echo "Now visit: http://${domain_name}"
press_anything_to_continue
echo "Removing ${domain_root_dir}/index.html"
rm "${domain_root_dir}/index.html"




# Testing PHP with Nginx
echo "--> Testing PHP with Nginx"
printf "<?php\nphpinfo();" > "${domain_root_dir}/info.php"


echo "--> Done"
echo "Now visit: http://${domain_name}/info.php"
press_anything_to_continue
echo "Removing ${domain_root_dir}/info.php"
rm "${domain_root_dir}/info.php"




# Testing Database Connection from PHP
echo "--> Testing Database Connection from PHP"


# Copy todo_list.php
cp "${file_templates_dir}/todo_list.php" "${domain_root_dir}/todo_list.php"

# Replace username
sed -i "s/example_user/${db_username}/" "${domain_root_dir}/todo_list.php"
# Replace password
sed -i "s/example_password/${db_password}/" "${domain_root_dir}/todo_list.php"



echo "--> Done"
echo "Now visit: http://${domain_name}/todo_list.php"

cat << EOF

And if you see this:

TODO

  1. My 1st important item
  2. My 2nd important item
  3. My 3rd important item
  4. and this one more thing


That means your PHP environment is ready to connect and interact with your MySQL server.

EOF


press_anything_to_continue
echo "Removing ${domain_root_dir}/todo_list.php"
rm "${domain_root_dir}/todo_list.php"






# To list all MySQL users
# SELECT User,Host FROM mysql.user;


# List grants for a mysql user
# SHOW GRANTS FOR 'bloguser'@'localhost';


#DROP USER 'bloguser'@'localhost';