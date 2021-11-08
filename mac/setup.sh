#!/usr/bin/env bash



# Symlink only MacOS .dotfiles
ln -sf "${user_to_setup_for_home_directory}/setup/mac/.mdqlstyle.css" "$user_to_setup_for_home_directory"
ln -sf "${user_to_setup_for_home_directory}/setup/mac/.wakeup" "$user_to_setup_for_home_directory"
ln -sf "${user_to_setup_for_home_directory}/setup/mac/.sleep" "$user_to_setup_for_home_directory"
ln -sf "${user_to_setup_for_home_directory}/setup/mac/.plug" "$user_to_setup_for_home_directory"






# Brew need to be first!

# Install apps and binaries with Brew
. $PWD/mac/brew.sh




# Configure MacOS defaults.
# You only want to run this once during setup. Additional runs may reset changes you make manually.
. $PWD/mac/.macos







# Install Vundle
# $ git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
#
# Install Plugins:
# * Launch vim and run :PluginInstall
# * To install from command line: 
# $ vim +PluginInstall +qall



# TODO(tim): Import vscode settings and stuff


cp "${user_to_setup_for_home_directory}/setup/mac/.zshrc_mac" "${user_to_setup_for_home_directory}/.zsh/.zshrc"
