######################################
# SFTP
# TODO(tim): try it out and make some aliases
######################################

# Download a single file from a remote ftp server to your machine:
#   sftp {user}@{host}:{remoteFileName} {localFileName}

# Upload a single file from your machine to a remote ftp server:
#   sftp {user}@{host}:{remote_dir} <<< $'put {local_file_path}'