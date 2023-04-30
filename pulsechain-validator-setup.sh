#!/usr/bin/env bash
#
# PulseChain Testnet Validator Node Setup Script for Ubuntu Linux
#
# Description
# - Installs pre-reqs, golang, rust, go-pulse (geth fork) and lighthouse on a fresh, clean Ubuntu OS
# for getting a PulseChain Testnet (V4) Validator Node setup and running.
#
# Usage
# $ ./pulsechain-testnet-validator-setup.sh [0x...YOUR PULSECHAIN FEE ADDRESS] [12.89...YOUR SERVER IP ADDRESS]
#
# Command line options
# - PULSECHAIN FEE ADDRESS is the FEE_RECIPIENT value for --suggested-fee-recipient to a wallet address you want
# to recieve priority fees from users whenever your validator proposes a new block (else it goes to the burn address)
#
# - SERVER_IP_ADDRESS to your validator server's IP address
#
# Environment
# - Tested on Ubuntu 22.04 (on Amazon AWS EC2 /w M2.2Xlarge VM) running as a non-root user (ubuntu) with sudo privileges
#
# Notes
# *IMPORTANT* things to do AFTER RUNNING THIS SCRIPT to complete the node setup
#
# 1) Generate validator keys with deposit tool and import them into lighthouse
#
# Make sure to generate your keys on a different, secure machine (NOT on the validator server) and transfer them over for import
#
# 2) Start the validator client
#
# 3) Once the blockchain clients are synced, you can make your 32m tPLS deposit (per validator, can have multiple on one machine)
# at the launchpad and get your validator activated and participating on the network.
#
# (see README for more detailed info)
#
# Now let's get validating! @rhmaximalist
#

# general config
NODE_USER="node"
FEE_RECIPIENT=$1
SERVER_IP_ADDRESS=$2

APT_PACKAGES="build-essential cmake clang git wget jq protobuf-compiler"

# chain flags
GETH_CHAIN="pulsechain-testnet-v4"
LIGHTHOUSE_CHAIN="pulsechain_testnet_v4"

# geth config
GETH_DIR="/opt/geth"
GETH_DATA="/opt/geth/data"

GETH_REPO="https://gitlab.com/pulsechaincom/go-pulse.git"
GETH_REPO_NAME="go-pulse"

JWT_SECRET_DIR="/var/lib/jwt"

# lighthouse config
LIGHTHOUSE_DIR="/opt/lighthouse"
LIGHTHOUSE_BEACON_DATA="/opt/lighthouse/data/beacon"
LIGHTHOUSE_VALIDATOR_DATA="/opt/lighthouse/data/validator"

LIGHTHOUSE_REPO="https://gitlab.com/pulsechaincom/lighthouse-pulse.git"
LIGHTHOUSE_REPO_NAME="lighthouse-pulse"

LIGHTHOUSE_PORT=9000
LIGHTHOUSE_CHECKPOINT_URL="https://checkpoint.v4.testnet.pulsechain.com"

################################################################

trap sigint INT

function sigint() {
    exit 1
}

# initial check for script arguments (fee address and IP options)
if [ -z "$2" ]; then
    echo "* requires fee address and IP args, read the script notes and try again"
    exit 1
fi

echo -e "PulseChain TESTNET V4 Validator Setup\n"
echo -e "Note: this is a HELPER SCRIPT (some steps still need completed manually, see notes after script is finished)\n"
echo -e "* it could take around 30 minutes to complete -- depending mostly on bandwidth and server specs *\n"

read -p "Hit [Enter] to continue"

# keep track of directory where we run the script
pushd $PWD &>/dev/null

echo -e "\nstep 1: install requirements and setting up golang + rust\n"

# install dependencies and setup path
sudo apt-get update
sudo apt-get install -y $APT_PACKAGES
sudo snap install --classic go

echo "export PATH=$PATH:/snap/bin" >> ~/.bashrc

# straight from rustup.rs website /w auto accept default option "-y"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"

echo -e "\nstep 2: adding node user and generate client secrets"

# add node account to run services
sudo useradd -m -s /bin/false -d /home/$NODE_USER $NODE_USER

# generate execution and consensus client secret
sudo mkdir -p $JWT_SECRET_DIR
openssl rand -hex 32 | sudo tee $JWT_SECRET_DIR/secret > /dev/null
sudo chown -R $NODE_USER:$NODE_USER $JWT_SECRET_DIR
sudo chmod 400 $JWT_SECRET_DIR/secret

echo -e "\nstep 3: setting up and running Go-Pulse (execution client) to start syncing data\n"

# geth setup
git clone $GETH_REPO
sleep 0.5 # ugh, wait
sudo mv $GETH_REPO_NAME $GETH_DIR
cd $GETH_DIR
make

# add geth to path
export PATH=$PATH:$GETH_DIR/build/bin

# geth data directory
mkdir -p $GETH_DATA
sudo chown -R $NODE_USER:$NODE_USER $GETH_DIR

sudo tee /etc/systemd/system/geth.service > /dev/null <<EOT
[Unit]
Description=Geth (Go-Pulse)
After=network.target
Wants=network.target

