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

# Webuzo .zip archive with settings
# Ref: https://www.softaculous.com/docs/admin/import-export-settings/
WEBUZO_SETTINGS_TO_IMPORT=



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


exit 0


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
# MySQL
# PHP
# phpMyAdmin
#
#### Mail apps to install on webuzo
# Exim
# Dovecot
# RainLoop webmail # sid 497 # or Roundcube # sid 118
# BIND # DNS software to setup MX record
# SpamAssassin # Install Exim before





exit 0


# TODO(tim): do it with vps_configuration
####################################################################################################
#### Justeuro: External References Used To Improve This Script (Thanks, Interwebz) ###############
####################################################################################################

## Ref: https://linuxize.com/post/secure-apache-with-let-s-encrypt-on-ubuntu-18-04/
## Ref: https://stackoverflow.com/questions/49172841/
