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

# Name of the user to grant privileges and ownership
USERNAME=tim


# Primary domain (without http(s) scheme) name to create a directory structure
PRIMARY_DOMAIN='justeuro.eu'

file_templates_dir="${PWD}/z_file_templates"

lib_dir_name='after_initial'

# MySQL user credentials
db_username='database_manager'
db_password='aoeu'



########################
### HELPER FUNCTIONS ###
########################

#. "./${lib_dir_name}/nginx.sh"
#. "./${lib_dir_name}/apache.sh"
. "./${lib_dir_name}/lib.sh"





####################
### SCRIPT LOGIC ###
####################

initialization >> "$LOG_FILE"



remove_apache >> "$LOG_FILE"


install_webuzo

cat <<EOF




EOF

if [ "$STACK" = 'LEMP' ]; then
  install_LEMP
else
  install_LAMP
fi









exit 0


# TODO(tim): do it with vps_configuration
####################################################################################################
#### Justeuro: External References Used To Improve This Script (Thanks, Interwebz) ###############
####################################################################################################

## Ref: https://linuxize.com/post/secure-apache-with-let-s-encrypt-on-ubuntu-18-04/
## Ref: https://stackoverflow.com/questions/49172841/
