#/bin/bash

version=v24.10.31
wget https://github.com/XTLS/Xray-core/releases/download/${version}/Xray-linux-64.zip
unzip Xray-linux-64.zip -d /usr/bin/xray
rm Xray-linux-64.zip
mkdir /etc/xray
touch /etc/xray/config.json
useradd xray
groupadd xray
cp xray.service /etc/systemd/system
systemctl daemon-reload
systemctl enable xray
service xray start
service xray status
