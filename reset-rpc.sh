#!/usr/bin/env bash
#
# RPC helper script stuff to "reset" RPC interface setup on a node and validator server
#

echo -e "ARE YOU SURE YOU WANT TO RESET RPC DATA ON THE VALIDATOR?\n"
read -p "Press [Enter] to Continue"

# restore service backup files and restart client services
sudo mv /etc/systemd/system/geth.service.BACKUP /etc/systemd/system/geth.service

sudo systemctl daemon-reload
sudo systemctl restart geth

echo -e "\nProcess is complete"
