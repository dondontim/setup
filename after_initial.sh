#!/bin/bash
#
# 

set -euo pipefail



########################
### SCRIPT VARIABLES ###
########################

DEBUG=
LOG_FILE="/root/after_initial.log"

STACK='LEMP' # LAMP (apache) or LEMP (nginx)

PRIMARY_DOMAIN='justeuro.eu'

# Name of the user to grant privileges and ownership
USERNAME=tim


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
WEBUZO_APPS_TO_INSTALL=(
  "35" # Exim
  "36" # Dovecot
  "34" # BIND
  "137" # SpamAssassin
)

# Script ID (sid)
WEBUZO_SCRIPTS_TO_INSTALL=(
  # RainLoop webmail # sid 497 # or Roundcube # sid 118
)



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


# Source script
. ./setup_webuzo.sh


#exit 0


cat <<EOF


EOF



if [ "$STACK" = 'LEMP' ]; then
  install_LEMP
else
  install_LAMP
fi


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



#install_webuzo_apps |& tee -a /root/install_webuzo_apps.log

#install_webuzo_scripts |& tee -a /root/install_webuzo_scripts.log







### Install OpenDKIM
# We need to install and configure DKIM on our mail server so that the other email
# servers can authenticate the emails sent from our server and confirm that the emails
# are not forged or altered and the emails are authorized by the domain owner. 
# Use the below-mentioned commands to install OpenDKIM.
#apt_install opendkim opendkim-tools

# Start OpenDKIM do not need cuz after installation it will start itself
#service opendkim start



# apache aid 3






exit 0


# TODO(tim): do it with vps_configuration
####################################################################################################
#### Justeuro: External References Used To Improve This Script (Thanks, Interwebz) ###############
####################################################################################################

## Ref: https://linuxize.com/post/secure-apache-with-let-s-encrypt-on-ubuntu-18-04/
## Ref: https://stackoverflow.com/questions/49172841/
