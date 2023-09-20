#!/usr/bin/env bash
#
# PulseChain client backup helper, this script will backup the clients before performing an
# update or restore the backed up clients to perform a rollback in case the new clients do not work
#

set -eo pipefail

NODE_USER="node"

# By default store the binaries in ~/backup
BACKUP_FOLDER="/home/$NODE_USER/backup"
LIGHTHOUSE_BACKUP="$BACKUP_FOLDER/lighthouse"
GETH_BACKUP="$BACKUP_FOLDER/geth"

GETH_BIN_PATH="/opt/geth/build/bin/geth"
LIGHTHOUSE_BIN_PATH="/home/node/.cargo/bin/lighthouse"

backup () {
    echo "Backing up binaries..."
    
    # Create backup directory if it doesn't exist
    sudo -u $NODE_USER test ! -d $BACKUP_FOLDER && sudo -u $NODE_USER bash -c "mkdir $BACKUP_FOLDER"

    # Copy binaries to backup folder
    sudo -u $NODE_USER bash -c "cp $GETH_BIN_PATH $LIGHTHOUSE_BIN_PATH $BACKUP_FOLDER"
}

restore () {
    # Check that the binaries are in the expected backup folder
    if sudo -u $NODE_USER test ! -f $LIGHTHOUSE_BACKUP || sudo -u $NODE_USER test ! -f $GETH_BACKUP; then
        echo "Either Geth or Lighthouse binary backup not found. Try running this command with the [backup] option first."
        exit 1
    fi

    echo "Versions to be restored:"
    echo "**************************"
    sudo -u node bash -c "$GETH_BACKUP --version"
    sudo -u node bash -c "$LIGHTHOUSE_BACKUP --version" | grep Lighthouse
    echo -e "**************************\n\n"

    echo -e "ARE YOU SURE YOU WANT TO REPLACE YOUR CURRENT CLIENT BINARIES WITH THE ONES BACKED UP?\n"
    echo "This operation can be reversed by running the update-client.sh script which will rebuild and restart the latest clients again"
    read -p "Hit [Enter] to Continue OR Ctrl+C to Cancel"
    
    echo "Restoring binaries..."
    
    # Using mv here to avoid having the same versions duplicated in storage and causing confusion
    sudo -u $NODE_USER bash -c "mv $GETH_BACKUP $GETH_BIN_PATH"
    sudo -u $NODE_USER bash -c "mv $LIGHTHOUSE_BACKUP $LIGHTHOUSE_BIN_PATH"

    echo "Restarting clients..."
    sudo systemctl restart geth lighthouse-beacon lighthouse-validator

    echo "Successfully restored backup versions"
}

case $1 in
    "backup")
        backup
        ;;
    "restore")
        restore
        ;;
    *)
        echo "Invalid command, valid commands are backup|restore"
        ;;
esac
