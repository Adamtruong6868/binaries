#!/bin/bash
exists()
{
  command -v "$1" >/dev/null 2>&1
}
if exists curl; then
echo ''
else
  sudo apt update && sudo apt install curl -y < "/dev/null"
fi

# Logo
sleep 1 && curl -s https://raw.githubusercontent.com/vnbnode/binaries/main/Logo/logo.sh | bash && sleep 1

cd $HOME

# Need install software and its updates
echo -e "\e[1m\e[32m1. Install software and its updates... \e[0m" && sleep 1
sudo apt install -y jq bc gnupg2 curl software-properties-common
curl -o - https://releases.algorand.com/key.pub | sudo tee /etc/apt/trusted.gpg.d/algorand.asc
sudo add-apt-repository "deb [arch=amd64] https://releases.algorand.com/deb/ stable main"
sleep 1

# Install Node Algorand
echo -e "\e[1m\e[32m2. Install Node Algorand... \e[0m" && sleep 1
sudo apt update
sudo apt install -y algorand
sudo systemctl stop algorand
sudo systemctl disable algorand 
sleep 1

# Configure Node VOI
echo -e "\e[1m\e[32m3. Configure Node VOI... \e[0m" && sleep 1
echo "export ALGORAND_DATA=/var/lib/algorand/" >> $HOME/.bashrc && source $HOME/.bashrc
sudo algocfg set -p DNSBootstrapID -v "<network>.voi.network" -d /var/lib/algorand/
sudo algocfg set -p EnableCatchupFromArchiveServers -v true -d /var/lib/algorand/
sudo chown algorand:algorand /var/lib/algorand/config.json
sudo chmod g+w /var/lib/algorand/config.json
sudo curl -s -o /var/lib/algorand/genesis.json https://testnet-api.voi.nodly.io/genesis
sudo chown algorand:algorand /var/lib/algorand/genesis.json
sudo cp /lib/systemd/system/algorand.service /etc/systemd/system/voi.service
sudo sed -i 's/Algorand daemon/Voi daemon/g' /etc/systemd/system/voi.service
sleep 1

# Start Node VOI
echo -e "\e[1m\e[32m4. Start Node VOI... \e[0m" && sleep 1
systemctl daemon-reload
sudo systemctl start voi && sudo systemctl enable voi
goal node status
goal node catchup $(curl -s https://testnet-api.voi.nodly.io/v2/status|jq -r '.["last-catchpoint"]')
goal node status -w 1000
rm $HOME/voi-auto.sh
