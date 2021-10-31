#!/bin/bash
#
# 

#set -euo pipefail



########################
### SCRIPT VARIABLES ###
########################

DEBUG=
LOG_FILE="/root/after_initial.log"

STACK='LEMP' # LAMP (apache) or LEMP (nginx)

PRIMARY_DOMAIN='justeuro.eu'
EMAIL='krystatymoteusz@gmail.com'

# Name of the user to grant privileges and ownership
USERNAME='tim'


# Primary domain (without http(s) scheme) name to create a directory structure

file_templates_dir="${PWD}/z_file_templates"

lib_dir_name='after_initial'

# MySQL user credentials
db_username='database_manager'
db_password='tymek2002'

# Webuzo .zip archive with settings path
# Ref: https://www.softaculous.com/docs/admin/import-export-settings/
WEBUZO_SETTINGS_TO_IMPORT=


# App ID (aid in below link)
# http://api.webuzo.com/apps.php

# Add here AID if you choose to install webuzo with e.g. lemp stack
WEBUZO_APPS_TO_REMOVE=(
  # "3" # Apache
)

WEBUZO_APPS_TO_INSTALL=(
  "35" # Exim is pre-installed
  "36" # Dovecot
  "34" # BIND is pre-installed
  "137" # SpamAssassin
  "29" # Python2 
  "140" # Python3 
  #"16" # MySQL
  #"136" # phpMyAdmin 
)

### These below comes preinstalled with basic webuzo installation
# apache
# curl
# mcrypt
# openLDAP
# sqllite
# php

# ONCE HAPPENED

# apache
# curl
# mcrypt
# perl
# openLDAP
# python2
# pure-ftpd
# sqllite
# bind
# exim
# mysql
# php

WEBUZO_APPS_TO_INSTALL=(
  "4"   # openssl            dep for curl
  "22"  # ldap (openLDAP)    dep for curl
  "8"   # curl               dep for php
  
  # RainLoop - requirements
  # https://www.rainloop.net/docs/system-requirements/
  "18"  # nginx              dep for rainloop
  "13"  # libxml             dep for rainloop
  "20"  # pcre               dep for rainloop

  "29"  # Python2 
  "140" # Python3 

  # PERL - requirements
  "28"  # libcap             dep for perl
  "19"  # Perl

  "31"  # pure-ftpd errer extracting

  "17"  # ncurses            dep for MySQL
  "16"  # MySQL

  # PHP - requirements
  "32"  # Sqlite             dep for php
  "151" # libzip             dep for php
  "26"  # libssh             dep for php
  "126" # libexpat           dep for php
  "150" # libonig            dep for php
  "33"  # xslt               dep for php
  "10"  # freetype           dep for gd
  "6"   # gd                 dep for php
  "44"  # imap               dep for php
  "9"   # freetds            dep for php
  "59"  # tidy               dep for php
  "153" # libsodium          dep for php
  "27"  # libtool            dep for php
  "14"  # mcrypt             dep for php
  "7"   # bzip               dep for php
  "149" # PHP 7.4

  "136" # phpMyAdmin

  # Mail server
  "35"  # Exim
  "36"  # Dovecot
  "34"  # BIND
  "137" # SpamAssassin

)






### For setup_webuzo.sh
# cp = Control Panel
cpuser="tymek22"
cppass="tymek2002"
cpdomain="$PRIMARY_DOMAIN"





########################
### HELPER FUNCTIONS ###
########################

#. "./${lib_dir_name}/nginx.sh"
#. "./${lib_dir_name}/apache.sh"
. "./${lib_dir_name}/lib.sh"



####################
### SCRIPT LOGIC ###
####################

#initialization >> "$LOG_FILE"
#remove_apache >> "$LOG_FILE"

# Redirect stdout and stderr to terminal and file
initialization |& tee -a "$LOG_FILE"
remove_apache |& tee -a "$LOG_FILE"



install_webuzo

# Just to test it so run it twice
#remove_apache |& tee -a "$LOG_FILE"


# Source script
. ./setup_webuzo.sh


remove_webuzo_apps |& tee -a /root/remove_webuzo_apps.log

install_webuzo_apps |& tee -a /root/install_webuzo_apps.log

install_webuzo_scripts |& tee -a /root/install_webuzo_scripts.log



##### TODO(tim): Maybe import it and install webuzo apps before installing L(A|E)MP STACK
##### from one hand ok but if you want to install L(A|E)MP STACK yourself 
##### you have to 1st install php to install most webuzo apps or maybe add to setup_webuzo.sh
##### additionaly note that webuzo imports also conf files as e.g. php.ini, my.conf, nginx.conf, exim.conf etc.
#
# Import webuzo settings if present
# NOTE: that settings only without installed apps
if [ -n "$WEBUZO_SETTINGS_TO_IMPORT" ]; then

  # need to be run as root and be uploaded on server
  #sudo /usr/local/emps/bin/php /usr/local/webuzo/cli.php --import_settings --file=/path/to/softaculous_settings.zip
  /usr/local/emps/bin/php /usr/local/webuzo/cli.php --import_settings --file="$WEBUZO_SETTINGS_TO_IMPORT"
fi

#### General apps to install
# openssl aid 4 dependency for curl TODO(tim): it wasnt required as certbot ran
# curl aid 8 (have to be installed via webuzo even if on system it is installed) (in here it is php dependency)
# PHP aid 149 for php 7.4 and aid 154 for php 8.0
# MySQL aid 16
# phpMyAdmin aid 136
#
#### Mail apps to install on webuzo
# Exim
# Dovecot
# RainLoop webmail # sid 497 # or Roundcube # sid 118
# BIND # DNS software to setup MX record
# SpamAssassin # Install Exim before




restart_webuzo_services_for_prevention


exit 0

# Note that with webuzo is some apps installed
if [ "$STACK" = 'LEMP' ]; then
  install_LEMP
else
  install_LAMP
fi













exit 0



### Install OpenDKIM
# We need to install and configure DKIM on our mail server so that the other email
# servers can authenticate the emails sent from our server and confirm that the emails
# are not forged or altered and the emails are authorized by the domain owner. 
# Use the below-mentioned commands to install OpenDKIM.
#apt_install opendkim opendkim-tools

# Start OpenDKIM do not need cuz after installation it will start itself
#service opendkim start





# TODO(tim): do it with vps_configuration
####################################################################################################
#### Justeuro: External References Used To Improve This Script (Thanks, Interwebz) ###############
####################################################################################################

## Ref: https://linuxize.com/post/secure-apache-with-let-s-encrypt-on-ubuntu-18-04/
## Ref: https://stackoverflow.com/questions/49172841/
