https://gist.github.com/Frick/0c22207f0445477a66e9
https://gist.github.com/Frick/1e0d77121cee39bad831


# https://twitter.com/liamosaur/status/506975850596536320
alias fuck='sudo $(history -p \!\!)'
# But better one here
# https://github.com/nvbn/thefuck


alias root="sudo su -"
# That way I can root to switch to root or even root someuser to switch to someuser.


rtfm() { $@ --help 2> /dev/null || man $@ 2> /dev/null || open "http://www.google.com/search?q=$@"; } 
# This handy little function tries command --help, 
# then man command, if that doesn't bring anything back. 
# Finally, it tries a google search for the command as a fallback. Fantastic.

mkpasswd () { 
  # TODO(tim): passwd
  local _len=12;
  [[ -n "$1" ]] && _len="$1";
  tr -dc A-Z-a-z-0-9 < /dev/urandom | head -c$_len;
  echo
}

function ss() {
  # the standard 'ss' output is horrible. we can
  # make it more readable by piping to `column`
  $(which ss) $1 | column -t
}


# Just print the lines in a config file that actually do stuff:
alias nocomment='egrep -v "^\s*(#|$)"'


alias topo='top -n 1 -b | less'




# To list all processes in the system:
alias process="ps -aux"
# To check the status of any system service:
alias sstatus="sudo systemctl status"
# To restart any system service:
alias srestart="sudo systemctl restart"


# To display the total used and free memory of the system:
alias mem="free -h"
# To display the CPU architecture, number of CPUs, threads, etc. of the system:
alias cpu="lscpu"
# To display the total disk size of the system:
alias disk="df -h"



# To display the current system Linux distro
# Check release (what OS is installed)
function os get_os getos check_release() {
  if [ -f /etc/redhat-release ]; then
      RELEASE="centos"
  elif grep -Eqi "debian" /etc/issue; then
      RELEASE="debian"
  elif grep -Eqi "ubuntu" /etc/issue; then
      RELEASE="ubuntu"
  elif grep -Eqi "centos|red hat|redhat" /etc/issue; then
      RELEASE="centos"
  elif grep -Eqi "debian" /proc/version; then
      RELEASE="debian"
  elif grep -Eqi "ubuntu" /proc/version; then
      RELEASE="ubuntu"
  elif grep -Eqi "centos|red hat|redhat" /proc/version; then
      RELEASE="centos"
  fi
  echo "$RELEASE"
}

# View only mounted drives
alias mnt="mount | awk -F' ' '{ printf \"%s\t%s\n\",\$1,\$3; }' | column -t | egrep ^/dev/ | sort"
