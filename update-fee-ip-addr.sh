#!/usr/bin/env bash
#
# PulseChain Testnet Fee and IP Address Update Helper Script
#
# Description
# - Allows you to update your Network Fee Address and Server IP Address configured on the validator
#

I_KNOW_WHAT_I_AM_DOING=false # CHANGE ME ONLY IF YOU TRULY UNDERSTAND

if [ "$I_KNOW_WHAT_I_AM_DOING" = false ]; then
    echo "Make sure you understand what this script does, then flip I_KNOW_WHAT_I_AM_DOING to true if you want to run it"
    exit 1
fi

# initial check for script arguments (fee address and IP options)
if [ -z "$2" ]; then
    echo "* requires fee address and IP args, read the script notes and try again"
    exit 1
fi

FEE_RECIPIENT=$1
SERVER_IP_ADDRESS=$2

echo -e "ARE YOU SURE YOU WANT TO UPDATE YOUR NETWORK FEE RECIPIENT AND IP ADDRESS ON THE VALIDATOR?\n"
read -p "Press [Enter] to Continue"

# backup service files, update flags and reload services
sudo cp /etc/systemd/system/lighthouse-beacon.service /etc/systemd/system/lighthouse-beacon.service.BACKUP
sudo cp /etc/systemd/system/lighthouse-validator.service /etc/systemd/system/lighthouse-validator.service.BACKUP

sudo sed -i 's/--suggested-fee-recipient=[^\s]* /--suggested-fee-recipient='"$FEE_RECIPIENT"' /' /etc/systemd/system/lighthouse-validator.service
sudo sed -i 's/--suggested-fee-recipient=[^\s]* /--suggested-fee-recipient='"$FEE_RECIPIENT"' /' /etc/systemd/system/lighthouse-beacon.service
sudo sed -i 's/--enr-address=[^\s]* /--enr-address='"$SERVER_IP_ADDRESS"' --enr-tcp-port=9000 --enr-udp-port=9000 /' /etc/systemd/system/lighthouse-beacon.service

sudo systemctl daemon-reload
sudo systemctl restart lighthouse-beacon lighthouse-validator

echo -e "\nProcess is complete"
