#!/bin/bash
#
# Funtions for after_initial.sh

source <(curl -s https://raw.githubusercontent.com/tlatsas/bash-spinner/master/spinner.sh)


# $1 have to be spinner message
# $2 have to be command to execute
function log_it() {
  if [[ $# -lt 2 ]]; then
    echo "[${funcstack}]: You are missing argument(s) for this funtion"
    return
  fi

  local spinner_message command_to_execute
  spinner_message="$1"
  command_to_execute="$2"

  start_spinner "$spinner_message"
  # Evaluate command to execute
  
  if [ "${DEBUG}" = true ]; then
    eval "$command_to_execute" &> "$LOG_FILE"
  else
    eval "$command_to_execute" &> /dev/null
  fi
  
  # Pass the last comands exit code
  stop_spinner $?
}



function apt_install() {
  sudo apt-get install -y "$@"
}

function update_and_upgrade() {
  sudo apt-get update -y && sudo apt-get upgrade -y
}


function press_anything_to_continue() {
  read -n 1 -s -r -p "Press any key to continue"
  # -n defines the required character count to stop reading
  # -s hides the user's input
  # -r causes the string to be interpreted "raw" (without considering backslash escapes)
  echo ""
}


function open_ports() {
  ### One of requirements
  # Open Ports - 2002, 2003, 2004, 2005, 21, 22, 25, 53, 80, 143, 443, 465, 993 and 3306 (It is recommended to keep these ports open on your server)
  # Note : There should be no PHP, Apache, MySQL installed on the server

  ### For mail server bunch examples from internet to open ports
  # 25 (SMTP),
  # 587 (SMTP over TLS),
  # 465 (SMTPS),
  # 143 (IMAP),
  # 993 (IMAPS),
  # 110 (POP3),
  # 995 (POP3S)
  PORTS_TO_BE_OPEN=(
    "2002"
    "2003"
    "2004"
    "2005"
    "21"
    "22"
    "25"
    "53"
    "80"
    "143"
    "443"
    "465"
    "993"
    "3306"
  )

  for port in "${PORTS_TO_BE_OPEN[@]}"; do
    ufw allow "$port"
  done

}

function install_webuzo() {

  ##### Original installation script (October 2021)
  # https://www.webuzo.com/docs/installing-webuzo/install/


  open_ports


  # before installing webuzo install below two lines to make it work!
  # these are dependencies without which webuzo will fail
  #apt_install sendmail-bin
  #apt_install sendmail

  # Install webuzo

  # Donwload Webuzo installation script
  wget http://files.webuzo.com/install.sh
  chmod 700 install.sh


  # TODO(tim): already tested remove it
  #./install.sh --install=lamp,bind

  # This will install only Webuzo without any LAMP Stack.
  ./install.sh --install=none # do not install httpd so port 80 is free

  #./install.sh

  # Remove the installer
  rm -f ./install.sh
}



function remove_apache_debian() {
  # On Debian/Ubuntu
  systemctl disable apache2 && systemctl stop apache2


  # Get list of apache dependencies and purge it
  temp_file=$(mktemp)
  apt list --installed | grep -i apache > "$temp_file"

  while read line; do
    arrIN=(${line/\// }) # // means global replace
    apt-get purge -y "${arrIN[0]}"
    #echo "${arrIN[0]}"
  done < "$temp_file"

  rm "$temp_file"



  #apt-get purge apache2 apache2-utils  -y
  #apt-get purge apache2-bin apache2.2-bin -y
  #apt-get purge apache2-common apache2.2-common -y
  #apt-get purge apache2* -y
  #apt-get purge apache2 apache2-bin apache2-data apache2-doc apache2-utils apache2-common -y

  # Get rid of other dependencies of unexisting packages
  apt-get autoremove -y

  # Remove the Configuration Files
  rm -rf /etc/apache2 # TODO(tim): you can use 'whereis apache2' here
  # Remove the Supporing files and httpd modules # /usr/lib/apache2/modules
  rm -rf /usr/lib/apache2
  
  # dpkg: warning: while removing apache2-bin, directory '/var/lib/apache2' not empty so not removed
  #rm -rf /var/lib/apache2

  # TODO(tim): Both seem to be empty, check it
  #rm -rf /usr/include/apache2

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


function install_mysql() {
  # Installing MySQL
  apt_install mysql-server

  # TODO(tim): pass in here answears to make it non-interactive
  ### Below will: 
  # 1. ask for 'VALIDATE PASSWORD PLUGIN'
  # 2. prompt for password 
  # 3. prompt for password (confirmation)
  # 4. remove some anonymous users,
  # 5. remove the test database,
  # 6. disable remote root logins, and
  # 7. load these new rules so that MySQL immediately respects the changes you have made.

  # NOTE(tim): does not work as intended cuz do not read only for password
# mysql_secure_installation <<EOF
# no
# tymek2002
# tymek2002
# Y
# no
# no
# Y
# EOF

  mysql_secure_installation


  # TODO(tim): create a dedicated user for databases
}



function replace_php_ini() {
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

}


function install_php() {
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

  
  if [ "$STACK" = 'LEMP' ]; then
    # nginx
    #apt_install php-fpm php-mysql # original
    apt_install php-fpm
  else
    # apache
    #apt_install php libapache2-mod-php php-mysql # original
    apt_install php libapache2-mod-php
  fi

  apt_install php-mysql
  
  # PHP.INI
  # Make backup of old and replace with php.ini from my templates fils
  replace_php_ini
}

function remove_apache() {
  init


  ### Stop, remove apache2 and all dependencies
  if [[ "$RELEASE" == "centos" ]]; then
    # On RHEL/CentOS/Oracle/Fedora Linux.
    remove_apache_centos
  else
    # On Debian/Ubuntu
    remove_apache_debian
  fi
}


function initialization() {

  # This need to be run as root!
  if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
  fi

  update_and_upgrade
  
}

function create_mysql_user_and_test_mysql() {


  ##### Create new MySQL user
  #echo ""
  #echo "--> Creating new mysql user"
  #echo ""
#
  #read -p "Username: " db_username
#
  #echo ""
#
  #while true; do
  #  read -s -p "New password: " db_password
  #  echo
  #  read -s -p "Retype new password: " db_password2
  #  echo
  #  [ "$db_password" = "$db_password2" ] && break
  #  echo "Please try again"
  #done




  cp "${file_templates_dir}/test_mysql_php_connection.sql" "${domain_root_dir}/test_mysql_php_connection.sql"


  # Replace username
  sed -i "s/example_user/${db_username}/gm" "${domain_root_dir}/test_mysql_php_connection.sql"
  # Replace password
  sed -i "s/example_password/${db_password}/gm" "${domain_root_dir}/test_mysql_php_connection.sql"

  # Create a user and test database
  mysql -u root < "${domain_root_dir}/test_mysql_php_connection.sql"

  # To manually log in to mysql new user and check the records
  #
  # mysql -u example_user -p
  # SHOW DATABASES;
  # SELECT * FROM example_database.todo_list;



  rm -f "${domain_root_dir}/test_mysql_php_connection.sql"

  



  # To list all MySQL users
  # SELECT User,Host FROM mysql.user;


  # List grants for a mysql user
  # SHOW GRANTS FOR 'bloguser'@'localhost';


  #DROP USER 'bloguser'@'localhost';

}





function tests() {


  


  ################################################################################
  # Tests
  ################################################################################





  ### Testing HTML with Nginx
  echo "--> Testing HTML with Nginx"
  # Copy an index.html template to test
  cp "${file_templates_dir}/index.html" "${domain_root_dir}/index.html"


  echo "--> Done"
  echo "Now visit: http://${PRIMARY_DOMAIN}"
  press_anything_to_continue
  echo "Removing ${domain_root_dir}/index.html"
  rm -f "${domain_root_dir}/index.html"




  ### Testing PHP with Nginx
  echo "--> Testing PHP with Nginx"
  printf "<?php\nphpinfo();" > "${domain_root_dir}/info.php"


  echo "--> Done"
  echo "Now visit: http://${PRIMARY_DOMAIN}/info.php"
  press_anything_to_continue
  echo "Removing ${domain_root_dir}/info.php"
  rm -f "${domain_root_dir}/info.php"




  ### Testing Database Connection from PHP
  echo "--> Testing Database Connection from PHP"


  # Copy todo_list.php
  cp "${file_templates_dir}/todo_list.php" "${domain_root_dir}/todo_list.php"

  # Replace username
  sed -i "s/example_user/${db_username}/gm" "${domain_root_dir}/todo_list.php"
  # Replace password
  sed -i "s/example_password/${db_password}/gm" "${domain_root_dir}/todo_list.php"



  echo "--> Done"
  echo "Now visit: http://${PRIMARY_DOMAIN}/todo_list.php"

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
  rm -f "${domain_root_dir}/todo_list.php"



  ##### Remove created database
  ### Execute mysql command from command line 
  # wtf cuz -p is password
  # mysql -u [username] -p somedb < somedb.sql
  # mysql -u [username] -p [dbname] -e [query]
  mysql -u root -e "DROP DATABASE example_database;"
  
  ### Delete created mysql user
  mysql -u root -e "DROP USER '${db_username}'@'localhost';"
  #$db_username
  #$db_password

}

function handle_nginx_conf_and_webroot() {
  

  # Instead of modifying /var/www/html, we’ll create a directory structure 
  # within /var/www for the 'your_domain' website, leaving /var/www/html in place 
  # as the default directory to be served if a client request doesn’t match any other sites.
  #
  # It is better and easier to manage multiple domains on one server that way

  domain_root_dir="/var/www/${PRIMARY_DOMAIN}"

  # Create the root web directory for 'your_domain' if not exists:
  [ -d "$domain_root_dir" ] || mkdir "$domain_root_dir"


  # Next, assign ownership of the directory with the $USER environment variable,
  # which will reference your current system user:
  #echo "$ USER = $USER"
  #echo "Type username which have to be owner to ${domain_root_dir}"
  #read username


  chown -R "$USERNAME":"$USERNAME" "$domain_root_dir"



  # Copy already created example nginx configuration to /etc/nginx/sites-available/your_domain
  cp "${file_templates_dir}/nginx_your_domain" "/etc/nginx/sites-available/${PRIMARY_DOMAIN}"

  # Replace in above file 'your_domain' to passed $PRIMARY_DOMAIN
  #
  # NOTE(tim): unfortunately it replaces only 2 of 3 ocurrencies 
  # because of www.your_domain prefix. So we need to run 2 line of replacing
  sed -i "s/your_domain/${PRIMARY_DOMAIN}/gm" "/etc/nginx/sites-available/${PRIMARY_DOMAIN}"
  # -i option is used to modify the content of the original file.
  #  s indicates the substitute command.



  # Activate your configuration by linking to the config file from Nginx’s sites-enabled directory:
  ln -s "/etc/nginx/sites-available/${PRIMARY_DOMAIN}" /etc/nginx/sites-enabled/

  # Then, unlink the default configuration file from the /sites-enabled/ directory:
  unlink /etc/nginx/sites-enabled/default


  # Note: If you ever need to restore the default configuration, 
  # you can do so by recreating the symbolic link, like this:
  #   ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/
  echo "Testing configuration for syntax errors..."
  nginx -t


  # If everything is correct reload Nginx
  systemctl reload nginx || exit 1 # TODO(tim): manage exeptions e.g. print all non 0 exit codes
}

# Nginx
function install_LEMP() {
  # Installing the Nginx Web Server
  apt_install nginx

  ufw allow 'Nginx Full' # 'Nginx Full' is equivalent of both below
  # 'Nginx HTTP'
  # 'Nginx HTTPS'

  install_mysql
  install_php


  handle_nginx_conf_and_webroot

  create_mysql_user_and_test_mysql
  tests

  # TODO(tim): Temporary commented for tests
  # setup_ssl >> "$LOG_FILE"
  
  # Remove current nginx domain config file
  rm "/etc/nginx/sites-available/${PRIMARY_DOMAIN}"
  # Copy version 2 with PMA Authentication Gateway added
  cp "${file_templates_dir}/example_nginx_config_v2" "/etc/nginx/sites-available/${PRIMARY_DOMAIN}"
  
}

function setup_ssl() {
  local EMAIL CERT_NAME
  EMAIL='krystatymoteusz@gmail.com'
  CERT_NAME='justeuro.eu'

  apt_install certbot python3-certbot-nginx
 
  ##### Staging enviroment (to test) with --dry-run
  ### it will not install any certificates
  #certbot certonly --nginx --non-interactive --dry-run --agree-tos --redirect --cert-name "$CERT_NAME" --no-eff-email -m "$EMAIL"  -d "${PRIMARY_DOMAIN}" -d "www.${PRIMARY_DOMAIN}"  -d "mail.${PRIMARY_DOMAIN}"  -d "smtp.${PRIMARY_DOMAIN}" -d "imap.${PRIMARY_DOMAIN}" -d "app.${PRIMARY_DOMAIN}"
  #certbot renew --dry-run


  # Production
  #certbot --nginx --non-interactive --agree-tos --redirect --cert-name "$CERT_NAME" --no-eff-email -m "$EMAIL"  -d "${PRIMARY_DOMAIN}" -d "www.${PRIMARY_DOMAIN}"  -d "mail.${PRIMARY_DOMAIN}"  -d "smtp.${PRIMARY_DOMAIN}" -d "imap.${PRIMARY_DOMAIN}" -d "app.${PRIMARY_DOMAIN}"
  certbot --nginx --non-interactive --agree-tos --redirect --cert-name "$CERT_NAME" --no-eff-email -m "$EMAIL"  -d "${PRIMARY_DOMAIN}" -d "www.${PRIMARY_DOMAIN}"  -d "mail.${PRIMARY_DOMAIN}"  -d "smtp.${PRIMARY_DOMAIN}" -d "imap.${PRIMARY_DOMAIN}" 

  # TODO(tim): make backup of /etc/letsencrypt
 # - Your account credentials have been saved in your Certbot
 #   configuration directory at /etc/letsencrypt. You should make a
 #   secure backup of this folder now. This configuration directory will
 #   also contain certificates and private keys obtained by Certbot so
 #   making regular backups of this folder is ideal.
}


### Apache
# Ref: https://www.digitalocean.com/community/tutorials/how-to-install-linux-apache-mysql-php-lamp-stack-on-ubuntu-20-04
function install_LAMP() {
  apt_install apache2
  ufw allow 'Apache Full'
  # 'Apache'
  # 'Apache Secure'

  install_mysql
  install_php

  # Creating a Virtual Host for your Website
  # virtual hosts (similar to server blocks in Nginx) 

  


}











function install_webuzo_apps() {
  for aid in "${WEBUZO_APPS_TO_INSTALL[@]}"; do
    # this php compiler have its own php.ini so do not worry
    /usr/local/emps/bin/php /usr/local/webuzo/cli.php --app_install --soft="$aid"
    # TODO(tim): if error would occur run same command twice (manually it works)
  done
}

function install_webuzo_scripts() {
  for sid in "${WEBUZO_SCRIPTS_TO_INSTALL[@]}"; do
    # TODO(tim): finish it
    : # true equivalent
    # (colon) Does nothing beyond expanding arguments and performing redirections.
    # The return status is zero.
  done
}