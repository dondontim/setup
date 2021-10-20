#!/bin/bash
#
# 

# Ref: https://www.digitalocean.com/community/tutorials/automating-initial-server-setup-with-ubuntu-18-04






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


function press_anything_to_continue() {
  read -n 1 -s -r -p "Press any key to continue"
  # -n defines the required character count to stop reading
  # -s hides the user's input
  # -r causes the string to be interpreted "raw" (without considering backslash escapes)
  echo ""
}


function apt_install() {
  sudo apt-get install -y "$@"
}

function update_and_upgrade() {
  sudo apt-get update -y && sudo apt-get upgrade -y
}






update_and_upgrade
apt_install ufw

# Disable welcome message - https://askubuntu.com/a/676381 
if [ -d "etc/update-motd.d" ]; then 
  chmod -x /etc/update-motd.d/* 
fi






set -euo pipefail

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

####################
### SCRIPT LOGIC ###
####################

# Add sudo user and grant privileges
useradd --create-home --shell "/bin/bash" --groups sudo "${USERNAME}"

# Check whether the root account has a real password set
encrypted_root_pw="$(grep root /etc/shadow | cut --delimiter=: --fields=2)"

if [ "${encrypted_root_pw}" != "*" ]; then
  # Transfer auto-generated root password to user if present
  # and lock the root account to password-based access
  echo "${USERNAME}:${encrypted_root_pw}" | chpasswd --encrypted
  passwd --lock root
else
  # Delete invalid password for user if using keys so that a new password
  # can be set without providing a previous value
  passwd --delete "${USERNAME}"
fi

# Expire the sudo user's password immediately to force a change
chage --lastday 0 "${USERNAME}"

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

# Disable root SSH login with password
sed --in-place 's/^PermitRootLogin.*/PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config
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

# Add exception for SSH and then enable UFW firewall
ufw allow OpenSSH

# If isset
if [ -n "$CUSTOM_SSH_PORT" ]; then
  ufw allow "$CUSTOM_SSH_PORT"
fi

ufw --force enable