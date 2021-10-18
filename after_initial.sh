#!/bin/bash
#
# Install Linux, Nginx, MySQL, PHP (LEMP stack)  

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
function apt_install() {
  sudo apt-get install -y "$@"
}

function update_and_upgrade() {
  sudo apt-get update -y && sudo apt-get upgrade -y
}

function ufw_allow() {
  sudo ufw allow "$@"
}

function press_anything_to_continue() {
  read -n 1 -s -r -p "Press any key to continue"
  # -n defines the required character count to stop reading
  # -s hides the user's input
  # -r causes the string to be interpreted "raw" (without considering backslash escapes)
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

# TODO(tim): createa a dedicated user for databases


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
echo "$ USER = $USER"
echo "Type username which have to be owner to ${domain_root_dir}"
read username

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


echo ""
echo "Creating new mysql user"
echo ""

echo "Type username for the new mysql user"
read db_username

echo ""

echo "Type password for the new mysql user"
read db_password


# TODO(tim): think of copying "${file_templates_dir}/test_mysql_php_connection.sql"
#cp "${file_templates_dir}/test_mysql_php_connection.sql" "${file_templates_dir}/test_mysql_php_connection.sql.bak"


# Replace username
sed -i "s/example_user/${db_username}" "${file_templates_dir}/test_mysql_php_connection.sql"
# Replace password
sed -i "s/example_password/${db_password}" "${file_templates_dir}/test_mysql_php_connection.sql"

# Create a user and test database
mysql -u root < "${file_templates_dir}/test_mysql_php_connection.sql"

# To manually log in to mysql new user and check the records
#
# mysql -u example_user -p
# SHOW DATABASES;
# SELECT * FROM example_database.todo_list;




# Copy todo_list.php
cp "${file_templates_dir}/todo_list.php" "${domain_root_dir}/todo_list.php"

# Replace username
sed -i "s/example_user/${db_username}" "${domain_root_dir}/todo_list.php"
# Replace password
sed -i "s/example_password/${db_password}" "${domain_root_dir}/todo_list.php"




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