#!/bin/bash

# check if root user is running the script
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

if [ ! -x "$(command -v socat)" ]; then sudo apt install -y socat; fi
if [ ! -x "$(command -v screen)" ]; then sudo apt install -y screen; fi

# get current ip address of the machine and store it in a variable called ip using hostname -I | cut -d ' ' -f 1
ip=$(hostname -I | cut -d ' ' -f 1)

# get current date and store it in a variable called date
date=$(date +%Y-%m-%d)

# check if $1 is given as an argument
if [ -z "$1" ]; then
  echo "Please provide a port number"
  exit 1
fi

# check if $1 is given as an argument and if it is a valid port number (1-65535) and if it is not already in use by another process (check if socat is already running on that port)
if [ -z "$1" ] || [ "$1" -lt 1 ] || [ "$1" -gt 65535 ] || [ "$(ps -A | grep -c "socat")" -gt 1 ]; then
  echo "Please provide a valid port number (1-65535) and make sure socat is not already running on that port"
  exit 1
fi

# check if the directory /etc/crat_config exists and create it if it doesn't
if [ ! -d "/etc/crat_config" ]; then
  mkdir /etc/crat_config
fi

# check if the file /etc/crat_config/crat.log exists and rename it to /etc/crat_config/crat.$date.old if it does
if [ -f /etc/crat_config/crat.log ]; then
  mv /etc/crat_config/crat.log /etc/crat_config/crat.$date.old
else 
  touch /etc/crat_config/crat.log
fi

echo "Running crat host on $ip"
echo "CRAT_HOST: IP: $ip:$1"

# run 'socat file:`tty`,raw,echo=0 tcp-listen:$1' in a screen session and log the output to /etc/crat_config/crat.log
sudo socat file:`tty`,raw,echo=0 tcp-listen:$1