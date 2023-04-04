#!/usr/bin/env bash
#
# PulseChain validator helper script stuff to "reset" things so you can try again
#

I_KNOW_WHAT_I_AM_DOING=false # CHANGE ME ONLY IF YOU TRULY UNDERSTAND

if [ "$I_KNOW_WHAT_I_AM_DOING" = false ]; then
    echo "Make sure you understand what this script does, then flip I_KNOW_WHAT_I_AM_DOING to true if you want to run it"
    exit 1
fi

echo -e "ARE YOU SURE YOU WANT TO RESET AND DELETE CLIENT DATA ON THE VALIDATOR?\n"
read -p "Press [Enter] to Continue"

# stop the client services
sudo systemctl stop geth &>/dev/null
sudo systemctl stop lighthouse-beacon &>/dev/null
sudo systemctl stop lighthouse-validator &>/dev/null

# remove the services and reload service daemon
sudo rm -rf /etc/systemd/system/geth.service
sudo rm -rf /etc/systemd/system/lighthouse*
sudo systemctl daemon-reload

# remove client data
sudo rm -rf /opt/*

# remove the user
sudo userdel -r node &>/dev/null

echo -e "\nProcess is complete"
