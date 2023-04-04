#!/usr/bin/env bash
#
# PulseChain validator helper script for Amazon AWS EC2 to update to just do a few nice things
#
# Note: once complete, it will reboot and disconnect your SSH session temporarily, wait a minute and log back in for freshness
#

NEW_HOSTNAME="elvalidator" # CHANGE ME to whatever you want to name the server

sudo hostname $NEW_HOSTNAME
touch ~/.hushlogin # quiet
sudo apt-get update && sudo apt-get upgrade -y && sudo reboot
