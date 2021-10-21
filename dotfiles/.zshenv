echo "[$(date +'%H:%M:%S')]: .zshenv"

# env - command prints all enviromental variables

# Google Shell Style Guide
# https://google.github.io/styleguide/shellguide.html#s4.1-file-header

# Path to .zsh config directory
export ZSH="$HOME/.zsh"


# Other zsh config files path
export ZDOTDIR="$ZSH"



# TODO(tim): if .bashrc or othrer file wont be ran on ssh, source here manualy:
#if [ -f ~/.bashrc ]; then
#  . ~/.bashrc
#fi
#
# if running ZSH
if [ -n "$ZSH_VERSION" ]; then
  # include .zshrc if it exists
  if [ -f "$ZDOTDIR/.zshrc" ]; then
    . "$ZDOTDIR/.zshrc"
  fi
fi


# TODO(tim): sometimes below bindings in key-bindings.zsh dont work
# bindkey "[C" forward-word
# bindkey "[D" backward-word

# Zsh/Bash startup files loading order
# https://medium.com/@rajsek/zsh-bash-startup-files-loading-order-bashrc-zshrc-etc-e30045652f2e
#
# +----------------+-----------+-----------+------+
# |                |Interactive|Interactive|Script|
# |                |login      |non-login  |      |
# +----------------+-----------+-----------+------+
# |/etc/zshenv     |    A      |    A      |  A   |
# +----------------+-----------+-----------+------+
# |~/.zshenv       |    B      |    B      |  B   |
# +----------------+-----------+-----------+------+
# |/etc/zprofile   |    C      |           |      |
# +----------------+-----------+-----------+------+
# |~/.zprofile     |    D      |           |      |
# +----------------+-----------+-----------+------+
# |/etc/zshrc      |    E      |    C      |      |
# +----------------+-----------+-----------+------+
# |~/.zshrc        |    F      |    D      |      |
# +----------------+-----------+-----------+------+
# |/etc/zlogin     |    G      |           |      |
# +----------------+-----------+-----------+------+
# |~/.zlogin       |    H      |           |      |
# +----------------+-----------+-----------+------+
# |                |           |           |      |
# +----------------+-----------+-----------+------+
# |                |           |           |      |
# +----------------+-----------+-----------+------+
# |~/.zlogout      |    I      |           |      |
# +----------------+-----------+-----------+------+
# |/etc/zlogout    |    J      |           |      |
# +----------------+-----------+-----------+------+
#
# The files in /etc/ will be launched (when present) for all users. 
# The .z* files only for the individual user.
