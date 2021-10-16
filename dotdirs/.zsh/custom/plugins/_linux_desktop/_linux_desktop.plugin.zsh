fname='_linux_desktop'
echo "[$(date +'%H:%M:%S')]: ${fname}"

source_whole_dir "${ZSH_CUSTOM}/plugins/${fname}/src"


# TODO(tim): this is redundant with zsh.sh (it can be caused that it is bash
# - zsh.sh and it is not reading it here)
[[ -z "$OS_DEPENDENT" ]] && export OS_DEPENDENT="$ZSH_CUSTOM/os_dependent"
source_whole_dir "${OS_DEPENDENT}/desktop"


#######################################
# Connect bluetooth device via terminal
#######################################
#
# https://unix.stackexchange.com/questions/96693/connect-to-a-bluetooth-device-via-terminal
# or bluetoothctl
# or hcitool



# Get GPU ram on desktop / laptop##
alias gpumeminfo='grep -i --color memory /var/log/Xorg.0.log'



alias {muza,muzyczka}="open_command https://www.youtube.com/playlist?list=PL_yAlCSE43waScu6Ojbvap9G-umGGfPJC"
alias techno="open_command https://www.youtube.com/playlist?list=PL_yAlCSE43waC7rWaTB85O-uY-VexaE5p"
alias {tomorrowland,oneworldradio,tmrrwland}="open_command https://www.youtube.com/watch?v=DY_rFed96mg"
