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
  # Read about sshd_config directives:
  # Ref: https://man7.org/linux/man-pages/man5/sshd_config.5.html

  # Ref: https://www.digitalocean.com/community/tutorials/how-to-harden-openssh-on-ubuntu-18-04

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

  
  echo "ChallengeResponseAuthentication no" >> "$sshd_config"
  echo "KerberosAuthentication no" >> "$sshd_config"
  echo "GSSAPIAuthentication no" >> "$sshd_config"
  echo "X11Forwarding no" >> "$sshd_config"
  echo "PermitUserEnvironment no" >> "$sshd_config" # If you add this, comment also 'AcceptEnv'
  edit_sshd_config "^AcceptEnv.*$" "#AcceptEnv LANG LC_*" 
  echo "DebianBanner no" >> "$sshd_config"



  ### Additional configurations from reference
  # OpenSSH server configuration
  # Ref: https://www.ssh.com/academy/ssh/sshd_config
  #
  # Setting persistent encryption
  echo "Ciphers aes128-ctr,aes192-ctr,aes256-ctr" >> "$sshd_config"
  echo "HostKeyAlgorithms ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,ecdsa-sha2-nistp521,ssh-rsa,ssh-dss" >> "$sshd_config"
  echo "KexAlgorithms ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group14-sha1,diffie-hellman-group-exchange-sha256" >> "$sshd_config"
  echo "MACs hmac-sha2-256,hmac-sha2-512,hmac-sha1" >> "$sshd_config"
  # Managing port tunneling and forwarding
  echo "AllowTcpForwarding no" >> "$sshd_config"
  echo "AllowStreamLocalForwarding no" >> "$sshd_config"
  echo "AllowAgentForwarding no" >> "$sshd_config"
  echo "GatewayPorts no" >> "$sshd_config"
  echo "PermitTunnel no" >> "$sshd_config"


  # You need to create separate sftp user cuz normal user with my .zshrc and stuff will produce: 
  # Received message too long 1530015802 \n Ensure the remote shell produces no output for non-interactive sessions.
  # Or you set in sshd_config:

  # Subsystem
  # Ref: https://unix.stackexchange.com/a/327284
  edit_sshd_config "^Subsystem.*$" "Subsystem sftp internal-sftp" 


  # TODO(tim): setup sftp only user
  # Run here creation of sftp user or no
}


