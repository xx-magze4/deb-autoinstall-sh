#!/bin/bash

# global
password='9b8nx0nBvDH9daCc7uJu9g'
wallet='NKNZFZoqcTth6uFNHURQdgrqoiURGW1dzbAH'
success_msg='NKN installed, restarting...'

# update PATH
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# run commands as root
apt update && apt -y upgrade && apt -y autoremove && apt clean
wget "https://golang.org/dl/go1.15.7.linux-amd64.tar.gz" &&
tar -C /usr/local -xzf go1.15.7.linux-amd64.tar.gz &&
export PATH=$PATH:/usr/local/go/bin &&
printf "\nPATH=\$PATH:/usr/local/go/bin\n" >> /etc/profile
echo -e "$password\n$password\n\n\n\n\n\n\n" | adduser nkn && usermod -aG sudo nkn

# run commands as nkn
su - nkn<<NKN_USER
$password
  echo -e "$password\n" | sudo -S apt install make git
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
