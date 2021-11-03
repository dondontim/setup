#######################################
# My stuff
#######################################

# Server and system ogs
error_log='/var/log/nginx/error.log'
access_log='/var/log/nginx/access.log'
export error_log access_log 

syslog='/var/log/syslog'
sys_log=$syslog
export syslog sys_log


##### LOGGING USERS
# you can find who logged in when (and from where) in the file:
### On Ubuntu servers, 
# /var/log/auth.log
### On Red Hat based distros such as Fedora/CentOS/RHEL:
# /var/log/secure.


### If you want to have login attempts included in the log file, 
# you'll need to edit the /etc/ssh/sshd_config file (as root or with sudo) 
# and change the LogLevel from INFO to VERBOSE.


function sshlog ssh_log() {
  ### When you’re logged in via SSH use the following command to view 
  # last 100 lines of your SSH log:
  #
  ## tail /var/log/auth.log -n 100
  # or even cleaner
  tail -100 /var/log/auth.log | grep 'sshd'
}

function sshfailed failedssh failed_ssh_attempts() {
  # Must read ref
  # Ref: https://www.tecmint.com/find-failed-ssh-login-attempts-in-linux/
  # Ref: https://askubuntu.com/a/178019 # Also great!


### UBUNTU
  grep "Failed password" /var/log/auth.log

  echo "In order to display extra information about the failed SSH logins, issue the command:"
  echo 'egrep "Failed|Failure" /var/log/auth.log'
  # egrep "Failed|Failure" /var/log/auth.log

### REDHAT (slightly modified commands)

  #egrep "Failed|Failure" /var/log/secure
  #grep "Failed" /var/log/secure
  # grep "authentication failure" /var/log/secure
}


function gitcheatsheet gcheatsheet() {
  # -L, --location      Follow redirects
  # -o, --output <file> Write to file instead of stdout
  # -v, --verbose       Make the operation more talkative  

  # output to terminal or write to passed file
  # curl -L [URL]
  # curl -Lv [URL] -o $1 

  curl -L https://gist.githubusercontent.com/davfre/8313299/raw/2c3ead2ab1d34e7f866785faccb50c93e0b4f78c/git_cheat-sheet.md
}