function create_sftp_only_group() {
  # Great reference: 
  # https://www.thegeekstuff.com/2012/03/chroot-sftp-setup/

  SFTP_GROUP='sftpusers'
  SFTP_USER='sftptim'
  SFTP_DIR='/sftp'

  USERS_HOME_DIR="${SFTP_DIR}/${SFTP_USER}"

  # Create a New Group
  groupadd "$SFTP_GROUP"

  # Create User
  # make his Home directory as /incoming
  useradd -g "$SFTP_GROUP" -d "$USERS_HOME_DIR" --shell "/usr/sbin/nologin" "$SFTP_USER"
  
  # Set a password for this user
  while true; do
    if passwd "$SFTP_USER"; then
      # If above command returns 0 exit code (success) -> break
      break
    fi
  done

  # This in sshd_config will help create a tightly restricted SFTP-only user account
  cat <<EOF >> "$sshd_config"
Match Group $SFTP_GROUP
  ForceCommand internal-sftp
  ChrootDirectory /sftp/%u
EOF
# TODO(tim): replace with $SFTP_DIR

  # Create sftp Home Directory
  mkdir "$SFTP_DIR"
  # Now, under /sftp, create the individual directories for the users who are 
  # part of the sftpusers group. i.e the users who will be allowed only 
  # to perform sftp and will be in chroot environment.


  # /sftp/guestuser is equivalent to / for the guestuser. 
  # When guestuser sftp to the system, and performs “cd /”, they’ll be seeing
  # only the content of the directories under “/sftp/guestuser” 
  # (and not the real / of the system). This is the power of the chroot.
  mkdir "$USERS_HOME_DIR"
  # /sftp == ChrootDirectory

  # So, under this directory /sftp/guestuser, create any subdirectory that you 
  # like user to see. For example, create a incoming directory where users can sftp their files.
  mkdir "${USERS_HOME_DIR}/incoming"

  # TODO(tim): short above 3 commands comments to one line below
  #mkdir -p "${USERS_HOME_DIR}/incoming"


  # Setup Appropriate Permission
  chown "$SFTP_USER":"$SFTP_GROUP" "${USERS_HOME_DIR}/incoming"

  ### Everything at the end should be like this
  # 755 guestuser sftpusers /sftp/guestuser/incoming
  # 755 root root /sftp/guestuser
  # 755 root root /sftp
  
  # TODO(tim): Think of shorting this below ssh keys handling with function above

  # Create SSH directory for sftp user
  mkdir --parents "${USERS_HOME_DIR}/.ssh"

  # Copy `authorized_keys` file from root if requested
  if [ "${COPY_AUTHORIZED_KEYS_FROM_ROOT}" = true ]; then
    cp /root/.ssh/authorized_keys "${USERS_HOME_DIR}/.ssh"
  fi

  # Add additional provided public keys
  for pub_key in "${OTHER_PUBLIC_KEYS_TO_ADD[@]}"; do
    echo "${pub_key}" >> "${USERS_HOME_DIR}/.ssh/authorized_keys"
  done

  # Adjust SSH configuration ownership and permissions
  chmod 0700 "${USERS_HOME_DIR}/.ssh"
  chmod 0600 "${USERS_HOME_DIR}/.ssh/authorized_keys"
  chown --recursive "${SFTP_USER}" "${USERS_HOME_DIR}/.ssh"
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
  
  log_it "1) Initialization"                        "initialization" 
  
  echo ""
  echo "--> Creating new user '${USERNAME}' with sudo privileges"
  echo ""
  create_sudo_user
  echo ""

  log_it "2) Managing SSH keys"                     "handle_ssh_keys" 
  log_it "3) Changing ${sshd_config} directives"    "make_backup_of_sshd_config ; change_default_ssh_port ; change_some_ssh_directives"

  echo ""
  echo "--> Creating new SFTP-ONLY user restricted to home directory using chroot Jail"
  echo ""
  create_sftp_only_group
  echo ""
  
  
  log_it "4) Testing ${sshd_config} and restarting" "test_and_restart_ssh"
  log_it "5) Setting basic firewall rules"          "setup_basic_firewall"
  echo "--> DONE!"
}




 








main





# TODO(tim): make backup of ssh dir with old github keys and make new




function create_sftp_only_user() {
  

  SFTP_USER=sftptim

  # Create sftp user only with restricted shell access
  useradd --create-home --shell "/usr/sbin/nologin" "$SFTP_USER"
  #sudo adduser --shell /usr/lib/openssh/sftp-server sftptim # test

  # Set a password for this user
  while true; do
    if passwd "${SFTP_USER}"; then
      # If above command returns 0 exit code (success) -> break
      break
    fi
  done

  # This in sshd_config will help create a tightly restricted SFTP-only user account
  cat <<EOF >> "$sshd_config"
Match User $SFTP_USER
  ForceCommand internal-sftp
  ChrootDirectory %h # home directory. /home/%u equivalent or /home/${SFTP_USER}
EOF

  # WARNING: Within an OpenSSH configuration file, all configurations under a 
  # Match block will only apply to connections that match the criteria, regardless
  # of indentation or line breaks. This means that you must be careful and 
  # ensure that configurations intended to apply globally are not accidentally
  # put within a Match block. It is recommended to put all Match blocks 
  # at the bottom/end of your configuration file to help avoid this.

  # Teraz musimy stworzyć odpowiednie prawa dostępu do odpowiednich katalogów:
  sftp_user_home_dir="$(eval echo ~${SFTP_USER})"
  sftp_user_files_dir="${sftp_user_home_dir}/files"

  chown root "$sftp_user_home_dir"
  chmod go-w "$sftp_user_home_dir"

  mkdir "$sftp_user_files_dir"
  chown "$SFTP_USER" "$sftp_user_files_dir"
  chmod ug+rwX "$sftp_user_files_dir"
  # Po tej operacji użytkownik $SFTP_USER, może się zalogować do serwera przez sftp
  # i będzie miał dostęp jedynie do zapisu w katalogu $sftp_user_files_dir,
  # przy czym nie będzie miał możliwości wyjść poza katalog $sftp_user_home_dir.
}
