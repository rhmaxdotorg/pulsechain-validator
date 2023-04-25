#!/usr/bin/env bash
#
# PulseChain Testnet Monitoring Setup Helper Script - Grafana and Prometheus
#
# Description
# - Installs Grafana and Prometheus monitoring tools on your validator server,
# however requires some manual setup and configuration afterwards (see below).
#
# Environment
# - Tested on Ubuntu 22.04
#
# What you need to do AFTER running this script
# - Check if the monitoring services are running correctly
#
# $ sudo systemctl status grafana-server.service prometheus.service prometheus-node-exporter.service
#
# - Set up the dashboards through the web interface
#
# How to access Grafana from your web browser (without exposing port 3000 to the Internet)
# $ ssh -i key.pem -N ubuntu@validator-server-IP -L 8080:localhost:3000
#
# Dashboards to import
# - https://gist.githubusercontent.com/karalabe/e7ca79abdec54755ceae09c08bd090cd/raw/3a400ab90f9402f2233280afd086cb9d6aac2111/dashboard.json (Geth)
# - https://raw.githubusercontent.com/sigp/lighthouse-metrics/master/dashboards/Summary.json (Lighthouse)
# - https://raw.githubusercontent.com/sigp/lighthouse-metrics/master/dashboards/ValidatorClient.json (Lighthouse)
#
# Important Note
#
# The standard config assumes you are not sharing the validator server with other people (local user accounts).
# otherwise, it’s recommended for security reasons to set up further authentication on the monitoring services.
# TL;DR you should be the only one with remote access to your validator server, so ensure your keys and passwords are
# safe and do not share them with anyone for any reason.
#
# References (basically automated most of these steps)
# - https://www.coincashew.com/coins/overview-eth/guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-i-installation/monitoring-your-validator-with-grafana-and-prometheus
#

# config
APT_PACKAGES="grafana prometheus prometheus-node-exporter"

METRICS_GETH_FLAG="--metrics --pprof"
METRICS_LIGHTHOUSE_FLAG="--metrics"

echo -e "Grafana and Prometheus Monitoring Setup for Validators\n"
echo -e "Note: this is a HELPER SCRIPT (some steps still need completed manually, see notes after script is finished)\n"
echo -e "* it could take around 3 minutes to complete -- depending mostly on bandwidth and server specs *\n"

read -p "Hit [Enter] to continue"

# backup service files, update /w metrics flag and reload services
sudo cp /etc/systemd/system/geth.service /etc/systemd/system/geth.service.BACKUP
sudo cp /etc/systemd/system/lighthouse-beacon.service /etc/systemd/system/lighthouse-beacon.service.BACKUP
sudo cp /etc/systemd/system/lighthouse-validator.service /etc/systemd/system/lighthouse-validator.service.BACKUP

sudo sed -i '12s/$/ '"$METRICS_GETH_FLAG"'/' /etc/systemd/system/geth.service
sudo sed -i '12s/$/ '"$METRICS_LIGHTHOUSE_FLAG"'/' /etc/systemd/system/lighthouse-beacon.service
sudo sed -i '12s/$/ '"$METRICS_LIGHTHOUSE_FLAG"'/' /etc/systemd/system/lighthouse-validator.service

sudo systemctl daemon-reload
sudo systemctl restart geth lighthouse-beacon lighthouse-validator

# install grafana and prometheus
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" > grafana.list
sudo mv grafana.list /etc/apt/sources.list.d

sudo apt-get update
sudo apt-get install -y $APT_PACKAGES

sudo systemctl enable grafana-server.service prometheus.service

# setup Prometheus with the generated config for geth and lighthouse
cat > prometheus.yml << EOT
global:
  scrape_interval:     15s # By default, scrape targets every 15 seconds.

  # Attach these labels to any time series or alerts when communicating with
  # external systems (federation, remote storage, Alertmanager).
  external_labels:
    monitor: 'codelab-monitor'

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
   - job_name: 'node_exporter'
     static_configs:
       - targets: ['localhost:9100']
   - job_name: 'nodes'
     metrics_path: /metrics
     static_configs:
       - targets: ['localhost:5054']
   - job_name: 'validators'
     metrics_path: /metrics
     static_configs:
       - targets: ['localhost:5064']
   - job_name: 'geth'
     scrape_interval: 15s
     scrape_timeout: 10s
     metrics_path: /debug/metrics/prometheus
     scheme: http
     static_configs:
     - targets: ['localhost:6060']
EOT

sudo mv prometheus.yml /etc/prometheus
sudo chmod 644 /etc/prometheus/prometheus.yml

sudo systemctl restart grafana-server.service prometheus.service prometheus-node-exporter.service
#sudo systemctl status grafana-server.service prometheus.service prometheus-node-exporter.service

echo -e "\nAlmost done! Just follow the next steps (as described in the notes) to setup your dashboards.\n"
