#!/usr/bin/env bash
#
# Monitoring helper script stuff to "reset" Grafana/Prometheus setup on a validator server
#

I_KNOW_WHAT_I_AM_DOING=false # CHANGE ME ONLY IF YOU TRULY UNDERSTAND

APT_PACKAGES="grafana prometheus prometheus-node-exporter"

if [ "$I_KNOW_WHAT_I_AM_DOING" = false ]; then
    echo "Make sure you understand what this script does, then flip I_KNOW_WHAT_I_AM_DOING to true if you want to run it"
    exit 1
fi

echo -e "ARE YOU SURE YOU WANT TO RESET AND DELETE MONITORING DATA ON THE VALIDATOR?\n"
read -p "Press [Enter] to Continue"

# stop monitoring services
sudo systemctl stop grafana-server.service prometheus.service

# remove packages
sudo apt-get remove -y $APT_PACKAGES

# remove monitoring artifacts
sudo rm -rf /var/lib/grafana
sudo rm -rf /var/lib/prometheus

# restore service backup files and restart client services
sudo mv /etc/systemd/system/geth.service.BACKUP /etc/systemd/system/geth.service
sudo mv /etc/systemd/system/lighthouse-beacon.service.BACKUP /etc/systemd/system/lighthouse-beacon.service
sudo mv /etc/systemd/system/lighthouse-validator.service.BACKUP /etc/systemd/system/lighthouse-validator.service

sudo systemctl daemon-reload
sudo systemctl restart geth lighthouse-beacon lighthouse-validator

echo -e "\nProcess is complete"
