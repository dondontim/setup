
function setup_webuzo() 
{
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


    # [force_install]='on'
    # [force_install]='on'
    # [uname]='dontim'
    # [email]='krystatymoteusz@gmail.com'
    # [pass]='tymek2002'
    # [rpass]='tymek2002'
    # [domain]='justeuro.eu'
    # [ns1]='ns1.justeuro.eu'
    # [ns2]='ns2.justeuro.eu'
    # [lic]=''
    # [submit]='Install Webuzo'
    # [submit_]='Install'
  declare -A webuzo_array=(
    [uname]='tymek22'
    [email]='krystatymoteusz%40gmail.com'
    [pass]='tymek2002'
    [rpass]='tymek2002'
    [domain]='justeuro.eu'
    [ns1]='ns1.justeuro.eu'
    [ns2]='ns2.justeuro.eu'
    [lic]=''
    [submit]='Install+Webuzo'
  )
  # TODO(tim): replace with $PRIMARY_DOMAIN

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


  #force_install=on&force_install=on&
  #data='uname=tymek2211&email=krystatymoteusz%40gmail.com&pass=tymek2002&rpass=tymek2002&domain=justeuro.eu&ns1=ns1.justeuro.eu&ns2=ns2.justeuro.eu&lic=&submit=Install+Webuzo'

  curl  -L -d "$data" \
        -H "Origin: ${ip_at_port}" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -H "Referer: ${webuzo_url}" \
        -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9" \
        -H "Accept-Encoding: gzip, deflate" \
        -H "Accept-Language: en-GB,en-US;q=0.9,en;q=0.8,pl;q=0.7" \
        -H "Connection: close" \
        -X POST "$webuzo_url"





  # Alternative if above would not work
  # https://stackoverflow.com/a/51145033

}


# Run main function
setup_webuzo