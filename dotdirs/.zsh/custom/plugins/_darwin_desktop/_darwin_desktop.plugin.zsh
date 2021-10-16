fname='_darwin_desktop'
echo "[$(date +'%H:%M:%S')]: ${fname}"

source_whole_dir "${ZSH_CUSTOM}/plugins/${fname}/src"


# TODO(tim): this is redundant with zsh.sh (it can be caused that it is bash
# - zsh.sh and it is not reading it here)
[[ -z "$OS_DEPENDENT" ]] && export OS_DEPENDENT="$ZSH_CUSTOM/os_dependent"
source_whole_dir "${OS_DEPENDENT}/desktop"


##### FROM .ZPROFILE

#export HTDOCS='/Applications/XAMPP/xamppfiles/htdocs/'
#export HOST='MacBookPro'

##
# MacOS/X specific
##
# Finder: show dotfiles
#
# to hide dotfiles change to 'false'
#defaults write com.apple.Finder AppleShowAllFiles true
# killall Finder # if you run above you'll need to re-open all Finder


# TEMPORARY
# alias rm="echo Use 'del', or the full path i.e. '/bin/rm'"