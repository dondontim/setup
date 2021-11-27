alias {show_ports,showports,show_listening_ports}='netstat -tuplen'



alias root="sudo su -"
# That way I can root to switch to root or even root someuser to switch to someuser.


function ss() {
  # the standard 'ss' output is horrible. we can
  # make it more readable by piping to `column`
  $(which ss) $1 | column -t
}





# listening command
# https://gist.github.com/Frick/0c22207f0445477a66e9
source <(curl -s https://gist.githubusercontent.com/Frick/0c22207f0445477a66e9/raw/d3774af2bcae3e803cc700cff35e77b21384a52b/%2520listening.sh)

# openfiles command
# https://gist.github.com/Frick/1e0d77121cee39bad831
source <(curl -s https://gist.githubusercontent.com/Frick/1e0d77121cee39bad831/raw/dc13fe341f1c736de499a188d1cf5aff7d89473e/%2520openfiles.sh)



# To list all processes in the system:
alias process="ps -aux"
# To check the status of any system service:
alias sstatus="sudo systemctl status"
# To restart any system service:
alias srestart="sudo systemctl restart"



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