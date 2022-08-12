#!/bin/bash

sudo apt update && sudo apt install curl -y &>/dev/null
sudo apt-get update && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC sudo apt-get install -y --no-install-recommends tzdata git ca-certificates libclang-dev cmake &>/dev/null
if [ ! $NODENAME_GEAR ]; then
	read -p "Введи ім'я ноди(тільки букви і цифри): " NODENAME_GEAR
fi
echo 'Твоя нода: ' $NODENAME_GEAR
sleep 1
echo 'export NODENAME='$NODENAME_GEAR >> $HOME/.profile
echo "Триває встановлення..."

curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_rust.sh | bash &>/dev/null
sudo apt install --fix-broken -y &>/dev/null
sudo apt install nano mc git mc clang curl jq htop net-tools libssl-dev llvm libudev-dev -y &>/dev/null
source $HOME/.profile &>/dev/null
source $HOME/.bashrc &>/dev/null
source $HOME/.cargo/env &>/dev/null
sleep 1 && curl -s https://raw.githubusercontent.com/f5nodes/logo/main/logo-shark.sh | bash && sleep 1

wget https://builds.gear.rs/gear-nightly-linux-x86_64.tar.xz &>/dev/null
tar xvf gear-nightly-linux-x86_64.tar.xz &>/dev/null
rm gear-nightly-linux-x86_64.tar.xz &>/dev/null
chmod +x $HOME/gear-node &>/dev/null


sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald


sudo tee <<EOF >/dev/null /etc/systemd/system/gear.service
[Unit]
Description=Gear Node
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/
ExecStart=/root/gear-node \
        --name $NODENAME_GEAR \
        --execution wasm \
	--port 31333 \
        --telemetry-url 'ws://telemetry-backend-shard.gear-tech.io:32001/submit 0' \
	--telemetry-url 'wss://telemetry.postcapitalist.io/submit 0'
Restart=always
RestartSec=10
LimitNOFILE=10000

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl restart systemd-journald &>/dev/null
sudo systemctl daemon-reload &>/dev/null
sudo systemctl enable gear &>/dev/null
sudo systemctl restart gear &>/dev/null

echo "Нода встановлена та працює!"