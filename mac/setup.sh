#!/usr/bin/env bash


# Make symlinks
. $PWD/make_symlinks.sh
# Symlink only MacOS .dotfiles
ln -sf "$PWD/mac/.mdqlstyle.css" "$HOME"
ln -sf "$PWD/mac/.wakeup" "$HOME"
ln -sf "$PWD/mac/.sleep" "$HOME"
ln -sf "$PWD/mac/.plug" "$HOME"



##### Install .zsh, .vim

# Copy dotdirs to $HOME
cp -R $PWD/dotdirs/.zsh $PWD/dotdirs/.vim $HOME/ && {
  # Copy custom zsh per machine
  cp $PWD/mac/.zshrc_mac $HOME/.zsh/.zshrc
} || {
  echo "problem with dotdirs copying"
}

# Install Vundle
# $ git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
#
# Install Plugins:
# * Launch vim and run :PluginInstall
# * To install from command line: 
# $ vim +PluginInstall +qall



# TODO(tim): Import vscode settings and stuff



# Brew need to be first!

# Install apps and binaries with Brew
. $PWD/mac/brew.sh




# Configure MacOS defaults.
# You only want to run this once during setup. Additional runs may reset changes you make manually.
. $PWD/mac/.macos