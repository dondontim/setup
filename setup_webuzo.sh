 
##### Temporary passwords

#<input type="text" class="form-control"      name="uname" id="uname" value="dontim" required>
#<input type="email" class="form-control"     name="email" id="email" value="krystatymoteusz@gmail.com" onchange="softmail();" required>
#<input type="password" class="form-control"  name="pass" id="pass" value="tymek2002" required>
#<input type="password" class="form-control"  name="rpass" id="rpass" value="tymek2002" required>
#<input type="text" class="form-control"      name="domain" id="domain" value="justeuro.eu" required>
#<input type="text" class="form-control"      name="ns1" id="ns1" value="ns1.justeuro.eu">
#<input type="text" class="form-control"      name="ns2" id="ns2" value="ns2.justeuro.eu">
#<input type="text" class="form-control"      name="lic" id="lic" value="">
#<input type="hidden"                         name="submit" value="Install Webuzo" />
#<input type="submit" class="btn btn-primary" name="submit_" id="softsubmitbut" value="Install">

#uname="dontim" # can not be system username
#email="krystatymoteusz@gmail.com"
#pass="tymek2002"
#rpass="tymek2002"
#domain="justeuro.eu"
#ns1="ns1.justeuro.eu"
#ns2="ns2.justeuro.eu"
#submit_="Install"
#lic=''
#submit='Install Webuzo'

## This is a checkbox with warning
#[force_install]='on'





# POST /install.php HTTP/1.1
# Host: 190.92.134.248:2004
# Content-Length: 161
# Cache-Control: max-age=0
# Upgrade-Insecure-Requests: 1


  #[force_install]='on'
declare -A webuzo_array=( 
  [uname]='dontim' 
  [email]='krystatymoteusz@gmail.com'
  [pass]='tymek2002' 
  [rpass]='tymek2002' 
  [domain]='justeuro.eu' 
  [ns1]='ns1.justeuro.eu' 
  [ns2]='ns2.justeuro.eu'
  [lic]=''
  [submit]='Install Webuzo' 
  [submit_]='Install' 
)

data=''

for i in "${!webuzo_array[@]}"
do
  # echo "key  : $i"
  # echo "value: ${webuzo_array[$i]}"

  # append to a variable
  data+="${i}=${webuzo_array[$i]}&"
done
# cut last 1 character from varable
data=${data::-1}



server_external_ip=$(curl -s https://ipecho.net/plain; echo)
ip_at_port="http://${server_external_ip}:2004"
webuzo_url="${ip_at_port}/install.php"


### Example nr 1
#curl -d "$data" -X POST "$webuzo_url"
#curl -d "param1=value1&param2=value2" -X POST http://localhost:3000/data


### Example nr 2


#force_install=on&force_install=on&
data='uname=tymek2211&email=krystatymoteusz%40gmail.com&pass=tymek2002&rpass=tymek2002&domain=justeuro.eu&ns1=ns1.justeuro.eu&ns2=ns2.justeuro.eu&lic=&submit=Install+Webuzo'

curl  -d "$data" \
      -H "Origin: ${ip_at_port}" \
      -H "Content-Type: application/x-www-form-urlencoded" \
      -H "Referer: ${webuzo_url}" \
      -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9" \
      -H "Accept-Encoding: gzip, deflate" \
      -H "Accept-Language: en-GB,en-US;q=0.9,en;q=0.8,pl;q=0.7" \
      -H "Connection: close" \
      -X POST "$webuzo_url"






# Alternative if would not work
# https://stackoverflow.com/a/51145033


# fixed nginx config














file_templates_dir="${PWD}/z_file_templates"


function replace_php_ini() {
  # PHP.INI
  # Make backup of old and replace php.ini
  #
  phpini_main_config_file_path=$(php -i | grep 'Loaded Configuration File' | awk -F '=> ' '{ print $2 }')

  if [ "$phpini_main_config_file_path" = '(none)' ]; then
    echo "Error finding path to main php.ini configuration file"
    echo "You will need to replace it manually!"
  else
    date=$(date '+%Y-%m-%d')
    # Create backup or old php.ini
    mv $phpini_main_config_file_path "${phpini_main_config_file_path}.${date}.bak"
    # Move new php.ini to the place of old one
    cp "${file_templates_dir}/php.ini.example" $phpini_main_config_file_path
  fi

}