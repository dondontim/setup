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
if [[ $EUID -eq 0 ]]; then
  #echo "This script must be run as root"
  echo "Do you want to make unpack the setup for root?"
  echo "If not run again witout sudo"
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


# After this run link.sh
