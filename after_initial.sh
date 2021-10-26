#!/bin/bash
#
# 


# This need to be run as root!
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi

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


function update_and_upgrade() {
  sudo apt-get update -y && sudo apt-get upgrade -y
}


function apt_install() {
  sudo apt-get install -y "$@"
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


sshd_config='/etc/ssh/sshd_config'
file_templates_dir="${PWD}/z_file_templates"


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




cat <<EOF





EOF



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





EOF

apt_install nginx
apt_install php-fpm php-mysql






cat <<EOF





EOF


domain_name='justeuro.eu'


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

username="tim"

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






cat <<EOF





EOF










apt_install certbot python3-certbot-nginx

certbot --nginx -d "${domain_name}" -d "www.${domain_name}"
certbot renew --dry-run