[Service]
User=$NODE_USER
Group=$NODE_USER
Type=simple
Restart=always
RestartSec=5
ExecStart=$GETH_DIR/build/bin/geth \
--$GETH_CHAIN \
--datadir=$GETH_DATA \
--http \
--http.api=engine,eth,net,admin,debug \
--authrpc.jwtsecret=$JWT_SECRET_DIR/secret\


[Install]
WantedBy=default.target
EOT

sudo systemctl daemon-reload
sudo systemctl enable geth
sudo systemctl start geth
#sudo systemctl status geth

# sudo systemctl status geth (check status of geth and make sure it started OK)
# syncing could a few hours or days depending on the server specs and network connection

echo -e "\nstep 4: setting up Lighthouse (beacon and consensus client) -- you need to start/enable it manually AFTER generating and importing your validator keys\n"

# go back to the directory where we started the script
popd

# lighthouse setup
cd ~
git clone $LIGHTHOUSE_REPO
sleep 0.5 # ugh, wait
sudo mv $LIGHTHOUSE_REPO_NAME $LIGHTHOUSE_DIR
cd $LIGHTHOUSE_DIR
make

# setup lighthouse beacon data, validator data and wallet directories
sudo mkdir -p $LIGHTHOUSE_VALIDATOR_DATA

sudo chown -R $NODE_USER:$NODE_USER $LIGHTHOUSE_DIR

# make symbolic link to lighthouse (make service binary in ExecStart nicer)
sudo -u $NODE_USER ln -s /home/$NODE_USER/.cargo/bin/lighthouse /opt/lighthouse/lighthouse/lh

sudo tee /etc/systemd/system/lighthouse-beacon.service > /dev/null <<EOT
[Unit]
Description=Lighthouse Beacon
After=network.target
Wants=network.target

[Service]
User=$NODE_USER
Group=$NODE_USER
Type=simple
Restart=always
RestartSec=5
ExecStart=$LIGHTHOUSE_DIR/lighthouse/lh bn \
--network $LIGHTHOUSE_CHAIN \
--datadir=$LIGHTHOUSE_BEACON_DATA \
--execution-endpoint=http://localhost:8551 \
--execution-jwt=$JWT_SECRET_DIR/secret \
--enr-address=$SERVER_IP_ADDRESS \
--enr-tcp-port=$LIGHTHOUSE_PORT \
--enr-udp-port=$LIGHTHOUSE_PORT \
--suggested-fee-recipient=$FEE_RECIPIENT \
--checkpoint-sync-url=$LIGHTHOUSE_CHECKPOINT_URL \
--http

[Install]
WantedBy=multi-user.target
EOT

sudo systemctl daemon-reload
sudo systemctl enable lighthouse-beacon
sudo systemctl start lighthouse-beacon
#sudo systemctl status lighthouse-beacon

sudo tee /etc/systemd/system/lighthouse-validator.service > /dev/null <<EOT
[Unit]
Description=Lighthouse Validator
After=network.target
Wants=network.target

[Service]
User=$NODE_USER
Group=$NODE_USER
Type=simple
Restart=always
RestartSec=5
ExecStart=$LIGHTHOUSE_DIR/lighthouse/lh vc \
--network $LIGHTHOUSE_CHAIN \
--suggested-fee-recipient=$FEE_RECIPIENT

[Install]
WantedBy=multi-user.target
EOT

sudo systemctl daemon-reload
sudo systemctl enable lighthouse-validator
#sudo systemctl start lighthouse-validator
#sudo systemctl status lighthouse-validator

# make sure the new user (running the clients) has rust env stuff
sudo mkdir /home/$NODE_USER/.cargo
sudo chown $NODE_USER:$NODE_USER /home/$NODE_USER/.cargo
sudo cp -R ~/.cargo/* /home/$NODE_USER/.cargo

echo -e "\nstep 5: setting up firewall to allow node connections (make sure you open them on your network firewall too)\n"

# firewall rules to allow go-pulse and lighthouse services
sudo ufw allow 30303/tcp
sudo ufw allow 30303/udp
sudo ufw allow 9000/tcp
sudo ufw allow 9000/udp

echo -e "\nAlmost done! Follow these next steps (as described in the notes) to finish setup and be the best validator you can be :)\n"

echo -e "- Generate validator keys with deposit tool ON A SECURE, DIFFERENT MACHINE\n"
echo -e "- Import them into lighthouse via 'lighthouse account validator import --directory ~/validator_keys --network=pulsechain_testnet_v4' AS THE NODE USER\n"
echo -e "- Start the validator client via 'sudo systemctl start lighthouse-validator'\n"
echo -e "- WAIT UNTIL YOUR CLIENTS ARE SYNCED and then make your 32m tPLS deposit on the launchpad @ https://launchpad.v4.testnet.pulsechain.com\n"

echo -e "See any errors? Check permissions, missing packages or debug client failures with 'journalctl -u [service name].service' (eg. lighthouse-beacon.service)\n"
