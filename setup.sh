#!/bin/bash
#
# Setup a new machine from scratch

# 1. git clone it to homedir 
# 2. cd into
# 3. bash setup.sh


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

# This cannot be run as root cuz it will make changes for root
# -eq equals, -ne not equals
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  #echo "Do you want to make unpack the setup for root?"
  #echo "If not run again witout sudo"
  exit 1
fi

init




unameOut="$(uname -s)"
case "${unameOut}" in
  Linux*)     MACHINE=Linux;;
  Darwin*)    MACHINE=Mac;;
  CYGWIN*)    MACHINE=Cygwin;;
  MINGW*)     MACHINE=MinGw;;
  *)          MACHINE="UNKNOWN:${unameOut}"
esac




function check_if_user_exists() {
  if id "$1" &>/dev/null; then
    #echo 'user found'
    return 0
  else
    #echo 'user not found'
    return 1
  fi
}

### Read username of a user and check if he exists
# Uses: 'check_if_user_exists' function
while true; do
  echo ""
  echo "--> Type the existing username for which the setup have to be done by me? "
  echo ""
  read user_to_setup_for

  if check_if_user_exists "$user_to_setup_for"; then
    break;
  else
    echo ""
    echo "--> This user dont exist"
    continue
  fi
done
export user_to_setup_for
export user_to_setup_for_home_directory=$(eval echo "~$user_to_setup_for")



# if ! [ "$PWD" = "${user_to_setup_for_home_directory}/setup" ]; then
#   echo "You need to execute this file from: $user_to_setup_for_home_directory/setup"
#   exit 1
# fi




# . (dot) is abbreviation to source
if [[ "$MACHINE" == "Linux" ]]; then
  echo "Linux detected!"
  echo "Hi $(whoami) !"
  echo "Which version do you wish me to install? (type 1 or 2 and press Enter)"
  echo "1. Desktop Linux"
  echo "2. Server  Linux"

  read TYPE
  if [ "$TYPE" -eq 1 ]; then
    . linux/desktop/setup.sh
  elif [ "$TYPE" -eq 2 ]; then
    . linux/server/setup.sh
  else
    echo "Wrong choice! Exiting..."
    exit 1
  fi
elif [[ "$MACHINE" == "Mac" ]]; then
  . mac/setup.sh
else
  echo "$MACHINE"
fi


#####
##### Not really needed but nice things
#####
#
### Fuck - Command which corrects your previous console command.
# https://github.com/nvbn/thefuck

