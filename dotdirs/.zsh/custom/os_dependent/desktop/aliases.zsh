alias {vps_,vps_info,vps_web,my_vps,myvps}="open_command https://my.a2hosting.com/clientarea.php?action=productdetails&id=473513"


function howto wikihowto() {
  if [[ $# -eq 0 ]]; then
    open_command https://www.wikihow.com
  else
    web_search google "$@ site:wikihow.com" 
  fi
}

alias {pogoda_h,pogodah}="open_command https://weather.com/pl-PL/weather/hourbyhour/l/5af100124a9fc3dce7e9aa2bdb2743a5a8b14eae03c0ca77e15d47c49f5b8b77#detailIndex4"
alias {pogoda_d,pogodad}="open_command https://weather.com/pl-PL/pogoda/10dni/l/5af100124a9fc3dce7e9aa2bdb2743a5a8b14eae03c0ca77e15d47c49f5b8b77"
alias {pogoda_m,pogodam}="open_command https://weather.com/pl-PL/pogoda/miesieczne/l/5af100124a9fc3dce7e9aa2bdb2743a5a8b14eae03c0ca77e15d47c49f5b8b77"




alias diffchecker="open_command https://www.diffchecker.com"
alias {googledrive,gdriveweb,gdrivegui}="open_command https://drive.google.com/drive/u/0/my-drive"
alias {translate,trans,gtrans}='open_command https://translate.google.pl'
alias regex="open_command https://regexr.com"
alias {asciitab,table_generator}="open_command https://ozh.github.io/ascii-tables/"
alias {advanced_search,advanced,advs}="open_command https://www.google.com/advanced_search"
alias {gitcheatsheet,gcheatsheet}="open_command https://gist.github.com/davfre/8313299"

# Server IP and PORT
SERVER_IP='190.92.134.248'
PORT='7822'
alias sshtim="ssh tim@${SERVER_IP} -p ${PORT}"
alias sshroot="ssh root@${SERVER_IP} -p ${PORT}"
alias sftptim="sftp -P ${PORT} tim@${SERVER_IP}"


alias code.="code ."
alias {g,gogle}='google'
alias yt='youtube'
alias trnas='trans'
alias {stack,overflow}='stackoverflow'



alias 2048='bash <(curl -s https://raw.githubusercontent.com/mydzor/bash2048/master/bash2048.sh)'
alias pomodoro='pydoro'


# Downloads a .mp3 file
# Extract audio from video
# if you ever wish to uninstall youtube-dl run: brew remove ffmpeg && brew remove youtube-dl
function dlmp3 ytgetaudio() {
  sudo youtube-dl --extract-audio --audio-format mp3 $1
}

function dlmp4 ytgetvideo() {
  youtube-dl -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best' $1
}

# Kill all the tabs in Chrome to free up memory
# [C] explained: http://www.commandlinefu.com/commands/view/402/exclude-grep-from-your-grepped-output-of-ps-alias-included-in-description
alias chromekill="ps ux | grep '[C]hrome Helper --type=renderer' | grep -v extension-process | tr -s ' ' | cut -d ' ' -f2 | xargs kill"
