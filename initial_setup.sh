#!/bin/bash
#
# Create new (sudo) user, setup firewall, manage SSH keys

# sudo apt-get update -y && sudo apt-get upgrade -y && apt-get install -y git curl && git clone https://github.com/dondontim/setup.git && cd setup

# DEBIAN_FRONTEND
# https://www.cyberciti.biz/faq/explain-debian_frontend-apt-get-variable-for-ubuntu-debian/

# apt-get HOW to skip any interactive post-install configuration steps?
export DEBIAN_FRONTEND=noninteractive
apt-get -yq install [packagename]

# You can also use one liner like this:
DEBIAN_FRONTEND=noninteractive apt-get -y update


# Updates, upgrades the packages, removes unused packages, then removes old versions of packages.
# apt-get update -y && apt-get upgrade -y && apt-get autoremove && apt-get autoclean

# apt update -y && apt upgrade -y && apt install -y git curl
# OR BELOW
# noninteractive \
#   apt-get \
#   -o Dpkg::Options::=--force-confold \
#   -o Dpkg::Options::=--force-confdef \
#   -y --allow-downgrades --allow-remove-essential --allow-change-held-packages


#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Initial commands
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
# sudo apt-get update -y && sudo apt-get upgrade -y && apt-get install -y git curl && git clone https://github.com/dondontim/setup.git && cd setup
# bash initial_setup.sh
#
# or
#
# sudo apt-get update -y && sudo apt-get upgrade -y && apt-get install -y git curl
# git clone https://github.com/dondontim/setup.git && cd setup
# bash initial_setup.sh





# TODO(tim): problem with not displaying questions
# This was caused by below:
# bash initial_setup.sh |& tee /root/initial_setup.log



# function get_password() {
#   while true; do
#     read -s -p "New password: " password
#     echo ""
#     read -s -p "Retype new password: " password2
#     echo ""
#     [ "$password" = "$password2" ] && break
#     echo "Please try again"
#   done
# }



# This need to be run as root!
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi

if ! [ "$PWD" = "/root/setup" ]; then
  echo "This script must be invoked from /root/setup"
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
  echo ""
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



# Tutoral on using below script
# https://www.digitalocean.com/community/tutorials/automating-initial-server-setup-with-ubuntu-18-04
#
# Digital Ocean automation script for initial_server_setup.sh
# https://github.com/do-community/automated-setups/blob/master/Ubuntu-18.04/initial_server_setup.sh

# If you have downloaded the script to your local computer, you can pass the script directly to SSH:
# * ssh root@servers_public_IP "bash -s" -- < /path/to/script/file


# Somebodys github nice Ubuntu Server Setup script
# https://github.com/jasonheecs/ubuntu-server-setup








