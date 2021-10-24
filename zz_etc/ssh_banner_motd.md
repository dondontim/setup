# LEGAL Notices for Login/MOTD unix banners
# Ref: https://gist.github.com/hvmonteiro/7f897cd8ae3993195855040056f87dc6


### Display SSH Warning Message BEFORE the Login
# The SSH warning messages are commonly located in the files ‘/etc/issue’ and ‘/etc/issue.net’

Banner /etc/ssh/sshd-banner

###############################################################
#                  This is a private server!                  #
#       All connections are monitored and recorded.           #
#  Disconnect IMMEDIATELY if you are not an authorized user!  #
###############################################################


### Msg after login
/etc/motd

######################################
# If you are not authorized to access#
# or use this system, disconnect now #
######################################