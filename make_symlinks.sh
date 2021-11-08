#!/bin/bash
#
# Create symlinks source - dotfiles and destination in $HOME



# Create symlinks to all dotfiles from and ~/

for f in "${user_to_setup_for_home_directory}"/setup/dotfiles/.*; do
  [ -e "$f" ] || continue
  FILE="$(basename "$f")"
  [ "$FILE" = "." ] && continue
  [ "$FILE" = ".." ] && continue
  #echo "${user_to_setup_for_home_directory}/${FILE}"
  ln -sf "$f" "${user_to_setup_for_home_directory}/${FILE}"
done

#echo "${user_to_setup_for_home_directory}/setup/dotfiles/${FILE}"
#ln -sf "${user_to_setup_for_home_directory}/setup/dotfiles/${FILE}" "$user_to_setup_for_home_directory"

#if ln -sf "${user_to_setup_for_home_directory}/setup/dotfiles/${FILE}" "$user_to_setup_for_home_directory/${FILE}"; then
#  echo "(+) Linked: ${user_to_setup_for_home_directory}/setup/dotfiles/${FILE} to -> ${user_to_setup_for_home_directory}/${FILE}"
#else
#  echo "(-) Failed linking: ${user_to_setup_for_home_directory}/setup/dotfiles/${FILE}"
#fi

# No need cuz whole setup dir is users ownership
#chown -R "${user_to_setup_for}:${user_to_setup_for}" "${user_to_setup_for_home_directory}/${FILE}"

echo "Linked dotfiles. Please restart your shell. "