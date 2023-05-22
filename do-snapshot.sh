#!/usr/bin/env bash
#
# PulseChain Snapshot helper script to backup blockchain data for transferring from one server to another
#
# Description
# - Takes a snapshot of blockchain data on a fully synced validator so it can be copied over and
# used to bootstrap a new validator -- clients must be stopped until the snapshot completes,
# afterwards they will be restarted so the validator can resume normal operation
#
# Environment
# - Tested on Ubuntu 22.04 (validator server) running Geth and Lighthouse clients
#
# What to do after running this script
# - Copy the geth.tar.xz and lighthouse.tar.xz (compressed like ZIP files) over to the new validator
# server (see scp demo below OR use a USB stick)
#
# $ scp geth.tar.xz ubuntu@new-validator-server-ip:/home/ubuntu
# $ scp lighthouse.tar.xz ubuntu@new-validator-server-ip:/home/ubuntu
#
# - Then you can run the following commands ON THE NEW SERVER
#
# $ sudo systemctl stop geth lighthouse-beacon lighthouse-validator
# $ tar -xJf geth.tar.xz
# $ tar -xJf lighthouse.tar.xz
# $ sudo cp -Rf opt /
# $ sudo chown -R node:node /opt
# $ sudo systemctl start geth lighthouse-beacon lighthouse-validator
#
# Note: this should work fine for Ethereum too as it's just copying the blockchain data directories
# for Geth and Lighthouse, but the scenario is technically untested; also, this relies on the new
# validator setup (which you are copying the snapshot to) to be setup with this repo's setup script
#

GETH_DATA="/opt/geth/data"
LIGHTHOUSE_BEACON_DATA="/opt/lighthouse/data/beacon"

LANDING_DIR=$HOME # default (change as needed)
TMP_DIR="/tmp/"

GETH_SNAPSHOT=$TMP_DIR"geth.tar.xz"
LIGHTHOUSE_SNAPSHOT=$TMP_DIR"lighthouse.tar.xz"

trap sigint INT

function sigint() {
    exit 1
}

echo -e "ARE YOU SURE YOU WANT TO TEMPORARILY STOP CLIENTS TO TAKE A SNAPSHOT ON THE VALIDATOR?\n"
echo -e "* it could take anywhere from a few hours to a couple days to complete -- depending mostly on blockchain data size and server specs *\n"
read -p "Press [Enter] to Continue"

# install xz (if not already installed)
sudo apt install -y xz-utils

# stop client services
sudo systemctl stop geth lighthouse-beacon lighthouse-validator

# compress geth directory
sudo -u node bash -c "tar -cJf $GETH_SNAPSHOT $GETH_DATA &>/dev/null"

# compress lighthouse directory
sudo -u node bash -c "tar -cJf $LIGHTHOUSE_SNAPSHOT $LIGHTHOUSE_BEACON_DATA &>/dev/null"

# fix perms
sudo chown -R $USER:$USER $GETH_SNAPSHOT
sudo chown -R $USER:$USER $LIGHTHOUSE_SNAPSHOT

# move snapshots to landing directory
mv $GETH_SNAPSHOT $LANDING_DIR
mv $LIGHTHOUSE_SNAPSHOT $LANDING_DIR

# start client services
sudo systemctl start geth lighthouse-beacon lighthouse-validator

echo -e "\nProcess is complete"
