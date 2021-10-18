#######################################
# Connect bluetooth device via terminal
#######################################
#
# brew install blueutil
#
# Print bluetooth status
# $ blueutil
alias bt='blueutil'

# Bluetooth on
# $ blueutil --power 1 or blueutil -p 1
alias {bt_on,bton}='blueutil --power 1'

# Bluetooth off
# $ blueutil --power 0 or blueutil -p 0
alias {bt_off,btoff}='blueutil --power 0'

# Get details about Bluetooth - devices paired, with their names, MAC address.
# 
# $ system_profiler SPBluetoothDataType
alias bt_details='system_profiler SPBluetoothDataType'


# Connect to bluetooth device via MAC Address 
# 
# brew install bluetoothconnector
# https://github.com/lapfelix/BluetoothConnector


# To toggle the connection (connect/disconnect) and be notified about it
function bt_toggle {
  BluetoothConnector "$@" --notify
}

# To connect and be notified about it
function bt_connect bt_conn {
  BluetoothConnector --connect "$@" --notify
  # BluetoothConnector -c "$@" --notify
}

# To disconnect
function bt_disconnect {
  BluetoothConnector --disconnect "$@"
  # BluetoothConnector -d "$@"
}


export MY_HEADSET_MAC_ADDR="64-72-D8-54-F7-B3"

alias {jbl_toggle,jbl}="bt_toggle ${MY_HEADSET_MAC_ADDR}"
alias {jbl_connect,jbl_conn}="bt_connect ${MY_HEADSET_MAC_ADDR}"
alias jbl_disconnect="bt_disconnect ${MY_HEADSET_MAC_ADDR}"



#######################################
# Checks if my Headset is connected
# Returns:
#   0 if bt is on
#   1 if bt is off
#######################################
function jbl_status() {
  local jbl_status
  jbl_status=$(BluetoothConnector --status ${MY_HEADSET_MAC_ADDR})
  if [ "${jbl_status}" = "Connected" ]; then
    #echo "${MY_HEADSET_MAC_ADDR} is Connected"
    return 0
  elif [ "${jbl_status}" = "Disconnected" ]; then
    #echo "${MY_HEADSET_MAC_ADDR} is Disconnected"
    return 1
  else
    echo "[${funcstack}]: Unrecognized bluetooth status"
    return 1
  fi
}

#######################################
# Bluetooth status
# Returns:
#   0 if bt is on
#   1 if bt is off
#######################################
function bt_status() {
  local result
  result=$(blueutil -p)
  if [ $result = "1" ]; then 
    # Bt is on
    return 0
  elif [ $result = "0" ]; then 
    # Bt is off
    return 1
  else
    echo "else"
    return 1
  fi
}

# Disconnects and connects my headset in case of a lag
function jbl_re jbl_reload jbl_reconnect bt_reconnect () {
  local return_code

  jbl_status
  return_code=$?

  if [ $return_code -eq 0 ]; then
    # Device connected
    # so disconnect and reconnect
    bt_disconnect ${MY_HEADSET_MAC_ADDR}
    bt_connect ${MY_HEADSET_MAC_ADDR}
  else
    # Device disconnected
    # so check if Bt is on
    bt_status
    return_code=$?
    if [ $return_code -eq 0 ]; then
      # Bt is on
      bt_connect ${MY_HEADSET_MAC_ADDR}
    else
      # Bt is off
      blueutil --power 1 # so turn it on
      bt_connect ${MY_HEADSET_MAC_ADDR}
    fi
  fi
}


