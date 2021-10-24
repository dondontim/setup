#!/bin/bash
#
# 

# Ref: https://www.digitalocean.com/community/tutorials/automating-initial-server-setup-with-ubuntu-18-04



set -euo pipefail


########################
### HELPER FUNCTIONS ###
########################



function apt_install() {
  sudo apt-get install -y "$@"
}

function update_and_upgrade() {
  sudo apt-get update -y && sudo apt-get upgrade -y
}




function replace_regex_in_file() 
{ 
  local pattern repl file
  pattern="$1"
  repl="$2"
  file="$3"
  #sed --in-place -E "s/${pattern}/${repl}/" "$3" # it was macos sed
  sed --in-place "s/${pattern}/${repl}/m" "$file"
  # -i == --in-place
}

function edit_sshd_config() 
{ 
  # Edit ssh config - $sshd_config
  replace_regex_in_file "$@" "$sshd_config"
}


function make_old_file_backup() {
  local file_path date
  file_path="$1"
  date=$(date '+%Y-%m-%d')
  cp "$file_path" "${file_path}.${date}.bak"
}







DEBUG=
LOG_FILE="/root/initial_server_setup.log"



#remote_machine_public_ip=$(curl -s https://ipecho.net/plain; echo)
sshd_config='/etc/ssh/sshd_config'
#file_templates_dir="${PWD}/z_file_templates"







########################
### SCRIPT VARIABLES ###
########################

# Name of the user to create and grant sudo privileges
USERNAME=tim

# Whether to copy over the root user's `authorized_keys` file to the new sudo
# user.
COPY_AUTHORIZED_KEYS_FROM_ROOT=false

# Additional public keys to add to the new sudo user
# OTHER_PUBLIC_KEYS_TO_ADD=(
#   "ssh-rsa AAAAB..."
#   "ssh-rsa AAAAB..."
# )
OTHER_PUBLIC_KEYS_TO_ADD=(
  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC+YLvFLyTnbrcBIRIU5OMf1ZHkxM04jP9L/gnQlEKn0kd2XGYkBd36QRN51M9nnmIjaVTORLmv2DA0CsMoQRdmL7TphMXeycA6xi82wrf5cvy9Qbtp1iv0VfZR2YfXmXJnyT7+LY99Qf4qbPmnFpu384HR17IdeXmKvQf8tCqJBzph/pBYFLjZQxR/lWFYnvZ3e7Tb+7/IKaacLcusZfc9lQ1i+SXQ/kEuscHjI4rOjmzWqY/VfFFV6mSAmXKIQxuypY/wWXYlUuYFfEug41sRWCROPT7f3NwVumiOwB1G+FCTP6YS9KMFvhzfLqdC0igZ5rHkkVtUFAcAdh349FdpGeaR3C/7KwN/d+rUCJ9rKPBnOTrFbCOmTA44wwCRGoPLTIrmIfXpZqg51+ZpEiZSdS/tNfmc+N74g3Phq7NBx5GWJRa4S51D1xpsFS+Ba5Yj/q9cBAPwBKFHe+m1hcl1f2bS3NRm9zaRTiLcnTT4hptexhanhj8PtWzhSVAz4a8= dontim@android-571979f94aa0e9ac"
)

CUSTOM_SSH_PORT=7822

PORTS_TO_BE_OPEN=(
  "OpenSSH" # Add exception for SSH default port 22
  "$CUSTOM_SSH_PORT"
  "21"
  "25"
  "80"
  "443"
)

####################
### SCRIPT LOGIC ###
####################



function initialization() {

  # This need to be run as root!
  if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
  fi

  update_and_upgrade

  apt_install ufw
  #apt_install curl

  disable_welcome_message
}




function create_sudo_user() {
  ### Add sudo user and grant privileges
  useradd --create-home --shell "/bin/bash" --groups sudo "${USERNAME}"
  # Set a password for this user
  while true; do
    if passwd "${USERNAME}"; then
      # If above command returns 0 exit code (success) -> break
      break
    fi
  done

  ### Alternatives
  # Create a new user
  #adduser --gecos "" "${USERNAME}"
  # Granting Administrative Privileges
  #usermod -aG sudo "${USERNAME}"
}






################################################################################
# Set up SSH keys                                                              #
################################################################################
function handle_ssh_keys() {
  # Create SSH directory for sudo user
  home_directory="$(eval echo ~${USERNAME})"
  mkdir --parents "${home_directory}/.ssh"

  # Copy `authorized_keys` file from root if requested
  if [ "${COPY_AUTHORIZED_KEYS_FROM_ROOT}" = true ]; then
    cp /root/.ssh/authorized_keys "${home_directory}/.ssh"
  fi

  # Add additional provided public keys
  for pub_key in "${OTHER_PUBLIC_KEYS_TO_ADD[@]}"; do
    echo "${pub_key}" >> "${home_directory}/.ssh/authorized_keys"
  done

  # Adjust SSH configuration ownership and permissions
  chmod 0700 "${home_directory}/.ssh"
  chmod 0600 "${home_directory}/.ssh/authorized_keys"
  chown --recursive "${USERNAME}":"${USERNAME}" "${home_directory}/.ssh"
}


################################################################################
# sshd_config
################################################################################

# TODO(tim): after tests if this is enough
# Original was this: ^PermitRootLogin.*

