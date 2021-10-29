######################################
# SFTP
# TODO(tim): try it out and make some aliases
######################################

# Download a single file from a remote ftp server to your machine:
#   sftp {user}@{host}:{remoteFileName} {localFileName}

# Upload a single file from your machine to a remote ftp server:
#   sftp {user}@{host}:{remote_dir} <<< $'put {local_file_path}'


##### LFTP
# lftp sftp://[user name]@[domain name]:[port number]
############# $ lftp sftp://sftptim@190.92.134.248:7822


#### Run this to not get prompt for password
## because lftp will read empty password after ',' and then check for ssh keys
# lftp -u username, sftp://hostname
############# $ lftp -u sftptim, sftp://190.92.134.248:7822
# Ref: https://unix.stackexchange.com/questions/181781/using-lftp-with-ssh-agent