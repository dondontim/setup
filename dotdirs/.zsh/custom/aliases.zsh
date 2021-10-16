#echo "[$(date +'%H:%M:%S')]: $ZSH_CUSTOM/aliases.zsh"
#######################################
# Normalize
#######################################

alias sudo='sudo -E' # -E indicates to preserve user existing environment variables.

## super user alias
alias _='sudo '

#alias vim='sudo vim'

# confirmation #
alias mv='mv -i' # make mv ask before overwriting a file by default
alias cp='cp -i'
alias ln='ln -i'

# -p create any nessesary parent direcories and 
# -v confirm in such way every directory
alias mkdir="mkdir -pv"

alias md='mkdir -p'
alias rd='rmdir'

# -c : continue the download in case of problems.
alias wget='wget -c'

# The search is done from left to right, and if more than one matches are found 
# in the directories listed in the PATH path variable, which will print 
# only the first one. To print all matches, use the -a option:
alias which='which -a'

# LS 
# 
# * -lA is show list and all files
# * -h  When used with the -l option, use unit suffixes: Byte, Kilobyte,
#       Megabyte, Gigabyte, Terabyte and Petabyte in order to reduce the num-
#       ber of digits to three or less using base 2 for sizes.
# * -F  Display a slash (`/') immediately after each pathname that is a
#       directory, an asterisk (`*') after each that is executable, an at
#       sign (`@') after each symbolic link etc
# * -G  Enable colorized output.  This option is equivalent to defining
#       CLICOLOR in the environment. (See man ls)

alias lsl='ls -lF'
alias lsa='ls -AF'
alias {lsla,l,ll,la,lslla,lslsa,lslah}='ls -lAFh' # h for human-readable filesize
alias lslh='ls -lh'


alias lS='ls -Ss'
alias las='ls -aSs'
alias lls='ls -lS'
alias {llas,lals}='ls -lAS'
alias lc='ls --color=none'


command_exists htop && {
  alias top="htop"
}


######################################
# Reboot / Shut down
######################################

# sudo shutdown [FLAGS] <time>
#
# Replace <time> with the specific time. 
# If you want to do it immediately, type now. 
# If you want in an hour, type +60.
# -h : shutdown
# -r : reboot
# -s : sleep
alias {off,off_machine}="sudo shutdown -h now"
alias {reboot, reboot_machine}="sudo shutdown -r now"
alias sleep_machine="sudo shutdown -s now"

alias lgout="logout"


# Always enable colored `grep` output
# Note: `GREP_OPTIONS="--color=auto"` is deprecated, hence the alias usage.
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias G="grep"
alias Gi="grep -i"
alias L="less"
alias devnull="2> /dev/null"


# Start calculator with math support
alias {bc,calc,calculator}='bc -l'

# You can compare files line by line using diff and use a tool 
# called colordiff to colorize diff output:
# install  colordiff package :)
alias diff='colordiff'

# Make mount command output pretty and human readable format
alias mount='mount | column -t'

# Print each PATH entry on a separate line
alias path='echo -e ${PATH//:/\\n}'  # pretty print $PATH
alias now='date +"%T"'
alias nowtime=now
alias nowdate='date +"%d-%m-%Y"'

alias cal='cal -3'
alias calendar='cal'
alias today='date "+%A, %B %-d, %Y"'
# Get week number
alias week='date +%V'

#######################################
# Wrappers
#######################################
this_file_name=$(basename $0)
CUSTOM_ALIASES="${ZSH_CUSTOM}/${this_file_name}"
CUSTOM_FUNCTIONS="${ZSH_CUSTOM}/functions.zsh"


# Shortcuts
alias {desk,desktop}="cd ~/Desktop"
alias {downloads,donwloads}="cd ~/Downloads"
#alias db="cd ~/Documents/Dropbox"


# IP addresses
alias myip="curl https://ipecho.net/plain; echo"
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
#alias ip="curl -4 icanhazip.com"
alias localip="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"


# Reload the shell (i.e. invoke as a login shell)
alias {reload,r}="exec ${SHELL} -l"
#alias {reload,r}=". ${ZSH}/.zshrc"

alias zrc="${EDITOR} ${ZSH}/.zshrc"
alias zrc_functions="${EDITOR} ${CUSTOM_FUNCTIONS}"
alias zrc_aliases="${EDITOR} ${CUSTOM_ALIASES}"

alias c='clear'
alias {back,b}='cd "$OLDPWD"'

# View list of aliases in your source file
alias {lsaliases,lsalias,aliasesls}="grep -in --color -e '^alias\s+*' ${CUSTOM_ALIASES} | sed 's/alias //' | grep --color -e ':[{a-z0-9,}]*'"
# Below line disable colored via grep alone ':' marks
#   * alias lsaliases="grep -in --color -e '^alias\s+*' ${CUSTOM_ALIASES} | sed 's/alias //' | grep --color -e ':[a-z0-9{][a-z0-9,}]*'"
# Below line is original but i have not single aliases but bulk so i changed regex
#   * alias lsaliases="grep -in --color -e '^alias\s+*' ${CUSTOM_ALIASES} | sed 's/alias //' | grep --color -e ':[a-z][a-z0-9]*'"


# Outputs exit status of a previous ran command
alias {prev_exit_status,prev_cmd_status,prev_status}='echo $?'

# Git
alias {gini,ginit}="git init"
alias gadd='git add .'
alias glog='git log'
alias gsta='git status'

alias gdf='git diff'
alias gca='git commit -a'
alias gt='git --no-pager'
alias gst='gt status --porcelain -s'


#######################################
# Abbreviations
#######################################

alias {py,p}="python3"

alias {wh,wi}='which'
alias hi='highlight'



#######################################
# Mis-spelled commands
#######################################

alias {bim,cim}='vim'
alias les='less'
alias mkdor='mkdir'
alias {cd..,cu}='cd ..'
alias {wwhich,whcih,whihc}='which'
alias {pyython3,pytohn3,pyhton3}='python3'
alias {relaod,reoad,reloda}='reload'
alias {celear,cear}='clear'
alias {exi,xit}="exit"
