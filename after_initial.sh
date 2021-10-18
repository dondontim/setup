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

  apt-get purge apache2 apache2-utils 
  
  apt-get purge apache2-bin apache2.2-bin
  apt-get purge apache2-common apache2.2-common

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
read domain_name


# Instead of modifying /var/www/html, we’ll create a directory structure 
# within /var/www for the 'your_domain' website, leaving /var/www/html in place 
# as the default directory to be served if a client request doesn’t match any other sites.
#
# It is better and easier to manage multiple domains on one server that way

# Create the root web directory for 'your_domain' as follows:
mkdir "/var/www/${domain_name}"

# Next, assign ownership of the directory with the $USER environment variable,
# which will reference your current system user:
echo "$ USER = $USER"
echo "Type username which have to be owner to /var/www/${domain_name}"
read username

chown -R $username:$username "/var/www/${domain_name}"



# Move already created example nginx configuration to /etc/nginx/sites-available/your_domain
mv "$PWD/z_file_templates/nginx_your_domain" "/etc/nginx/sites-available/${domain_name}"

# Replace above file contents
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

# Move an index.html template to test
mv "$PWD/z_file_templates/index.html" "/var/www/${domain_name}/index.html"


echo "--> Done"
echo "Now visit: http://server_domain_or_IP"