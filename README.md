# PulseChain Testnet Validator Node Setup Helper Scripts for Ubuntu Linux

![pls-testnet-validator-htop](https://user-images.githubusercontent.com/100790377/229965674-75593b5a-3fa6-44fe-8f47-fc25e9d3ce21.png)

Read ALL the instructions as they will explain and tell you how to run these scripts and the caveats. When you download the script, you may need to `chmod +x pulsechain-validator-setup.sh` to make the script executable and able to run on the system.

# Description

The setup script installs pre-reqs, golang, rust, go-pulse (geth fork) and lighthouse on a fresh, clean Ubuntu OS for getting a PulseChain Testnet (V3) Validator Node setup and running with **Geth (go-pulse)** and **Lighthouse** clients.

There are other helper scripts that do various things, check the notes for each one specifically for more info.

Note: the pulsechain validator setup script currently DOES NOT install monitoring/metrics packages such as Grafana or Prometheous, that may be done in a separate monitoring setup script

# Usage

```
$ ./pulsechain-validator-setup.sh [0x...YOUR ETHEREUM FEE ADDRESS] [12.89...YOUR SERVER IP ADDRESS]
```

**Command line options**

- ETHEREUM FEE ADDRESS is the FEE_RECIPIENT value for --suggested-fee-recipient to a wallet address you want to recieve priority fees from users whenever your validator proposes a new block (else it goes to the burn address)

- SERVER_IP_ADDRESS to your validator server's IP address

Note: you may get prompted throughout the process to hit [Enter] for OK and continue the process

For example when running Ubuntu on AWS EC2 cloud service, you can expect to hit OK on kernel upgrade notice, [Enter] or "1" to continue Rust install process and so on

# Environment
Tested on Ubuntu 22.04 (on Amazon AWS EC2 /w M2.2xlarge VM) running as a non-root user (ubuntu) with sudo privileges


**IMPORTANT things to do AFTER RUNNING THIS SCRIPT to complete the node setup**

1) Generate validator keys with deposit tool, import them into lighthouse and make your 32m tPLS deposit on the launchpad

Note: generate your keys on a different, secure machine (NOT on the validator server) and transfer them over for import

```
$ sudo apt install -y python3-pip
$ git clone https://gitlab.com/pulsechaincom/staking-deposit-cli.git
$ cd staking-deposit-cli && pip3 install -r requirements.txt && sudo python3 setup.py install
$ ./deposit.sh new-mnemonic
```

Then follow the instructions from there, copy them over to the validator and import into lighthouse AS THE NODE USER (not the 'ubuntu' user on ec2)

Something like this should work
```
$ sudo -u node bash
$ lighthouse account validator import --directory ~/validator_keys --network=pulsechain_testnet_v3
```

2) Start the beacon and validator clients

```
$ sudo systemctl daemon-reload
$ sudo systemctl enable lighthouse-beacon lighthouse-validator
$ sudo systemctl start lighthouse-beacon lighthouse-validator
```

If you want to look at lighthouse debug logs (similar to geth)

```
$ journalctl -u lighthouse-beacon.service (with -f to get the latest logs OR without the get the beginning)
$ journalctl -u lighthouse-validator.service
```

Now let's get validating! @rhmaximalist

# Reset Validator Script
This helper script deletes all your validator data so you can try the setup again if you want a fresh install or feel like you made an error.

Be careful! It deletes and resets things, so read the code and make sure you understand what it does before using it.

# AWS EC2 Helper Script
Just some nice-to-haves if you're using the AWS Cloud for your validator server.

# AWS Cloud Setup
* [How to run a cloud server on AWS](https://docs.google.com/document/d/1eW0SDT8IvZrla7gywK32Rl3QaQtVoiOu5OaVhUKIDg8/edit)

# Staking Deposit Client Walkthrough

* [Validator Key Generation and Management](https://docs.google.com/document/d/1tl_nql6-Bqyo5yqFDJ2aqjAQoBAK0FtcCYSKpGXg0hw/edit)

# Details for all PulseChain clients (/w Ethereum Testnet notes)
* [Geth, Erigon, Prysm and Lighthouse](https://docs.google.com/document/d/1RkAWt0Q_DmYpnykHFM4Qf5ItDLPLi-kaj1PDG74Mftg/edit)

# Setting up monitoring with Prometheus and Grafana
* TBD

# Community Guides and Scripts
* https://gitlab.com/davidfeder/validatorscript/-/blob/5fa11c7f81d8292779774b8dff9144ec3e44d26a/PulseChain_V3_Script.txt
* https://www.hexpulse.info/docs/node-setup.html
* https://togosh.medium.com/pulsechain-validator-setup-guide-70edae00b344
* https://github.com/tdslaine/install_pulse_node

# FAQ

* What server specs do you need to be a validator?

Specs and preferences vary between who you talk to, but at least 32gb ram and a beefy i7 or server-based processor and 2TB SSD hard disk. In the cloud, this roughly translates into a M2.2XLarge EC2 instance + 2TB disk.

* How long does it take to sync the blockchain clients?

It depends on your bandwidth, server specs and the state of the network, but you should expect anywhere from 24 - 96hrs for a validator node to sync.

