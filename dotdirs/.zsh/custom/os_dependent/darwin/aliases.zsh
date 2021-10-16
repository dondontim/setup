


alias {r,reopn,reopren}='reopen'
alias brwe='brew'


function open_in_brave() {
osascript <<EOF
  tell application "Brave Browser" to open location "$@"
EOF
}
function muza muzyczka() {
  # alias {muza,muzyczka}="open_command https://www.youtube.com/playlist?list=PL_yAlCSE43waScu6Ojbvap9G-umGGfPJC"
  open_in_brave https://www.youtube.com/playlist?list=PL_yAlCSE43waScu6Ojbvap9G-umGGfPJC
}
function techno() {
  # alias techno="open_command https://www.youtube.com/playlist?list=PL_yAlCSE43waC7rWaTB85O-uY-VexaE5p"
  open_in_brave https://www.youtube.com/playlist?list=PL_yAlCSE43waC7rWaTB85O-uY-VexaE5p
}
function tomorrowland oneworldradio tmrrwland() {
  # alias {tomorrowland,oneworldradio}="open_command https://www.youtube.com/watch?v=DY_rFed96mg"
  open_in_brave https://www.youtube.com/watch?v=DY_rFed96mg
}



#######################################
# Only on current system
#######################################

alias htdocs='cd /Applications/XAMPP/xamppfiles/htdocs/'
alias xampp='sudo /Applications/XAMPP/xamppfiles/xampp'

# Never try to alias rm better use trash-cli etc 
# alias rm='rm -i'
# explaination: https://unix.stackexchange.com/a/261452


