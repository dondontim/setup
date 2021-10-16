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






function gitcheatsheet gcheatsheet() {
  # -L, --location      Follow redirects
  # -o, --output <file> Write to file instead of stdout
  # -v, --verbose       Make the operation more talkative  

  # output to terminal or write to passed file
  # curl -L [URL]
  # curl -Lv [URL] -o $1 

  curl -L https://gist.githubusercontent.com/davfre/8313299/raw/2c3ead2ab1d34e7f866785faccb50c93e0b4f78c/git_cheat-sheet.md
}
