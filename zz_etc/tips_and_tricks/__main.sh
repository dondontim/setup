

commandx |& tee -a file.log

### Install OpenDKIM
# We need to install and configure DKIM on our mail server so that the other email
# servers can authenticate the emails sent from our server and confirm that the emails
# are not forged or altered and the emails are authorized by the domain owner. 
# Use the below-mentioned commands to install OpenDKIM.
#apt_install opendkim opendkim-tools

# Start OpenDKIM do not need cuz after installation it will start itself
#service opendkim start



### How to Add an Existing User to a Group
# sudo usermod -a -G groupname username
# sudo usermod -a -G group1,group2 username
#
# id username
# groups username




# TODO(tim): do it with vps_configuration
####################################################################################################
#### Justeuro: External References Used To Improve This Script (Thanks, Interwebz) ###############
####################################################################################################

## Ref: https://linuxize.com/post/secure-apache-with-let-s-encrypt-on-ubuntu-18-04/
## Ref: https://stackoverflow.com/questions/49172841/