# TODO(tim): collect all variables on the top of script
remote_machine_public_ip=$(curl -s https://ipecho.net/plain; echo)
sshd_config='/etc/ssh/sshd_config'
file_templates_dir="${PWD}/z_file_templates"


# Disable welcome message - https://askubuntu.com/a/676381 
if [ -d "etc/update-motd.d" ]; then 
  chmod -x /etc/update-motd.d/* 
fi


# if ! [ -f $HOME/domains_for_ssl.txt ]; then
#   echo "~/domains_for_ssl.txt is missing for configuration."
#   echo "--> Creating one in $HOME/domains_for_ssl.txt"
#   cp "${file_templates_dir}/domains_for_ssl.txt" "$HOME/domains_for_ssl.txt"
#   echo "--> Done"
#   echo ""
#   echo "Replace the file contents with the domain names you’d like the certificate to be valid for."
#   exit 1
# fi





cat <<EOF
--> Info!
During installation you will be asked for username/password combination for:
1. User with sudo access
2. MySQL root user
3. MySQL regular user

EOF



echo "--> Creating New User with sudo priviledges"
echo "Type username you want to create:"
echo "or press CTRL + C to quit"
echo -n ">>>"
read user_to_create

# set new user home path variable (IT IS UNUSED FOR NOW)
#new_user_home="/home/${user_to_create}"

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

### These 2 are Default Policies
# ufw default deny incoming
# ufw default allow outgoing

# Allowing SSH Connections
ufw_allow OpenSSH

ufw_allow 22

ufw_allow 7822 # custom port for ssh and sftp

### Allowing HTTP 
## Below 2 lines are not required because of further below Nginx Full (80,443)
#ufw_allow 80 # http
#ufw_allow 443 # https

# Allowing file transfer
ufw_allow 21 # ftp

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






echo ""
echo "Run:"
# TODO(tim): check in /etc/ssh/sshd_config for port number
echo "ssh-keygen && ssh-copy-id ${user_to_create}@${remote_machine_public_ip} -p 7822"


press_anything_to_continue


# TODO(tim): add here check if the ~/.ssh/authorized_keys exist










echo "--> Copying ${sshd_config} to ${sshd_config}.bak"
cp "${sshd_config}" "${sshd_config}.bak"
echo "--> Done"


echo "--> Disabling Password Authentication"

# Append to sshd_config some directives
{ echo "PasswordAuthentication no"; echo "PermitEmptyPasswords no"; echo "PermitRootLogin no"; } >> "$sshd_config"
# alternative: PermitRootLogin without-password


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
systemctl restart ssh # sshd on other distros than debian/ubuntu



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



# Do tad mam zrobione w initial_server_setuo.sh

################################################################################
################################################################################
################################################################################
################################################################################
################################################################################






################################################################################
# Install Linux, Nginx, MySQL, PHP (LEMP stack)                                #
################################################################################
# https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mysql-php-lemp-stack-on-ubuntu-20-04







function remove_apache_debian() {
  # On Debian/Ubuntu
  systemctl disable apache2 && systemctl stop apache2

  apt-get purge -y apache2 apache2-utils 
  
  apt-get purge -y apache2-bin apache2.2-bin
  apt-get purge -y apache2-common apache2.2-common

  apt-get purge -y apache2*

  # Get rid of other dependencies of unexisting packages
  apt-get autoremove

  # Remove the Configuration Files
  rm -rf /etc/apache2 
  # Remove the Supporing files and httpd modules # /usr/lib/apache2/modules
  rm -rf /usr/lib/apache2
}

function remove_apache_centos() {
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
}








update_and_upgrade



### Stop, remove apache2 and all dependencies
# TODO(tim): check if apache2 is present
if [[ "$RELEASE" == "centos" ]]; then
  # On RHEL/CentOS/Oracle/Fedora Linux.
  remove_apache_centos
else
  # On Debian/Ubuntu
  remove_apache_debian
fi




# Installing the Nginx Web Server
apt_install nginx

ufw_allow 'Nginx Full' # 'Nginx Full' is equivalent of both below
#ufw_allow 'Nginx HTTP'
#ufw_allow 'Nginx HTTPS'
#ufw delete allow 'Nginx HTTP' # Could not delete non-existent rule
#ufw delete allow 'Nginx HTTPS' # Could not delete non-existent rule



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

chown -R "$username":"$username" "$domain_root_dir"



# Copy already created example nginx configuration to /etc/nginx/sites-available/your_domain
cp "${file_templates_dir}/nginx_your_domain" "/etc/nginx/sites-available/${domain_name}"

# Replace in above file 'your_domain' to passed $domain_name
#
# NOTE(tim): unfortunately it replaces only 2 of 3 ocurrencies 
# because of www.your_domain prefix. So we need to run 2 line of replacing
sed -i "s/your_domain/${domain_name}/" "/etc/nginx/sites-available/${domain_name}"
sed -i "s/www\.your_domain/www.${domain_name}/" "/etc/nginx/sites-available/${domain_name}"
# -i option is used to modify the content of the original file.
#  s indicates the substitute command.



# Activate your configuration by linking to the config file from Nginx’s sites-enabled directory:
ln -s "/etc/nginx/sites-available/${domain_name}" /etc/nginx/sites-enabled/

# Then, unlink the default configuration file from the /sites-enabled/ directory:
unlink /etc/nginx/sites-enabled/default

# Note: If you ever need to restore the default configuration, 
# you can do so by recreating the symbolic link, like this:
#   ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/
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
  read -s -p "New password: " db_password
  echo
  read -s -p "Retype new password: " db_password2
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





################################################################################
# Secure Nginx with Let's Encrypt                                              #
################################################################################
# https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-20-04

# Installing Certbot
apt_install certbot python3-certbot-nginx

# Confirming Nginx’s Configuration
#
# Certbot needs to be able to find the correct server block in your Nginx
# configuration for it to be able to automatically configure SSL. 
# Specifically, it does this by looking for a server_name directive 
# that matches the domain you request a certificate for.


# TODO(tim): in /etc/nginx/nginx.conf set server_names_hash_bucket_size 64;



### Server Configuration
#
# * /etc/nginx: 
#     The Nginx configuration directory. 
#     All of the Nginx configuration files reside here.
# * /etc/nginx/nginx.conf: 
#     The main Nginx configuration file. 
#     This can be modified to make changes to the Nginx global configuration.
# * /etc/nginx/sites-available/: 
#     The directory where per-site server blocks can be stored. 
#     Nginx will not use the configuration files found in this directory unless they are linked to the sites-enabled directory. Typically, all server block configuration is done in this directory, and then enabled by linking to the other directory.
# * /etc/nginx/sites-enabled/: 
#     The directory where enabled per-site server blocks are stored. 
#     Typically, these are created by linking to configuration files found in the sites-available directory.
# * /etc/nginx/snippets: 
#     This directory contains configuration fragments
#     that can be included elsewhere in the Nginx configuration. 
#     Potentially repeatable configuration segments are good candidates into snippets.




# Obtaining an SSL Certificate
cat <<EOF

Obtaining an SSL Certificate for:
1. $domain_name
1. www.${domain_name}

If this is your first time running certbot, you will be prompted to
enter an email address and agree to the terms of service.

After doing so, certbot will communicate with the Let’s Encrypt server, 
then run a challenge to verify that you control the domain you’re requesting a certificate for.

PS Choose not to change configuration

EOF



# CERTBOT USAGE:
# https://certbot.eff.org/docs/using.html

# NOTE: CERTBOT HAVE RATE LIMITS
# Ref: https://letsencrypt.org/docs/rate-limits/
# SO TO AVOID IT, USE '--dry-run' (for developement purposes)
# Ref: https://letsencrypt.org/docs/staging-environment/


# the domain names we’d like the certificate to be valid for.
#certbot --nginx -d "${domain_name}" -d "www.${domain_name}"
certbot --nginx --non-interactive --agree-tos --redirect --no-eff-email -m krystatymoteusz@gmail.com -d "${domain_name}" -d "www.${domain_name}"
# another example from one company: 
# $ certbot certonly --noninteractive --agree-tos --cert-name slickstack -d ${SITE_TLD} -d www.${SITE_TLD} -d staging.${SITE_TLD} -d dev.${SITE_TLD} --register-unsafely-without-email --webroot -w /var/www/html/
#
# In our case we hardcode the --cert-name to be slickstack because only
# one website is installed on each VPS server, so it makes other server admin tasks 
# (and scripts) easier to manage. However, if you are installing several domains 
# and SSL certs on the same server, you could change the subcommand --cert-name 
# to be named after each TLD domain instead, etc. This affects the SSL directory
#  names, thus helping to keep your files/folders nice and tidy.
# 
# another modification of above:
# $ certbot certonly --noninteractive --agree-tos --cert-name ${SITE_TLD} -d ${SITE_DOMAIN_ONE} -d ${SITE_DOMAIN_TWO} -m ${SSL_EMAIL} --webroot -w /var/www/html/

# use it! 
# --no-eff-email - dont share your email with eff
# --redirect - to https





echo ""
echo "Visit SSL Labs Server Test, it will get an A grade."
echo "https://www.ssllabs.com/ssltest/analyze.html?d=${domain_name}"
echo ""



# Verifying Certbot Auto-Renewal

# You can query the status of the timer with systemctl:
#systemctl status certbot.timer

# To test the renewal process, you can do a dry run with certbot:
echo "Testing renewal process (dry run)"
certbot renew --dry-run

cat <<EOF

If you see no errors, you’re all set.

If the automated renewal process ever fails, 
Let’s Encrypt will send a message to the email you specified, 
warning you when your certificate is about to expire.

EOF





exit 0 


################################################################################
# Install and Secure phpMyAdmin with Nginx                                     #
################################################################################
# https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-phpmyadmin-with-nginx-on-an-ubuntu-20-04-server


echo "--> Updating packages"
update_and_upgrade



cat <<EOF

--> Installing phpMyAdmin...

1. During the installation process, you will be prompted to choose a web server
   (either Apache or Lighttpd) to configure.
   However, because you are using Nginx as a web server you shouldn’t choose either of these options. 
-->Instead press 'TAB' to highlight the '<Ok>' and then press 'ENTER' to continue the installation process.

2. Next, you’ll be prompted whether to use dbconfig-common for configuring the application database. 
-->Select <Yes>.
   This will set up the internal database and administrative user for phpMyAdmin. 
   You will be asked to define a new password for the phpmyadmin MySQL user, 
-->but because this isn’t a password you need to remember you can leave it blank and let phpMyAdmin randomly create a password.
EOF

press_anything_to_continue

# Installing phpMyAdmin
apt_install phpmyadmin



### Changing phpMyAdmin’s Default Location

# One way to protect your phpMyAdmin installation is by making it harder to find. 
# Bots will scan for common paths, like /phpmyadmin, /pma, /admin, /mysql, and other similar names. 
# Changing the interface’s URL from /phpmyadmin to something non-standard will 
# make it much harder for automated scripts to find your phpMyAdmin installation
# and attempt brute-force attacks.



# Create a symbolic link from the installation files to Nginx’s document root directory
ln -s /usr/share/phpmyadmin "/var/www/${domain_name}/cocietokurwaobchodzicotutajjest"


echo ""
echo "Now you can visit and login with your regular MySQL credentials"
echo "https://${domain_name}/cocietokurwaobchodzicotutajjest"
echo ""

press_anything_to_continue

# Disabling Root Login


# Because you selected dbconfig-common to configure and store phpMyAdmin settings, 
# the application’s default configuration is currently stored within your MySQL database. 
# You’ll need to create a new config.inc.php file in phpMyAdmin’s configuration directory
# to define your custom settings. Even though phpMyAdmin’s PHP scripts are located
# inside the /usr/share/phpmyadmin directory, the application’s 
# configuration files are located in /etc/phpmyadmin.



# Create a new custom settings file inside the /etc/phpmyadmin/conf.d directory and name it pma_secure.php:
cp "${file_templates_dir}/pma_secure.php" /etc/phpmyadmin/conf.d/pma_secure.php



# Note: If the passphrase you enter here is shorter than 32 characters in length, 
# it will result in the encrypted cookies being less secure. 
# Entering a string longer than 32 characters, though, won’t cause any harm.

# To generate a truly random string of characters, use pwgen
apt_install pwgen

# By default, pwgen creates easily pronounceable, though less secure, passwords. 
# However, by including the -s flag, as in the following command, 
# you can create a completely random, difficult-to-memorize password.
random_string=$(pwgen -s 32 1)

# Replace
sed -i "s/CHANGE_THIS_TO_A_STRING_OF_32_RANDOM_CHARACTERS/${random_string}/" /etc/phpmyadmin/conf.d/pma_secure.php 









### Creating an Authentication Gateway
echo "--> Creating an Authentication Gateway"
#
# By completing this step, anyone who tries to access your phpMyAdmin 
# installation’s login screen will first be required to pass through
# an HTTP authentication prompt by entering a valid username and password.
#
# In addition to providing an extra layer of security, this gateway
# will help keep your MySQL logs clean of spammy authentication attempts.


echo ""
echo "--> Creating pma_pass file"
echo "--> Enter username and password you will need to access phpMyAdmin"
echo "Username doesn’t need to be the name of an existing user profile on your Ubuntu server or that of a MySQL user."
echo ""

read -p "Username: " pma_username

echo ""

# First you need to create a password file to store the authentication credentials.
# Nginx requires that passwords be encrypted using the crypt() function.

# Create an encrypted password
pma_password=$(openssl passwd)

# In this file, specify the username you would like to use, 
# followed by a colon (:) and then the encrypted version of the password 
# you received from the openssl passwd utility. Example: 'sammy:9YHV.p60.Cg6I'
echo "${pma_username}:${pma_password}" > /etc/nginx/pma_pass





# Remove current nginx domain config file
rm "/etc/nginx/sites-available/${domain_name}"

# Copy version 2 with PMA Authentication Gateway added
cp "${file_templates_dir}/example_nginx_config_v2" "/etc/nginx/sites-available/${domain_name}"
 
# Locate the server block, and the location / section within it. 
# You need to create a new location section below this location / block 
# to match phpMyAdmin’s current path on the server.

# You don’t need to include the full file path, just the name of the symbolic link
# relative to the Nginx document root directory:



# Within this block, set up two directives: 
# 1. auth_basic, which defines the message that will be displayed on the authentication prompt, 
# 2. auth_basic_user_file, pointing to the authentication file you just created.


# NOTE: In Nginx configuration files, 
# regular expression definitions have a higher precedence over standard location definitions. 

# This means that if you we don’t use the ^~ selector at the beginning of the location, 
# users will still be able to bypass the authentication prompt 
# by navigating to http://server_domain_or_ip/hiddenlink/index.php in their browser.

# The ^~ selector at the beginning of the location definition tells Nginx
# to ignore other matches when it finds a match for this location. 
# This means that any subdirectories or files within /hiddenlink/ will be matched with this rule.

# However, because the definition to parse PHP files will be skipped 
# as a result of the ^~ selector usage, we’ll need to include a new PHP location block
# inside the /hiddenlink definition. This will make sure PHP files inside this location
# are properly parsed; otherwise they will be sent to the browser as download content.


# location ^~ /cocietokurwaobchodzicotutajjest/ {
#   auth_basic "Admin Login";
#   auth_basic_user_file /etc/nginx/pma_pass;
# 
#   location ~ \.php$ {
#     include snippets/fastcgi-php.conf;
#     fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
#   }
# }

# TODO(tim): You should also double check the location of your PHP-FPM socket file




# Test the configuration
nginx -t

# To activate the new authentication gate, reload Nginx:
systemctl reload nginx



### To ad additional phpMyAdmin security: TODO(tim):
#
# Setting Up Access via Encrypted Tunnels
# https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-phpmyadmin-with-nginx-on-an-ubuntu-20-04-server#step-5-—-setting-up-access-via-encrypted-tunnels







echo "exiting before webuzo"
exit 0


# before installing webuzo install below two lines to make it work!
# these are dependencies without which webuzo will fail
apt_install sendmail-bin
apt_install sendmail

# Install webuzo

# Donwload Webuzo installation script
wget http://files.webuzo.com/install.sh
chmod 700 install.sh


./install.sh


cat <<EOF
1. When the installation script finishes, enter link it displays .
2. The Webuzo Initial Setup page appears.
3. Type a username.
4. Type the user's e-mail address.
5. Type and re-enter the user's password.
6. In the Primary Domain text box, type the server's domain name or IP address.
7. In the NameServer 1 and NameServer 2 text boxes, type the primary and secondary name servers for the domain.

i  If you do not have name servers for the server, type ns1.example.com and ns2.example.com.

8. Click Install.

i  Do not navigate away from the page or interrupt the installation process. 
   The installation process can take a few minutes.

--> After installation navigate to your domain at 2002,2004,2005 port
EOF










# TODO(tim): do it with vps_configuration
####################################################################################################
#### Justeuro: External References Used To Improve This Script (Thanks, Interwebz) ###############
####################################################################################################

## Ref: https://linuxize.com/post/secure-apache-with-let-s-encrypt-on-ubuntu-18-04/
## Ref: https://stackoverflow.com/questions/49172841/


exit 0
## JE_EOF



# PHP.INI
# Make backup of old and replace php.ini
#
phpini_main_config_file_path=$(php -i | grep 'Loaded Configuration File' | awk -F '=> ' '{ print $2 }')

if [ "$phpini_main_config_file_path" = '(none)' ]; then
  echo "Error finding path to main php.ini configuration file"
  echo "You will need to replace it manually!"
else
  date=$(date '+%Y-%m-%d')
  # Create backup or old php.ini
  mv $phpini_main_config_file_path "${phpini_main_config_file_path}.${date}.bak"
  # Move new php.ini to the place of old one
  cp "${file_templates_dir}/php.ini.example" $phpini_main_config_file_path
fi
