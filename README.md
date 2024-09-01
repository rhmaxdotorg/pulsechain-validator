# PulseChain Validator Automated Setup Scripts

![image](https://github.com/rhmaxdotorg/pulsechain-validator/assets/100790377/20867b6a-00cb-46af-98da-19c1fbb76d8b)

Welcome!

The community writes code to help people see the power of blockchains, understand true DeFi and support amazing networks like [PulseChain](www.pulsechain.com). 

These scripts will help automate your setup of a validator node running on the [PulseChain](www.pulsechain.com) Mainnet. Since it is a fork of [Ethereum](ethereum.org) 2.0, most all of the methods and guidance can easily be re-worked for setting up validators on the Ethereum side as well. **These scripts work on both your own hardware as well as cloud servers.**

**Setting up and running a validator server requires basic knowledge of Linux command line** which you can learn [here](https://www.youtube.com/playlist?list=PLS1QulWo1RIb9WVQGJ_vh-RQusbZgO_As).

**Please read ALL the instructions as they will explain and tell you how to run the scripts and any caveats.**

To download these scripts on your server, you need [git](https://www.digitalocean.com/community/tutorials/how-to-install-git-on-ubuntu-22-04) and then you can do `git clone https://github.com/rhmaxdotorg/pulsechain-validator.git`.

After you download the code, you may need to `chmod +x *.sh` to make all the scripts executable and able to run on the system.

**To simply install the validator software**, use [pulsechain-validator-setup.sh](https://github.com/rhmaxdotorg/pulsechain-validator/blob/main/pulsechain-validator-setup.sh). All the other scripts are just extra bells and whistles to support more features and maintenance. See this [video](https://www.youtube.com/watch?v=MSdf74CjF10) for a quick demo of how to run the script.

**Once you’re finished running the setup script, go to [AFTER RUNNING THE SCRIPT](#after-running-the-script) section to complete the process and get your validator on the network.**

Check out the [FAQ](#faq) or binge the [75+ validator videos](https://www.youtube.com/playlist?list=PLziGfhOdD9GByIivZJMh17mg6wfF-AgFC) that will probably answer any questions you have about how validators work, setup process, maintenance and more.

# Description

**Scripts and guidance available include...**
- PulseChain Validator setup (~85% entire process automated)
- Use the staking deposit client
- Grafana and Prometheus monitoring setup
- Setting up a Digital Ocean or AWS cloud server
- Updating your client versions to the latest
- Updating your fee recipient and IP address
- Enabling local RPC for Metamask
- Withdrawals and exiting the network
- Snapshot synced blockchain data and server backups
- Reset the validator and monitoring setup (in case you need to start over)

The setup script installs pre-reqs, golang, rust, go-pulse (geth fork) and lighthouse on a fresh, clean **Ubuntu Linux** OS for getting a PulseChain Mainnet Validator Node setup and running with **Geth (go-pulse)** and **Lighthouse** clients.

Clients are running on the same machine and not in docker containers (such as the method other scripts use). There are advantages and disadvantages to containerizing the clients vs running them on the host OS. You can also automate deployments with Terraform on AWS along with many other software packages. However, these scripts are meant to make it pretty easy to spin up and tear down new validator machines once you have the hardware up with access to a fresh install of Ubuntu Linux and try to make the process as seamless as possible.

There are other helper scripts that do various things, check the notes for each one specifically for more info.

You can run **pulsechain-validator-setup.sh** to setup your validator clients and **monitoring-setup.sh** afterwards to install the graphs and monitoring software.

Note: the pulsechain validator setup script doesn't install monitoring/metrics packages, however a script to do that is provided. It would need to **run the validator setup script AND THEN run the monitoring-setup.sh script provided**. Do not run the monitoring script before installing your validator clients. See details in the [Grafana or Prometheus](https://github.com/rhmaxdotorg/pulsechain-validator#setting-up-monitoring-with-prometheus-and-grafana) section.

Also **check out the introductory blog post** on [Becoming a PulseChain Validator](https://rhmax.org/blog/become-a-pulsechain-validator) for a simple breakdown of how the process works as well as the detailed [setup walkthrough video](https://www.youtube.com/watch?v=cLsTqTwxMko).

Table of Contents
=================

- [PulseChain Validator Automated Setup Scripts](#pulsechain-validator-automated-setup-scripts)
- [Description](#description)
- [Table of Contents](#table-of-contents)
- [Walkthrough](#walkthrough)
- [Usage](#usage)
  - [Command line options](#command-line-options)
- [Environment](#environment)
- [Hardware](#hardware)
- [After running the script](#after-running-the-script)
- [Debugging](#debugging)
  - [Check the Blockchain Sync Progress](#check-the-blockchain-sync-progress)
    - [Geth](#geth)
    - [Lighthouse](#lighthouse)
  - [Look at Client Service Status](#look-at-client-service-status)
  - [Look at client debug logs](#look-at-client-debug-logs)
- [Reset Validator Script](#reset-validator-script)
- [New Server Helper Script](#new-server-helper-script)
- [Client Update Script](#client-update-script)
  - [Backup clients helper](#backup-clients-helper)
- [Fee Recipient and IP Address Update Script](#fee-recipient-and-ip-address-update-script)
- [RPC Interface Script](#rpc-interface-script)
- [Snapshot Helper Script](#snapshot-helper-script)
- [Prune Geth Helper Script](#prune-geth-helper-script)
- [AWS Cloud Setup](#aws-cloud-setup)
- [Digital Ocean Cloud Setup](#digital-ocean-cloud-setup)
- [Staking Deposit Client Walkthrough](#staking-deposit-client-walkthrough)
- [Details for all PulseChain clients (/w Ethereum Testnet notes)](#details-for-all-pulsechain-clients-w-ethereum-testnet-notes)
- [Setting up monitoring with Prometheus and Grafana](#setting-up-monitoring-with-prometheus-and-grafana)
  - [Web UI setup](#web-ui-setup)
- [Community Guides, Scripts and Dashboards](#community-guides-scripts-and-dashboards)
- [Security](#security)
- [Networking](#networking)
  - [Server](#server)
  - [Home Router](#home-router)
  - [AWS Cloud](#aws-cloud)
  - [Digital Ocean](#digital-ocean)
- [Graffiti](#graffiti)
- [Withdrawals](#withdrawals)
  - [Overview](#overview)
  - [Withdrawal Keys](#withdrawal-keys)
  - [Exiting](#exiting)
- [Backups](#backups)
  - [Home](#home)
  - [Cloud](#cloud)
- [Uptime Monitoring](#uptime-monitoring)
- [FAQ](#faq)
  - [What server specs do you need to be a validator?](#what-server-specs-do-you-need-to-be-a-validator)
  - [How long does it take to sync the blockchain clients?](#how-long-does-it-take-to-sync-the-blockchain-clients)
  - [Can I run more than (1) validator on a single server?](#can-i-run-more-than-1-validator-on-a-single-server)
  - [I want to add more validators to my server.](#i-want-to-add-more-validators-to-my-server)
  - [How can I see the stats on my validator(s)?](#how-can-i-see-the-stats-on-my-validators)
  - [What if my validator stops working?](#what-if-my-validator-stops-working)
  - [How much does it cost to be a validator?](#how-much-does-it-cost-to-be-a-validator)
  - [My validator's effectiveness is 100%. Why do I see negative amounts or penalities?](#my-validators-effectiveness-is-100-why-do-i-see-negative-amounts-or-penalities)
  - [Is there any maintenance involved in keeping the validator running smoothly?](#is-there-any-maintenance-involved-in-keeping-the-validator-running-smoothly)
  - [What kind of internet connection do I need to validate?](#what-kind-of-internet-connection-do-i-need-to-validate)
  - [Can I use the script to set up a Testnet validator?](#can-i-use-the-script-to-set-up-a-testnet-validator)
  - [I just can't figure this stuff out. Help?](#i-just-cant-figure-this-stuff-out-help)
  - [Where can I find additional help on PulseChain dev stuff and being a validator?](#where-can-i-find-additional-help-on-pulsechain-dev-stuff-and-being-a-validator)
- [Additional Resources and References](#additional-resources-and-references)

# Walkthrough
Check out these videos for further explanations and code walkthroughs.
- [30 minute walkthrough](https://www.youtube.com/watch?v=cLsTqTwxMko)

More videos
- https://www.youtube.com/watch?v=6-ePJXAUfdg
- https://www.youtube.com/watch?v=X0TnkLt4E3w
- https://www.youtube.com/watch?v=QqcDs8llyyw
- https://www.youtube.com/watch?v=YFOxf4B27Zs
- https://www.youtube.com/watch?v=9Yibmetppcs
- https://www.youtube.com/results?search_query=rhmax+validator+ama

**How validators work**
- https://www.youtube.com/watch?v=8X5yBAdUthw
- https://twitter.com/rhmaximalist/status/1747444294452121643

**Profitability**
- https://twitter.com/rhmaximalist/status/1747797166087971244

# Usage

```
$ ./pulsechain-validator-setup.sh [0x...YOUR NETWORK FEE ADDRESS] [12.89...YOUR SERVER IP ADDRESS]
```

**Note: run the script with only the fee address and IP address, without the brackets (they are just included above for demonstration purposes).**

## Command line options

- **NETWORK FEE ADDRESS** is the FEE_RECIPIENT value for --suggested-fee-recipient to a wallet address you want to recieve priority fees from users whenever your validator proposes a new block (else it goes to the burn address)

- **SERVER_IP_ADDRESS** to your validator server's IP address

Note: you may get prompted throughout the process to hit [Enter] for OK and continue the process at least once, so it's not meant to be a completely unattended install, but it could be depending on your environment setup.

**Note: You can use choose to use either the same wallet or two different wallets for your fee address and withdrawal address. Some people might like their fees going to a hot wallet and withdrawals to a cold wallet, which in case they would use two different wallets.**

**If you encounter errors running the script and want to run the script again, use the [Reset the Validator](https://github.com/rhmaxdotorg/pulsechain-validator/blob/main/README.md#reset-validator-script) BEFORE running it over and over again.**

Just make sure you know what you're doing and manually edit the reset script to bypass the "I don't know what I'm doing" check. It's very straightforward, just read the code, acknowledge you know what the script it doing and **change I_KNOW_WHAT_I_AM_DOING=false to true to get it to run**.

# Environment
Tested on **Ubuntu 22.04** Linux running as a non-root user with sudo privileges.

Desktop or Server edition works, however Desktop edition is recommended as it provides a GUI and is easier to navigate for beginners. **LTS** (long term support) versions are often more stable, which is better for servers and things you want to know are well tested and reliable.

# Hardware
The consensus on the **minimum recommended requirements** to run a validator seem to be **32gb RAM, 2TB disk and plenty of processing power (quadcore, xeon/ryzen, 4-8 vCPUs and such)**. These can come in the form of buying or building your own server and paying an upfront cost, utilities and maintenance OR renting a server from a VPS/cloud provider such as **Amazon AWS (M2.2Xlarge server)** or **Digital Ocean 32GB Droplet** and paying monthly to use their platform and resources. Both have advantages and disadvantages as well as varying time, monetary and management costs.

Could you get by with an old PC under your desk with a $50 battery backup? Maybe, but that would not be *recommended*. I'd rather not skimp on hardware for things that I would plan to run for years and pay for the peace of mind of not worrying about what I'm going to do if X fails one day, wishing I'd started with stronger foundations. If you try and do it right the first time, you might save a lot of time and headache.

It's **recommended you have new hardware that meets or exceeds the minimum recommended requirements to give yourself the chance to have the best experience being a validator**. There's also the PulseChain validator hardware store you can check out for more ready-to-go options at https://www.validatorstore.com.

# After running the script

The script automates a roughly estimated ~85% of what it takes to get the validator configured, but there's still a few manual steps you need to do to complete the setup: generate your keys in a secure environment, copy and import them on your validator server and **once your clients are fully synced**, make the deposit to activate your validator on the network.

**Steps 1-4**

1) Generate your keys (on another, secure machine)
2) Copy and import your keys on the validator
3) Start the validator client
4) Make your deposit(s)

**Environment and hardware options for key generation**
* **Live CD** or **bootable USB** such as [Rufus](https://rufus.ie) that you boot and use (all ephemeral, in-memory, disposable filesystem), recommended as a more secure option
* **Use another machine** (spare laptop or device) with a **clean install** of Ubuntu Linux, not connected to the internet (only to download the staking client or use a USB stick to transfer staking over to it) – another fairly secure way of doing it
* **Virtual machine** with clean install (less secure and make sure to delete it afterwards)
* **Spin up a free tier cloud instance** on a cloud provider (see AWS section, less secure, but fast, make sure to destroy it afterwards)

**Generate validator keys with deposit tool and import them into Lighthouse**

**Run the staking deposit client (ON A DIFFERENT MACHINE, see notes below for details)**
```
$ sudo apt install -y python3-pip
$ git clone https://gitlab.com/pulsechaincom/staking-deposit-cli.git
$ cd staking-deposit-cli && pip3 install -r requirements.txt && sudo python3 setup.py install
$ ./deposit.sh new-mnemonic --chain=pulsechain --eth1_withdrawal_address=0x... (ENTER THE CORRECT WALLET ADDRESS TO WITHDRAWAL YOUR FUNDS)
```

If you get an error after running the first command, saying that it can't find python3-pip (such as when you're booting from USB to run Ubuntu OS), you can update the apt config and that should fix it.

`sudo add-apt-repository universe && sudo apt update`

It is **VERY IMPORTANT** that you use a withdrawal wallet address that you have access to and is SECURE for a long time. Otherwise you may lose all your deposit funds.

**Note: You can use choose to use either the same wallet or two different wallets for your fee address and withdrawal address. Some people might like their fees going to a hot wallet and withdrawals to a cold wallet, which in case they would use two different wallets.**

**Then follow the instructions from there, copy them over to the validator and import into lighthouse AS THE NODE USER (not the 'ubuntu' user on ec2) as described below.**

If you are setting this up on a home server, you can copy the validator keys onto a USB drive and then plug the USB drive into the validator when you're ready to copy. If logged in to the validator server locally and using the Desktop, after plugging in the drive you can open a window to view files and folders on the drive and see the *validator_keys* folder. If you open another window that shows the *Home* directory, you can drag (or right click and copy) the *validator_keys* folder from the USB drive to the *Home* directory.

Once you have copied the *validator_keys* folder into the *Home* directory (for the user you're logged in as, which may be the *ubuntu* user or otherwise, as we're not using the *node* user for import operations yet), these are the next commands to get through the process.

```
$ sudo cp -R /home/ubuntu/validator_keys /home/node/validator_keys
$ sudo chown -R node:node /home/node/validator_keys
$ sudo -u node bash

(as node user)
$ cd ~
$ /opt/lighthouse/lighthouse/lh account validator import --directory ~/validator_keys --network=pulsechain

enter password to import validator(s)

(exit and back as ubuntu user)
```

Note: generate your keys on a different, secure machine (NOT on the validator server) and transfer them over for import. **See the Security section for more references on why this is important.** AWS even offers a [free tier](https://aws.amazon.com/free/free-tier-faqs/) option that allows you to spin up and use VMs basically for free for a certain period of time, so you could use that for quick and easy tiny VMs running Ubuntu Linux (not beefy enough to be a validator, but fine for small tasks and learning).

You can use the `scp` command to copy validator keys over the network (encrypted), USB stick (if hardware is local, not vps/cloud) OR use this base64 encoding trick for a copy and paste style solution such as the following. Note: this is advanced and you need to pay attention to be successful with it. If you're not confident you can do it, **better to use scp or USB methods**.

**On disposable VM, live CD or otherwise emphemeral filesystem**

```
sudo apt install -y unzip zip
zip -r validator_keys.zip validator_keys
base64 -w0 validator_keys.zip > validator_keys.b64
cat validator_keys.b64 (and copy the output)
```

**On your validator server**
```
cat > validator_keys.b64 <<EOF
Paste the output
[Enter] + type “EOF” + [Enter]
base64 -d validator_keys.b64 > validator_keys.zip
unzip validator_keys.zip
```

Also see [Validator Key Generation and Management](https://docs.google.com/document/d/1tl_nql6-Bqyo5yqFDJ2aqjAQoBAK0FtcCYSKpGXg0hw/edit) for more guidance.

**Start the beacon and validator clients**
```
$ sudo systemctl daemon-reload
$ sudo systemctl enable lighthouse-beacon lighthouse-validator
$ sudo systemctl start lighthouse-beacon lighthouse-validator
```

If you want to look at lighthouse debug logs (similar to geth)

```
$ journalctl -u lighthouse-beacon.service (with -f to get the latest logs OR without it to get the beginning logs)
$ journalctl -u lighthouse-validator.service
```

**Once the blockchain clients are synced, you can make your 32m PLS deposit (per validator)**

You can have multiple on one machine. The deposit is made @ [https://launchpad.pulsechain.com](https://launchpad.pulsechain.com) to get your validator activated and participating on the network.

If you do the deposit before the clients are fully synced and ready to go, then you risk penalities as your validator would join the network, but due to not being synced, unable to participate in validator duties (until it's fully synced).

Once on the network, you check use [Beacon Explorer](https://beacon.pulsechain.com) to check for Active/Inactive status, Effectiveness and Rewards. See this [post](https://twitter.com/rhmaximalist/status/1781324036217454683) for how to view stats for validators.

Now let's get validating! [@rhmaximalist](https://www.twitter.com/rhmaximalist)

# Debugging
In general, if you happen to be stuck syncing at N% or even at 100% but not sure why you're not seeing the validator make attestations, sometimes a reboot can help. You might even see "Error during attestation routine" or "Error updating deposit contract cache" in the logs and notice your validator isn't making attestations. You can try rebooting the server itself if restarting services doesn't work, which might take more then once even in a day or so time period.

Check service logs to see "Successfully published attestations" and use the beacon explorer to confirm your validator(s) are making attestations again.

## Check the Blockchain Sync Progress

### Geth
```
curl -s http://localhost:8545 -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":67}' | jq
```    

**You should see a similar output below  from the command above**    
```
{
  "jsonrpc": "2.0",
  "id": 67,
  "result": {
  "currentBlock": "0xffe4e3", // THIS IS WHERE YOU ARE
  "highestBlock": "0xffe8fa", // THIS IS WHERE YOU’RE GOING
  [full output was truncated for brevity]
  }
}
```

So you can compare the current with the highest to see how far you are from being fully sync’d. Or is result=false, you are sync'd.

```
curl -s http://localhost:8545 -H "Content-Type: application/json" --data "{\"jsonrpc\":\"2.0\",\"method\":\"eth_syncing\",\"params\":[],\"id\":67}" | jq
```    

**You should see a similar output below  from the command above**    
```
{
  "jsonrpc": "2.0",
  "id": 67,
  "result": false
}
```

### Lighthouse
```
$ curl -s http://localhost:5052/lighthouse/ui/health | jq
{
  "data": {
	"total_memory": XXXX,
	"free_memory": XXXX,
	"used_memory": XXXX,
	"os_version": "Linux XXXX",
	"host_name": "XXXX",
	"network_name": "XXXX",
	"network_bytes_total_received": XXXX,
	"network_bytes_total_transmit": XXXX,
	"nat_open": true,
	"connected_peers": 0, // PROBLEM
	"sync_state": "Synced"
  [full output was truncated for brevity]
  }
}
```


```
$ curl -s http://localhost:5052/lighthouse/syncing | jq
{
  "data": "Synced"
}
```
## Look at Client Service Status

```
$ sudo systemctl status geth lighthouse-beacon lighthouse-validator

● geth.service - Geth (Go-Pulse)
     Loaded: loaded (/etc/systemd/system/geth.service; enabled; vendor preset: enabled)
     [some output truncated for brevity]

Apr 00 19:30:20 server geth[126828]: INFO Unindexed transactions blocks=1 txs=56   tail=14,439,524 elapsed=2.966ms
Apr 00 19:30:30 server geth[126828]: INFO Imported new potential chain segment blocks=1 txs=35   mgas=1.577  elapsed=21.435ms     mgasps=73.569  number=16,789,524 hash=xxxxd7..xxx>
Apr 00 19:30:30 server geth[126828]: INFO Chain head was updated                   number=16,789,xxx hash=xxxxd7..cdxxxx root=xxxx9c..03xxxx elapsed=1.345514ms
Apr 00 19:30:30 server geth[126828]: INFO Unindexed transactions blocks=1 txs=96   tail=14,439,xxx elapsed=4.618ms

● lighthouse-beacon.service - Lighthouse Beacon
     Loaded: loaded (/etc/systemd/system/lighthouse-beacon.service; enabled; vendor preset: enabled)
     [some output truncated for brevity]

Apr 00 19:30:05 server lighthouse[126782]: INFO Synced slot: 300xxx, block: 0x8355…xxxx, epoch: 93xx, finalized_epoch: 93xx, finalized_root: 0x667f…707b, exec_>

Apr 00 19:30:10 server lighthouse[126782]: INFO New block received root: 0xxxxxxxxxf5e1364e34de345ab72bf1632e814915eb3fdc888e5b83aaxxxxxxxx, slot: 300061

Apr 00 19:30:15 server lighthouse[126782]: INFO Synced slot: 300xxx, block: 0x681e…xxxx, epoch: 93xx, finalized_epoch: 93xx, finalized_root: 0x667f…707b, exec_>

● lighthouse-validator.service - Lighthouse Validator
     Loaded: loaded (/etc/systemd/system/lighthouse-validator.service; enabled; vendor preset: enabled)
     [some output truncated for brevity]

Apr 00 19:30:05 server lighthouse[126779]: Apr 06 19:30:05.000 INFO Connected to beacon node(s)             synced: X, available: X, total: X, service: notifier
Apr 00 19:30:05 server lighthouse[126779]: INFO All validators active slot: 300xxx, epoch: 93xx, total_validators: X, active_validators: X, current_epoch_proposers: 0, servic>
```

## Look at client debug logs

For example, `journalctl` will let you look at each client's debug logs. Recommend it with the `-f` option to get the latest logs.

```
$ journalctl -u geth.service
$ journalctl -u lighthouse-beacon.service
$ journalctl -u lighthouse-validator.service -f (with -f to get the latest logs OR without it get the beginning logs)
```

You can also run the `htop` command to check the CPU and memory usage of your validator server.

# Reset Validator Script
This helper script deletes all your validator data so you can try the setup again if you want a fresh install or feel like you made an error.

Be careful! It deletes and resets things, so read the code and make sure you understand what it does before using it.

# New Server Helper Script
Just some nice-to-haves if you're using Digital Ocean or AWS Cloud for your validator server.

# Client Update Script
It pulls updates from Gitlab, rebuilds the clients and restarts the services back again. Only supports Geth and Lighthouse.

**Important Notice**
If you used the setup script and **you made a new validator within the first 6-7 weeks of PulseChain, prior to early July 2023, the update script will not work for your server.** It requires either a *quick rebuild* of the validator with new changes in the setup script OR git environment update before it can properly upgrade the clients. See this [post](https://github.com/rhmaxdotorg/pulsechain-validator/issues/22#issuecomment-1619364208) which has the guidance for going through the process.

**Update:** If you would like to backup/restore the current clients as a safety measure, see the section below **Backup clients helper** before running the update script

Running the script is as simple as `./update-client.sh`. If you get a message to modify the script to make sure you understand the process, because **the validator will be offline for likely 1 hour while the updates are taking place**, make sure you understand and are OK with that. This is just a precaution to make sure you understand what you're doing before running the script. If all is good, you can do the following.

```
pico reset-validator.sh
```

and change `line 6` from `I_KNOW_WHAT_I_AM_DOING=false` to `I_KNOW_WHAT_I_AM_DOING=true`, then `ctrl+x` to exit, it will ask you to save so say `y` and `Enter` to save the changes.

And then `./update-client.sh` to start the process.

Once the process completes, you can verify the updated version of Geth and Lighthouse with these commands (respectively).

```
$ /opt/geth/build/bin/geth version
Geth
Version: 3.0.1-pulse-stable
```

```
$ sudo -u node bash -c "/opt/lighthouse/lighthouse/lh --version"
Lighthouse Lighthouse-Pulse/v2.4.0-2b37ea4
```

## Backup Client
Optionally, the script `backup-clients.sh` can be run with either option `[backup | restore]` and it should be run **before** the `update-client.sh` script, if performing the `backup` or after an update in case the new binaries are not working properly by running it with the `restore` parameter.

- `backup`: Will copy the currently running Geth and Lighthouse binaries into a backup folder in the node's user `$HOME` home directory. This option is intended to be run before running the update script which pulls and builds the latest clients
- `restore` Will replace the newly built binaries with the ones backed up (previous versions)

**Rollbacks**
- `backup`: To rollback running this command simply remove the backed up binaries or the whole folder `sudo -u node bash -c "rm -rf /home/node/backup"` (Run as node user)
- `restore`: To rollback and run again the latest clients, the best thing to do is to re-run the `update-client.sh` script again

# Fee Recipient and IP Address Update Script

This one allows you to update the network fee recipient and server IP address for Lighthouse.

These were specified during the initial PulseChain validator setup, however both of them may change for you over time, so the script allows you to easily update them and restart the clients.

```
$ ./update-fee-ip-addr.sh [0x...YOUR NETWORK FEE ADDRESS] [12.89...YOUR SERVER IP ADDRESS]
```

# RPC Interface Script

Enables the RPC interface so you can use your own node in Metamask (support for Firefox only). Running your own node and using it can be used for testing purposes, not relying on public servers or bypassing slow, rate limited services by "doing it yourself".

**Do not expose your RPC publicly unless you know what you're doing.** This script helps you more securely expose it to your own local environment for your own use.

If your RPC is...
- On the same machine as Metamask, you can point it at 127.0.0.1
- On VPS/cloud server, you can use SSH port forwarding and then point it at 127.0.0.1
- On a different machine on your local network, open the port on the local firewall and point it at that local IP address

**Add your server to Metamask**

Click the Network drop-down, then Add Network and Add a Network Manaully.

- Network name: Local PLS
- New RPC URL: http://local-network-server-IP:8564 OR http://127.0.0.1:8546 (running same machine OR port forwarded)
- Chain ID: 369 (943 for testnet v4)
- Currency symbol: tPLS
- Block explorer URL: https://scan.pulsechain.com
- Save

Now you can use your own node for transactions on the network that your validator is participating in.

# Snapshot Helper Script

Takes a backup snapshot of blockchain data on a fully synced validator so it can be copied over and used to bootstrap a new validator. Clients must be stopped until the snapshot completes, afterwards they will be restarted so the validator can resume normal operation.

**It's recommended to use get up to speed on "resumable terminals"** such as [tmux](https://linuxize.com/post/getting-started-with-tmux/) and use it when you're doing long-running operations such as snapshots. This mitigates unnecessary failures such as a disconnection from the server, causing the process to be interrupted, and requiring a re-run of the script.

After running the script, copy the geth.tar.xz and lighthouse.tar.xz (compressed blockchain data, kinda like ZIP files) over to the new validator server (see scp demo below OR use a USB stick).

```
$ scp -i key.pem geth.tar.xz ubuntu@new-validator-server-ip:/home/ubuntu
$ scp -i key.pem lighthouse.tar.xz ubuntu@new-validator-server-ip:/home/ubuntu
```

Copying over the network could take anywhere from 1 hour to a few hours (depending on the bandwidth of your server's network).

Then you can run the following commands ON THE NEW SERVER

```
$ sudo systemctl stop geth lighthouse-beacon lighthouse-validator
$ tar -xJf geth.tar.xz
$ tar -xJf lighthouse.tar.xz
$ sudo cp -Rf opt /
$ sudo chown -R node:node /opt
$ sudo systemctl start geth lighthouse-beacon lighthouse-validator
```

The geth.tar.xz file is likely going to be > 100gb and the lighthouse compressed file probably smaller, but prepare for ~200gb of data total for the transfer. It can take 4-6 hours to decompress these blockchain data files as well, for example...

```
$ date; tar -xJf geth.tar.xz; date
03:32:56 UTC 2023
07:50:01 UTC 2023
```

Note: this should work fine for Ethereum too as it's just copying the blockchain data directories for Geth and Lighthouse, but the scenario is technically untested. Also, this relies on the new validator setup (which you are copying the snapshot to) to be setup with this repo's setup script.

# Prune Geth Helper Script

Allows you to prune geth blockchain data to reduce disk space usage on the validator. Erigon does this automatically, but for maintenance pruning Geth regularly (quarterly or bi-yearly) is recommended to avoid the disk filling up.

You can also setup a cron job to do this automatically every quarter or 6 months, otherwise if you don't do the maintence, depending on your disk size, it can fill up and cause your validator to stop working properly.

References
- https://geth.ethereum.org/docs/fundamentals/pruning
- https://www.coincashew.com/coins/overview-eth/guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-ii-maintenance/pruning-the-execution-client-to-free-up-disk-space
- https://tecadmin.net/crontab-in-linux-with-20-examples-of-cron-schedule/

# AWS Cloud Setup
* [How to run a cloud server on AWS](https://docs.google.com/document/d/1eW0SDT8IvZrla7gywK32Rl3QaQtVoiOu5OaVhUKIDg8/edit)

AWS also offers a [free tier](https://aws.amazon.com/free/free-tier-faqs/) option that allows you to spin up Linux VMs for free for a certain period of time, so you could use that for quick and easy tiny VMs running Ubuntu Linux. They are not beefy enough to be a validator, so that's not an option, but they are fine for small tasks and learning. You just need to sign up for an account and follow the instructions in the above document, except choose Free Tier options instead of the validator hardware configuration as described.

# Digital Ocean Cloud Setup
* [How to run a cloud server on Digital Ocean](https://docs.google.com/document/d/1m41lIQxY1GSCJCNG7j54z655gw2hwGB5tgKIF973Kb0/edit)

DO seems to be a lot cheaper per month to run validator servers vs AWS which is why many people may choose it as a cloud provider rather than AWS.

# Staking Deposit Client Walkthrough

* [Validator Key Generation and Management](https://docs.google.com/document/d/1tl_nql6-Bqyo5yqFDJ2aqjAQoBAK0FtcCYSKpGXg0hw/edit)

# Details for all PulseChain clients (/w Ethereum Testnet notes)
* [Geth, Erigon, Prysm and Lighthouse](https://docs.google.com/document/d/1RkAWt0Q_DmYpnykHFM4Qf5ItDLPLi-kaj1PDG74Mftg/edit)

# Setting up monitoring with Prometheus and Grafana

The **monitoring-setup.sh** and **reset-monitoring.sh** automate most of the setup for grafana and prometheus as well as let you reset (or remove) the monitoring, respectively.

**You need to run the validator setup script FIRST and then use the monitoring setup script to "upgrade" the install with monitoring.**

## Web UI setup

After running the monitoring setup script, you must finish the configuration at the Grafana portal and import the dashboards.

The standard config assumes you are not sharing the validator server with other people (local user accounts). Otherwise, it’s recommended for security reasons to set up further authentication on the monitoring services. TL;DR you should be the only one with remote access to your validator server, so ensure your keys and passwords are safe and do not share them with anyone for any reason.

**If you are accessing your validator on the cloud or remote server** (not logged into a monitor connected to the validator at home)
You can setup grafana for secure access externally as opposed to the less secure way of forwarding port 3000 on the firewall and open it up to the world, which could put your server at risk next time Grafana has a security bug that anyone interested enough can exploit.

```
ssh -i key.pem -N ubuntu@validator-server-IP -L 8080:localhost:3000
```

Then open a browser window on your computer and login to grafana yourself without exposing it externally to the world. Magic, huh!

Go to `http://localhost:8080` and login with admin/admin (as the initial username/password). It will then ask you to set a new password, make it a good one.

**If you logged into it with a monitor connected to the validator** (not accessing your validator from remote location)
Then you don't need to forward any ports or use SSH as you can open a browser on the validator (**don't use it for generally surfing the internet**, only for specific purposes like checking metrics) and go to `http://localhost:3030` (not 8080) and with the same default login credentials of admin/admin, then set a new strong password.

Now to continue the monitoring setup...

In the lower left bar area, click the gear box -> Data Sources -> Add Data Source.
- Select Prometheus
- URL: http://localhost:9090
- Click Save & Test
- It should say “Datasource is working” in green

Use your mouse cursor to hover over the Dashboards icon (upper left bar area, 4 squares icon).
- Select Import
- Upload each JSON dashboard

This [Staking Dashboard](https://github.com/raskitoma/pulse-staking-dashboard) was forked from the Ethereum-based one for PulseChain and has really good stats!

**Staking Dashboard** (one of the best ones)
- Download it @ https://raw.githubusercontent.com/raskitoma/pulse-staking-dashboard/main/Yoldark_ETH_staking_dashboard.json to import
- Name: Staking Dashboard
- Datasource: Prometheus (default)
(same steps as previous)

There are also Dashboards for client stats, such as...

**Geth**
- Download it @ https://gist.githubusercontent.com/karalabe/e7ca79abdec54755ceae09c08bd090cd/raw/3a400ab90f9402f2233280afd086cb9d6aac2111/dashboard.json to import
- Name: Geth
- Datasource: Prometheus (default)
- Click Import
- Click Save button (and confirm Save) in upper right toolbar
- Repeat for next dashboard

**Lighthouse VC**
- Download it @ https://raw.githubusercontent.com/sigp/lighthouse-metrics/master/dashboards/ValidatorClient.json to import
- Name: Lighthouse VC
- Datasource: Prometheus (default)
(same steps as previous)

**Lighthouse Beacon**
- Download it @ https://raw.githubusercontent.com/sigp/lighthouse-metrics/master/dashboards/Summary.json to import
- Name: Lighthouse Beacon
- Datasource: Prometheus (default)
(same steps as previous)

**Now you can browse the Dashboards and see various stats and data!**

Also see the guides below for additional help (scripts were mostly based on those instructions)
- https://www.coincashew.com/coins/overview-eth/guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-i-installation/monitoring-your-validator-with-grafana-and-prometheus
- https://schh.medium.com/port-forwarding-via-ssh-ba8df700f34d
- https://github.com/raskitoma/pulse-staking-dashboard

You can also setup **email alerts** on Grafana. See guide at the link below.
- https://thriftly.io/docs/components/Thriftly-Deployment-Beyond-the-Basics/Metrics-Prometheus/Creating-Receiving-Email-Alerts.html

# Community Guides, Scripts and Dashboards
- https://www.gammadevops.com/p/validator-setup
- https://gitlab.com/davidfeder/validatorscript/-/tree/main
- https://hodldog.notion.site/PulseChain-Mainnet-Node-Validator-Guide-390243a66f3449a9a2425db25370ad89
- https://www.hexpulse.info/docs/node-setup.html
- https://togosh.medium.com/pulsechain-validator-setup-guide-70edae00b344
- https://github.com/tdslaine/install_pulse_node
- https://github.com/raskitoma/pulse-staking-dashboard
- https://github.com/PierreBrunetot/PulsechainConkyDashboard

# Security

Basic Security Model for PulseChain/Ethereum Validator

![PLS ETH Validator Security Flowchart (1)](https://github.com/rhmaxdotorg/pulsechain-validator/assets/100790377/352d9225-d762-4b7a-b2a2-54e7baa24b91)

**Network Security**

If running a validator in the cloud, there's already isolation away from your home network and the devices connected to it. However, if running a validator on your home network, the game is to keep attackers off of your home network. This is much easier when you're not inviting the public to connect to your server that sits on your network at home, but with validators, you're naturally exposing infrastructure running on your own network, which may be the same one you connect your personal devices to as well.

Recommended that if running a validator at home, you isolate it from everything else on your home network using another router into the mix, cascading routers or using VLANs and other kinds of network isolation or "guest" networks.

See references below for more information.
- https://www.mbreviews.com/cascading-routers/
- https://www.michaelhorowitz.com/second.router.for.wfh.php
- https://about.gitlab.com/handbook/security/network-isolation/
- https://www.routersecurity.org/vlan.php

**Validator Security AMA**
- https://www.youtube.com/watch?v=o3V052VvI4o

References
- https://www.youtube.com/watch?v=hHtvCGlPz-o
- https://www.coincashew.com/coins/overview-eth/guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-i-installation/guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node

# Networking
There are ports that need to be exposed to the Internet for your validator to operate, specially for Geth and Lighthouse it's TCP/UDP **ports 30303 and 9000** respectively. There are two common ways to control the firewall on your network: the Linux server and the network (such as your router or gateway to the Internet).

## Server
On the Linux server, you can open ports like this (as seen in the code).

```
# firewall rules to allow go-pulse and lighthouse services
sudo ufw allow 30303/tcp
sudo ufw allow 30303/udp
sudo ufw allow 9000/tcp
sudo ufw allow 9000/udp
```

## Home Router
This depends on your router device and model, so you'll need to research how to open ports on your specific networking device.

## AWS Cloud
**Security groups** (firewall)
- TCP port 22 (SSH) is your remote access to the server in the cloud (it’s enabled by default)
- For Erigon (or Geth), we need to open up TCP ports 30303 and 42069
- For Prysm (or Lighthouse), we need to open up TCP ports 9000 and 13000 as well as UDP port 12000
- All with Source=0.0.0.0/24 or Anywhere OR for extra security, you can restrict SSH access to your specific IP range / block, such as `XX.YY.0.0/16` (replace XX.YY with first two numbers of your public IP address, assuming you only plan to access the server from that location)

## Digital Ocean
Analogous to AWS cloud network settings and IP restrictions as you need appropriate.

# Graffiti

You can add graffiti flags for simple, one-line messages or ask Lighthouse to read from a file to express yourself in text for blocks your validator helps create. By default, the script does not set graffiti flags, but you can do this manually by editing the Lighthouse service files and adding in the flags and values that you want.

Check out the Lighthouse manual page on [graffiti](https://lighthouse-book.sigmaprime.io/graffiti.html) for instructions on how it works.

**Example**
```
$ sudo pico /etc/systemd/system/lighthouse-beacon.service

add something like this to the ExecStart= command (line 12)

 --graffiti "richard heart was right"

$ sudo systemctl daemon-reload
$ sudo systemctl restart lighthouse-beacon
```

# Withdrawals
**These instructions are only meant for use on Testnet and have not been tested on Mainnet, so only use them on Testnet until further testing and confirmation.**

**Be EXTRA CAREFUL as mistakes here can cost you funds and you must use these instructions at your own risk and hold yourself fully accountable for control and actions with your own funds, just like in the other parts of crypto.**

There are **full withdrawals** and partial withdrawals. This section will focus on the full withdrawal and validator exit process.

## Overview

**If you set a withdrawal address** when generating your validator keys, you can check on the [launchpad withdrawal](https://launchpad.pulsechain.com/en/withdrawals) page to verify withdrawals are enabled and then exit your validator (see process below).

**If you didn't set a withdrawal address** when generating your validator keys, you need to "upgrade your keys" (generate BLSToExecution JSON) using the staking deposit client and broadcast it via the Launchpad, **which as of now is unavailable**. Will update with further instructions as this feature to support the scenario becomes available. Then, you can exit your validator from the network.

## Withdrawal Keys

**TREAT THIS AS IF YOU ARE GENERATING YOUR VALIDATOR KEYS + SEED WORDS**

**PERFORM IT ON A DIFFERENT, SECURE MACHINE (not your validator server)**

Find the validator index for the specific validator you want to initiate an exit and withdrawal. Check on the beacon explorer with the validator’s public key (for example, 4369).

Download the latest staking deposit

```
$ git clone https://gitlab.com/pulsechaincom/staking-deposit-cli.git

$ ./deposit.sh generate-bls-to-execution-change

English

pulsechain

(Enter seed words)

0

(Enter each validator index as currently shown on the network)

You can open your deposit JSON file and copy each validator’s public key into the beacon explorer one at a time to get each index, but they should be sequential, like 4369, 4370, 4371, etc OR just the launchpad as it will show you validator index and withdrawal_credentials.

(Enter each withdrawal_credentials for each validator which is also in the deposit JSON file)

(Enter your execution address, aka withdrawal address, the wallet you’ve securely, made sure you and only you have access to and want to send the deposited PLS from the network back into)

DOUBLE CONFIRM YOU HAVE ACCESS TO THIS WALLET ADDRESS

It cannot be changed and if you typo something here, TWICE, YOUR FUNDS WILL BE UNRECOVERABLE.

Once you’ve double checked, enter the address again
```

Now your bls_to_execution_change JSON file is in the newly created **bls_to_execution_changes** folder.

## Exiting

Note: this was tested on Testnet V4 but has not been rigorously tested on PulseChain mainnet. See references for more info.

You can broadcast the change using your Lighthouse client (for the specific validator you want to exit and initiate withdrawal).

```
$ sudo -u node bash

$ /opt/lighthouse/lighthouse/lh account validator exit --network pulsechain --keystore ~/.lighthouse/pulsechain/validators/0x…(the validator public key you want to exit)/keystore-(specific for your setup)...json

Enter the keystore password

Enter the exit phrase described @ https://lighthouse-book.sigmaprime.io/voluntary-exit.html

“Successfully validated and published voluntary exit for validator 0x...” – and we can check it’s status on the beacon explorer

"Waiting for voluntary exit to be accepted into the beacon chain..."

"Voluntary exit has been accepted into the beacon chain, but not yet finalized. Finalization may take several minutes or longer. Before finalization there is a low probability that the exit may be reverted."

https://beacon.pulsechain.com/validator/0x...
```

And you can see it’s going from Active to Exit (pulsing green).

Once it's exited, you have to wait for Withdrawals to become available.

```
This validator has exited the system during epoch 5369 and is no longer validating.

There is no need to keep the validator running anymore. Funds will be withdrawable after epoch 5555. 
```

References
- https://lighthouse-book.sigmaprime.io/voluntary-exit.html
- https://finematics.com/ethereum-staking-withdrawals-explained
- https://blog.stake.fish/eth-withdrawals-for-validators-your-go-to-guide-after-shanghai/
- https://docs.prylabs.network/docs/wallet/withdraw-validator
- https://docs.prylabs.network/docs/wallet/exiting-a-validator
- https://www.coincashew.com/coins/overview-eth/update-withdrawal-keys-for-ethereum-validator-bls-to-execution-change-or-0x00-to-0x01-with-ethdo
- https://nimbus.guide/withdrawals.html
- https://someresat.medium.com/guide-to-configuring-withdrawal-credentials-on-ethereum-812dce3193a
- https://github.com/eth-educators/ethstaker-guides/blob/main/zhejiang.md#adding-a-withdrawal-address
- https://www.youtube.com/watch?v=RwwU3P9n3uo

# Backups
You can do various types of backups.

- Full server backup
- Blockchain data backup
- Snapshot of the entire disk (cloud)

**For the full server backup**, see the Home section below.

**For blockchain data backup only**, check out the Snapshot helper script and guidance.

**For snapshotting your disk on AWS cloud server**, see the Cloud section below.

## Home
You can use various tools on Linux to make scheduled backups to another disk OR another server.

Most use rsync, cron jobs or programs like Timeshift to automate the process.

**Using Timeshift to backup the server** (eg. on a 1TB or 2TB big USB or external hard drive)
- https://www.youtube.com/watch?v=QE0lyWodWdU
- https://teejeetech.com/timeshift/
- https://linuxtechlab.com/backup-ubuntu-systems-using-timeshift/
- https://dev.to/rahedmir/how-to-use-timeshift-from-command-line-in-linux-1l9b
- https://github.com/linuxmint/timeshift/issues/150
- https://linuxhint.com/timeshift_linux_mint_usb/

Further Guides and References
- https://helpdeskgeek.com/linux-tips/5-ways-to-automate-a-file-backup-in-linux/
- https://www.howtogeek.com/135533/how-to-use-rsync-to-backup-your-data-on-linux/
- https://averagelinuxuser.com/automatically-backup-linux/
- https://www.math.cmu.edu/~gautam/sj/blog/20200216-rsync-backups.html
- https://www.simplified.guide/linux/automatic-backup

## Cloud
**Snapshots**
- AWS Home
- EC2 -> Instances -> (Select validator server’s Instance ID)
- Storage tab (near bottom)
- Click the Volume ID (to filter by it)
- Click the Volume ID (again)
- Actions -> Create Snapshot
- Description: (current date, for example 5/5/55)
- Create Snapshot

You should see in green...
- Successfully created snapshot snap-aaaabbbb from volume vol-xxxxyyyy.

It will be in Pending status for a while before the process completes (could be a few hours).

**Using a Snapshot**
- EC2 -> Snapshots
- Click on the Snapshot ID (see description to identify the right one, set Name as appropriate)
- Now you can do things like create a volume from the snapshot (and use the snapshot)
- Create a new volume from the snapshot
- Go back to volumes and name it like pulsechain-snapshot-050523
- Spin up another server with the same hardware
- Create a new server (instance)
- Go to the new instance and detach the initially created volume
- EC2 -> Volumes -> Select the volume created from the snapshot
- Actions -> Attach volume
- Select the new instance (just created)
- Device name: /dev/sda1
- Click Attach volume
- Now start the new instance

You now have a new server with a hard disk volume based on the snapshot of the other server, yay!

# Uptime Monitoring

There are many ways to get uptime monitoring alerts for your validator, some more complex and invasive than others. You can setup a mail server and detect outage condition X or Y, probably even monitor Grafana for alerts. There are pros and cons using your validator server to do this vs leveraging external services.

One light-weight way to get alerts if your validator "goes offline" is to use an external service to simply check and see if at least (1) condition has been met for a properly functioning validator server. In this example, we're using [UptimeRobot](https://www.uptimerobot.com) and alerting if our server fails to meet a condition such as the Geth client on port 30303 is unreachable.

**This will catch "validator is down" scenarios** such as...
- Entire server is offline
- Network problem that has taken server effectively offline
- Geth client problem that is preventing your validator from working properly

Be aware that this isn't meant to catch all of them. However, it should work for common downtime situations such as hardware failures, server crashes or networking issues.

First, you'll need to sign up @ www.uptimerobot.com and then on the dashboard, choose Add New Monitor.

Friendly Name: Validator 30303
IP: [validator IP address]
Port: Custom Port
Port: 30303
URL: ping

- Select Alert Contacts to Notify
- Select your sign-up email (or add a new one)
- Click Create Monitor

See the “Monitor Created” notification in green

Go to monitor detail

- Create status page

Friendly name: Validator 30303
+ On the validator 30303 monitor to add it
Save

Click on the eye icon to see your public status page
The URL will look something like [https://stats.uptimerobot.com/XYZ369abc5555](https://stats.uptimerobot.com/XYZ369abc5555).

**Testing notification setup**

1) WAIT 24-36hrs before testing for outage alerts, service may not pick up outages or be very effective prior to 24-36hrs period AFTER setting up alerts for your validator
2) “Send test notification” to try it out and see what it sends to your inbox
3) Or “sudo systemctl stop geth” and see what it does with a real outage (NOTE: this may cause some penalties to your validator and affect uptime % stats obviously, but should be minimal)

Now if your validator goes offline and meets the conditions we're checking for (port 30303 is reachable), you should get an email from UptimeRobot and also see updates on the UptimeRobot dashboard and status page.

# FAQ

## What server specs do you need to be a validator?

Specs and preferences vary between who you talk to, but at least 32gb ram and a beefy i7 or server-based processor and 2TB SSD hard disk. In the cloud, this roughly translates into a M2.2XLarge EC2 instance + 2TB disk.

## How long does it take to sync the blockchain clients?

It depends on your bandwidth, server specs and the if the network is running smoothly, but you should expect anywhere from 24 - 96hrs for a validator node to sync. Then 12-36hrs afterwards for your validator to be activated and added to the network. So it can take 2-3 days for the full process.

## Can I run more than (1) validator on a single server?

Yes, you can run as many validators as you want on your server. Only caveat being that if you plan to run 100+, you may want to double the specs (at least memory) on your hardware to account for any additional resource usage. If you plan on running 1 or 10 or even 50, the minimum recommended hardware specs will probably work.

The setup script has no dependencies on the number of validators you run, it simply installs the clients and when you generate your validator keys with the staking deposit tool, there you choose the specific number you want to run. It could be 1, 5, 10 or 100. Then, when you import your keys to Lighthouse, you will import each key and it will configure the client to run that number of validators.

## I want to add more validators to my server.

Check out the Adding more validators guide @ CoinCashew.
- https://www.coincashew.com/coins/overview-eth/guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-iii-tips/adding-a-new-validator-to-an-existing-setup

Let's say you have generated your keys for 1 validator and want to add 2 more. It would look something like this for pulsechain.

```
$ ./deposit.sh existing-mnemonic --validator_start_index 1 --num_validators 2 --chain pulsechain --eth1_withdrawal_address 0x..(MAKE SURE YOU WILL ALWAYS HAVE ACCESS TO THIS WALLET)
```

You can also check out instructions [here](https://gitlab.com/davidfeder/validatorscript/-/blob/main/PulseChain_MainNet_Add_Wallets.txt?ref_type=heads).

## How can I see the stats on my validator(s)?

Look at your deposit JSON file to get the list of your validator(s) public keys, then check https://beacon.pulsechain.com/validator/ + your validator's public key which each one that you want to check the stats on.

For example this validator's stats: https://beacon.pulsechain.com/validator/8001503cd43190b01aaa444d966a41ddb95c140e4910bb00ad638a4c020bc3a070612f318e3372109f33e40e7c268b0b

You can also setup Monitoring with Grafana and Prometheus (see guidance in above sections).

## What if my validator stops working?

Did your server's IP address change? If so, update lighthouse beacon service file @ /etc/systemd/system/lighthouse-beacon.service or use the **update-fee-ip-addr.sh** script to update both the fee address + server IP address.

Did your network/firewall role change? Make sure the required client ports are accessible.

What is your status on the beacon explorer? Active, Pending, Exited or something else? If not active, it may be a client issue which you can debug with the steps discussed in the Debugging section.

Are your clients fully synced? They must be synced, talking to each other and talking to the network for the validator to work properly.

## How much does it cost to be a validator?

Depends on if you're using your own hardware or the cloud. For example, you could build or buy your own hardware for initial cost of $1k-$2k and then pay for electricity it uses from running 24/7 each month. Or you can rent a server in the Amazon AWS cloud for an (estimated) few hundred dollars per month. Both ways have advantages and disadvantages.

## My validator's effectiveness is 100%. Why do I see negative amounts or penalities?

You could getting wrong votes from time to time or otherwise which is just a natural part of participating in the system. Also, you could be seeing this because it's withdrawaling rewards in batches automatically to your withdrawal address.

Also, you can learn more about the different kinds of validator rewards [here](https://blog.metrika.co/validators-or-value-takers-e71f46047437).

- Attestation Rewards
- Proposal Rewards
- Sync-committee Rewards

References
- https://www.reddit.com/r/ethstaker/comments/khgdgf/why_do_i_get_a_negative_reward_for_a_normal/
- https://kb.beaconcha.in/rewards-and-penalties
- https://ethereum.org/en/staking/withdrawals/
- https://blog.metrika.co/validators-or-value-takers-e71f46047437

## Is there any maintenance involved in keeping the validator running smoothly?

There's only a couple maintenance items that can be completed manually (or by running the supporting scripts in the repo) or setup to run automatically with a cronjob, for example.

- Pruning geth (quarterly or bi-yearly so you don't fill up the disk space)
- Keeping the clients up to date (eg. if RH announces new parameters on the network, you'll want to update the clients)

Again, there are scripts in the repo that make this easy. Check this [tweet](https://twitter.com/rhmaximalist/status/1782624967198466461) for information on pruning the validator.

## What kind of internet connection do I need to validate?
This could depend on the number of validators, but generally speaking 50mbps seems to be fine for most cases, eg. 1-10 validators.

10+ or 100+ validators may benefit from 100mbps+ connection, but its always better to have too fast of a connection vs too slow. Gigabit is great if available and practical for situation.

## Can I use the script to set up a Testnet validator?

Yes, by default the script will use mainnet settings, however if you edit the script and comment out mainnet and uncomment the testnet parameters, you can run a testnet v4 validator.

First, change the client chain flags.

```
# chain flags
GETH_MAINNET_CHAIN="pulsechain"
LIGHTHOUSE_MAINNET_CHAIN="pulsechain"

GETH_TESTNET_CHAIN="pulsechain-testnet-v4"
LIGHTHOUSE_TESTNET_CHAIN="pulsechain_testnet_v4"

# default=mainnet, comment/uncomment to switch to testnet
GETH_CHAIN=$GETH_MAINNET_CHAIN
LIGHTHOUSE_CHAIN=$LIGHTHOUSE_MAINNET_CHAIN
#GETH_CHAIN=$GETH_TESTNET_CHAIN
#LIGHTHOUSE_CHAIN=$LIGHTHOUSE_TESTNET_CHAIN
```

Then, change the checkpoint URL.

```
# checkpoint urls
LIGHTHOUSE_MAINNET_CHECKPOINT_URL="https://checkpoint.pulsechain.com"
LIGHTHOUSE_TESTNET_CHECKPOINT_URL="https://checkpoint.v4.testnet.pulsechain.com"

LIGHTHOUSE_CHECKPOINT_URL=$LIGHTHOUSE_MAINNET_CHECKPOINT_URL
#LIGHTHOUSE_CHECKPOINT_URL=$LIGHTHOUSE_TESTNET_CHECKPOINT_URL
```

So, to run testnet instead of mainnet, the testnet options should be enabled and look something like this.

```
GETH_CHAIN=$GETH_TESTNET_CHAIN
LIGHTHOUSE_CHAIN=$LIGHTHOUSE_TESTNET_CHAIN

LIGHTHOUSE_CHECKPOINT_URL=$LIGHTHOUSE_TESTNET_CHECKPOINT_URL
```
## I just can't figure this stuff out. Help?

Binge the [Validator Playlist](http://tinyurl.com/ValidatorPlaylist). It covers just about every question and scenario you could run into during setup and understanding operation.

## Where can I find additional help on PulseChain dev stuff and being a validator?

- https://t.me/PulseDev
- https://t.me/g4mm4ioChat

# Additional Resources and References
- https://gitlab.com/pulsechaincom
- https://gammadevops.substack.com/p/part-1-introduction-to-validator
- https://gitlab.com/davidfeder/validatorscript/-/blob/64f37685908a78c5337f8d3dc951f7f01f251697/PulseChain_V4_Script.txt
- https://gitlab.com/davidfeder/validatorscript/-/blob/5fa11c7f81d8292779774b8dff9144ec3e44d26a/PulseChain_V3_Script.txt
- https://www.hexpulse.info/docs/node-setup.html
- https://togosh.medium.com/pulsechain-validator-setup-guide-70edae00b344
- https://github.com/tdslaine/install_pulse_node
- https://gitlab.com/Gamesys10/pulsechain-node-guide
- https://lighthouse-book.sigmaprime.io/api-lighthouse.html
- https://lighthouse-book.sigmaprime.io/key-management.html
- https://docs.gnosischain.com/node/guide/validator/run/lighthouse
- https://ethereum.stackexchange.com/questions/394/how-can-i-find-out-what-the-highest-block-is
- https://www.coincashew.com/coins/overview-eth/guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-i-installation/monitoring-your-validator-with-grafana-and-prometheus
- https://schh.medium.com/port-forwarding-via-ssh-ba8df700f34d
- https://www.youtube.com/watch?v=lbUnlIL_yLs&ab_channel=Oooly
- https://www.reddit.com/r/ethstaker/comments/txj5vh/technical_overview_of_validator_need_some_help/
- https://docs.prylabs.network/docs/troubleshooting/issues-errors
- https://pawelurbanek.com/ethereum-node-aws
- https://chasewright.com/getting-started-with-turbo-geth-on-ubuntu/
- https://docs.prylabs.network/docs/prysm-usage/p2p-host-ip
- https://www.blocknative.com/blog/an-ethereum-stakers-guide-to-slashing-other-penalties
- https://goerli.launchpad.ethstaker.cc/en/faq
- https://www.coincashew.com/coins/overview-eth/guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-i-installation/guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node
- https://ethereum.stackexchange.com/questions/3887/how-to-reduce-the-chances-of-your-ethereum-wallet-getting-hacked
- https://docs.prylabs.network/docs/install/install-with-script
- https://7goldfish.com/Eth_Staking_Testnet_on_AWS.html
- https://mirror.xyz/steinkirch.eth/F5PI4eqShKTGlx0GzL0Lq0-vHQ6b14OoV4ylE2FMsAc
- https://consensys.net/blog/developers/my-journey-to-being-a-validator-on-ethereum-2-0-part-5/
- https://www.monkeyvault.net/secure-aws-infrastructure-with-vpc-a-terraform-guide/ (VPCs guide too)
- https://hackmd.io/@prysmaticlabs/HkSSMpDtt
- https://medium.com/@mshmulevich/running-ethereum-nodes-in-high-availability-cluster-on-aws-aefd08d4d81
- https://chasewright.com/getting-started-with-turbo-geth-on-ubuntu/
- https://someresat.medium.com/guide-to-staking-on-ethereum-ubuntu-prysm-581fb1969460
- https://www.blocknative.com/blog/ethereum-validator-lighthouse-geth
- https://www.youtube.com/watch?v=hHtvCGlPz-o
- https://kb.beaconcha.in/rewards-and-penalties
- https://hodldog.notion.site/PulseChain-Mainnet-Node-Validator-Guide-390243a66f3449a9a2425db25370ad89
- https://mirror.xyz/0xc8F1e4820b1C97043701969A870580aAbE1Ac771/-kB_7s0xaqF08Y5s0cD9eSqz8GHgvBxiFUJZq3lpvdE
- http://tinyurl.com/ValidatorPlaylist
