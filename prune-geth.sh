#!/usr/bin/env bash
#
# PulseChain Validator Helper Script for Pruning Geth Data
#
# Description
# - Allows you to prune geth blockchain data to reduce disk space usage on the validator
#
# You can setup a cron job to do this automatically every quarter or 6 months,
# otherwise if you don't do the maintence, depending on your disk size, it can
# fill up and cause your validator to stop working properly
#
# See official docs for more info
# - https://geth.ethereum.org/docs/fundamentals/pruning
#

NODE_USER="node"
GETH_DIR="/opt/geth"
GETH_DATA="/opt/geth/data"

echo -e "ARE YOU SURE YOU WANT TO PRUNE GETH BLOCKCHAIN DATA ON THE VALIDATOR? (this could take a few hours)\n"
read -p "Press [Enter] to Continue"

# stop geth
sudo systemctl stop geth

# run prune command (could take a few hours)
sudo -u $NODE_USER $GETH_DIR/build/bin/geth --datadir $GETH_DATA snapshot prune-state

# start geth
sudo systemctl start geth

echo -e "\nProcess is complete (if you see snapshot is not old enough message, then try again later)"
