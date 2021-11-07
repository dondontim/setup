#!/bin/bash
#
# Create symlinks source - dotfiles and destination in $HOME


echo "Linked dotfiles. Please restart your shell. "

# Create symlinks to all dotfiles from and ~/
for f in "${user_to_setup_for_home_directory}/setup/dotfiles/\.[^.]*"; do
  FILE="$(basename $f)"
  ln -sf "${user_to_setup_for_home_directory}/setup/dotfiles/${FILE}" "$user_to_setup_for_home_directory"
  # No need cuz whole setup dir is users ownership
  #chown -R "${user_to_setup_for}:${user_to_setup_for}" "${user_to_setup_for_home_directory}/${FILE}"
done