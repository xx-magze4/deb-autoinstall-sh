#!/bin/bash

# global
password='9b8nx0nBvDH9daCc7uJu9g'
wallet='NKNZFZoqcTth6uFNHURQdgrqoiURGW1dzbAH'
success_msg='NKN installed, restarting...'

# run commands as root
sudo apt update && sudo apt -y upgrade && sudo apt -y autoremove && sudo apt clean && echo -e "$password\n$password\n\n\n\n\n\n\n" | sudo adduser nkn && sudo usermod -aG sudo nkn

# run commands as nkn
su - nkn<<NKN_USER
$password
  echo -e "$password\n" | sudo -S apt -y install make git && wget "https://golang.org/dl/go1.15.7.linux-amd64.tar.gz" && sudo tar -C /usr/local -xzf go1.15.7.linux-amd64.tar.gz && export PATH=$PATH:/usr/local/go/bin
  
  git clone https://github.com/nknorg/nkn.git &&
  cd nkn && make && cp config.mainnet.json config.json
  sed "s/\"BeneficiaryAddr\": .*/\"BeneficiaryAddr\": \"$wallet\",/" config.json > temp_conf.json && mv temp_conf.json config.json && cat config.json
  echo -e "$password\n$password\n" | ./nknc wallet -c
  touch ~/nkn.service
  
  # create service
cat > ~/nkn.service <<SERVICE_FILE
  [Unit]
  Description=nkn
  [Service]
  User=nkn
  WorkingDirectory=/home/nkn/nkn
  ExecStart=/home/nkn/nkn/nknd -p "$password"
  Restart=always
  RestartSec=3
  LimitNOFILE=500000
  [Install]
  WantedBy=default.target
SERVICE_FILE

  sudo cp ~/nkn.service /etc/systemd/system/nkn.service && sudo systemctl enable nkn.service && echo "$success_msg" && sudo reboot
NKN_USER
