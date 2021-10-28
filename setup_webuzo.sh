 
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

#uname="dontim"
#email="krystatymoteusz@gmail.com"
#pass="tymek2002"
#rpass="tymek2002"
#domain="justeuro.eu"
#ns1="ns1.justeuro.eu"
#ns2="ns2.justeuro.eu"
#submit_="Install"
#lic=''
#submit='Install Webuzo' 


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
webuzo_url="http://${server_external_ip}:2004/install.php"


#curl -d "param1=value1&param2=value2" -X POST http://localhost:3000/data
curl -d "$data" -X POST "$webuzo_url"

# Alternative if would not work
# https://stackoverflow.com/a/51145033