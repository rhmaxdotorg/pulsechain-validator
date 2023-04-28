#!/usr/bin/env bash
#
# PulseChain Testnet RPC Interface Helper Script
#
# Description
# - Enables the RPC interface so you can use your own node in Metamask on Firefox (only)
#
# Environment
# - Tested on Ubuntu 22.04 (Validator Server) + Mozilla Firefox /w Metamask (Client)
#
# What you need to do AFTER running this script
#
# If your RPC is...
# - On the same machine as Metamask, you can point it at 127.0.0.1
# - On VPS/cloud server, you can use SSH port forwarding and then point it at 127.0.0.1
# - On a different machine on your local network, open the port on the local firewall and point it at that local IP address
#
# Add your server to Metamask
# - Click the Network drop-down
# - Add Network
# - Add a Network Manaully
# -> Network name: Local PLS
# -> New RPC URL: http://local-network-server-IP:8564 OR http://127.0.0.1:8546 (running same machine OR port forwarded)
# -> Chain ID: 943 (for testnet v4)
# -> Currency symbol: tPLS
# -> Block explorer URL: https://scan.v4.testnet.pulsechain.com
# -> Save
#
# Note
# - Running your own node and using it can be used for testing purposes, not relying on public servers or bypassing slow,
# rate limited services by "doing it yourself". Do not expose your RPC publicly unless you know what you're doing.
#

# config
MOZ_FF_MM_EXTENSION="1a7c358b-6844-438f-a809-4d5a534020e5"
CORS_FLAG="--http.corsdomain=\"moz-extension:\/\/"$MOZ_FF_MM_EXTENSION\"

echo -e "RPC Setup for Metamask on Nodes and Validators\n"
read -p "Hit [Enter] to Continue OR Ctrl+C to Cancel"

# backup service file, update /w cors flag and reload service
sudo cp /etc/systemd/system/geth.service /etc/systemd/system/geth.service.BACKUP

sudo sed -i '12s/$/ '"$CORS_FLAG"'/' /etc/systemd/system/geth.service

sudo systemctl daemon-reload
sudo systemctl restart geth lighthouse-beacon lighthouse-validator

# firewall rules to allow geth rpc (for exposing it publicly or on the LAN, port forwarding doesn't need this)
#sudo ufw allow 8545/tcp

echo -e "\nAlmost done! Just follow the next steps (as described in the notes) for port forwarding & setup your Metamask.\n"