function make_backup_of_sshd_config() {
  # Create backup of previous $sshd_config
  make_old_file_backup "$sshd_config"
}


function change_default_ssh_port() {
  # If variable not null change server SSH port
  if [ -n "$CUSTOM_SSH_PORT" ]; then
    # Set non default port
    edit_sshd_config "^Port.*$" "Port ${CUSTOM_SSH_PORT}" # change: 'Port N'
    edit_sshd_config "GatewayPort.*$" "GatewayPort ${CUSTOM_SSH_PORT}" # change: 'GatewayPort N'
  fi
}


function change_some_ssh_directives() {

  ### PasswordAuthentication - Disable password authentication for all users
  edit_sshd_config "^#PasswordAuthentication.*$" "PasswordAuthentication no"

  ### PermitEmptyPasswords - 
  # When password authentication is allowed, it specifies whether the server 
  # allows login to accounts with empty password strings. The default is no.
  edit_sshd_config "^#PermitEmptyPasswords.*$" "PermitEmptyPasswords no"

  ### PermitRootLogin
  edit_sshd_config "^PermitRootLogin.*$" "PermitRootLogin no" 
  # alternative: PermitRootLogin without-password or prohibit-password


  ### ClientAliveInterval
  # Set SSH Connection Timeout Idle Value
  edit_sshd_config "^#ClientAliveInterval.*$" "ClientAliveInterval 600"


  ### ClientAliveCountMax
  # Total number of checkalive message sent by the ssh server 
  # without getting any response from the ssh client
  edit_sshd_config "^#ClientAliveCountMax.*$" "ClientAliveCountMax 0"


  ### MaxAuthTries
  # Configure a Limit for Password Attempts
  edit_sshd_config "^#MaxAuthTries.*$" "MaxAuthTries 3"

  ### LoginGraceTime
  # Allow 20 sec to login, if not disconnect
  edit_sshd_config "^#LoginGraceTime.*$" "LoginGraceTime 20"



  ### Protocol 2
  # Use more cryptographicaly secure protocol
  echo "Protocol 2" >> "$sshd_config"
  # To test if SSH protocol 1 is supported any more, run the command:
  # ssh -1 user@remote-IP
  #
  # ssh -2 user@remote-IP # for Protocol 2


  ### AllowUsers
  # Limit SSH Access to Certain Users
  #echo "AllowUsers user1 user2" >> "$sshd_config" # after space add other users
  # AllowGroups sysadmin dba



  # TODO(tim): More about hardening sshd_config:
  # https://www.digitalocean.com/community/tutorials/how-to-harden-openssh-on-ubuntu-18-04

}




function test_and_restart_ssh() {
  if sshd -t -q; then
    # How to restart ssh
    # https://www.cyberciti.biz/faq/how-do-i-restart-sshd-daemon-on-linux-or-unix/
    # TODO(tim): in original here was sshd. Find out why sshd or ssh


    # If you want to restart the ssh server on the other machine (e.g. if you changed the config) use
    ### sudo /etc/init.d/ssh restart
    # Yes it is called ssh although the process is called sshd which might be confusing.
    # Ref: https://serverfault.com/a/143365
    # GOD DAMN!!! 
    # Another conflicting Ref: https://askubuntu.com/a/462971
    #
    # THIS IS VERY NICE ONE!!!!: https://askubuntu.com/a/1070148
    systemctl restart sshd
  fi
}





################################################################################
# Setting Up a Basic Firewall                                                  #
################################################################################
function setup_basic_firewall() {
  # Add additional provided public keys
  for port in "${PORTS_TO_BE_OPEN[@]}"; do
    ufw allow "$port"
  done

  # start/enable UFW firewall
  ufw --force enable
}




function disable_welcome_message() {
  # Disable welcome message - https://askubuntu.com/a/676381 
  if [ -d "/etc/update-motd.d" ]; then 
    chmod -x /etc/update-motd.d/* 
    echo "--> disabled welcome msg"
  fi
}











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






function main() {

  ### Order
  #disable_welcome_message
  #create_sudo_user
  #handle_ssh_keys
  #make_backup_of_sshd_config
  #change_default_ssh_port
  #change_some_ssh_directives
  #test_and_restart_ssh
  #setup_basic_firewall
  

  
  # 1) Installing Libraries and Dependencies
  # 2) Setting UP WEBUZO

  
  #log_it "1) Disabling welcome message"               "disable_welcome_message"

  if [ "${DEBUG}" = true ]; then
    echo ""
    echo "DEBUG is On"
    echo "Log file → ${LOG_FILE}"
    echo ""
  fi
  
  log_it "1) Initialization"                         "initialization" 
  
  echo ""
  echo "--> Creating new user '${USERNAME}' with sudo privileges"
  echo ""
  create_sudo_user
  echo ""

  log_it "2) Managing SSH keys"                      "handle_ssh_keys" 
  log_it "3) Changing ${sshd_config} directives"     "make_backup_of_sshd_config ; change_default_ssh_port ; change_some_ssh_directives"
  log_it "4) Testing  ${sshd_config} and restarting" "test_and_restart_ssh"
  log_it "5) Setting basic firewall rules"           "setup_basic_firewall"
}





main





# TODO(tim): make backup of ssh dir with old github keys and make new

# TODO(tim): Add spinner

