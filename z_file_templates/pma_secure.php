<?php

# PhpMyAdmin Settings
# This should be set to a random string of at least 32 chars
$cfg['blowfish_secret'] = 'CHANGE_THIS_TO_A_STRING_OF_32_RANDOM_CHARACTERS';

$i=0;
$i++;

$cfg['Servers'][$i]['auth_type'] = 'cookie';
$cfg['Servers'][$i]['AllowNoPassword'] = false;
$cfg['Servers'][$i]['AllowRoot'] = false;


# By including the AllowNoPassword and AllowRoot directives and setting both of them to false, 
# this configuration file disables passwordless logins and logins by the root MySQL user, respectively.


# Historically, phpMyAdmin instead used the Blowfish algorithm for this purpose. 
# However, it still looks for a directive named blowfish_secret, 
# which points to passphrase to be used internally by the AES algorithm. 
# This isn't a passphrase you need to remember, so any string containing 32 random characters will work here.
?>