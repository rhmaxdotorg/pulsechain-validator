# PulseChain Testnet Validator Node Setup Helper Scripts

![pls-testnet-validator-htop](https://user-images.githubusercontent.com/100790377/229965674-75593b5a-3fa6-44fe-8f47-fc25e9d3ce21.png)

This will help you setup [PulseChain](www.pulsechain.com) Testnet v4 and plans are to update it to support [PulseChain](www.pulsechain.com) Mainnet as well after it launches.

**Please read ALL the instructions as they will explain and tell you how to run these scripts and the caveats.**

To download these scripts on your server, you can `git clone https://github.com/rhmaxdotorg/pulsechain-validator.git`.

After you download the code, you may need to `chmod +x *.sh` to make all the scripts executable and able to run on the system.

# Description

The setup script installs pre-reqs, golang, rust, go-pulse (geth fork) and lighthouse on a fresh, clean Ubuntu OS for getting a PulseChain Testnet (V4) Validator Node setup and running with **Geth (go-pulse)** and **Lighthouse** clients.

There are other helper scripts that do various things, check the notes for each one specifically for more info.

You can run **pulsechain-validator-setup.sh** to setup your validator clients and **monitoring-setup.sh** afterwards to install the graphs and monitoring software.

Note: the pulsechain validator setup script DOES NOT install monitoring/metrics packages such as Grafana or Prometheus, you would need to run it AND THEN run the monitoring-setup.sh script provided. Do not run the monitoring script before installing your validator clients. See details [below](https://github.com/rhmaxdotorg/pulsechain-validator#setting-up-monitoring-with-prometheus-and-grafana).

# Video Walkthrough
Check out these videos for further explanations and code walkthroughs.
- https://www.youtube.com/watch?v=X0TnkLt4E3w
- https://www.youtube.com/watch?v=QqcDs8llyyw
- https://www.youtube.com/watch?v=YFOxf4B27Zs
- https://www.youtube.com/watch?v=9Yibmetppcs

# Usage

```
$ ./pulsechain-validator-setup.sh [0x...YOUR ETHEREUM FEE ADDRESS] [12.89...YOUR SERVER IP ADDRESS]
```

## Command line options

- **ETHEREUM FEE ADDRESS** is the FEE_RECIPIENT value for --suggested-fee-recipient to a wallet address you want to recieve priority fees from users whenever your validator proposes a new block (else it goes to the burn address)

- **SERVER_IP_ADDRESS** to your validator server's IP address

Note: you may get prompted throughout the process to hit [Enter] for OK and continue the process

For example when running Ubuntu on AWS EC2 cloud service, you can expect to hit OK on kernel upgrade notice, [Enter] or "1" to continue Rust install process and so on.

**If you encounter errors running the script and want to run the script again, use the [Reset the Validator](https://github.com/rhmaxdotorg/pulsechain-validator/blob/main/README.md#reset-validator-script) BEFORE running it over and over again.**

Just make sure you know what you're doing and manually edit the reset script to bypass the "I don't know what I'm doing" check. It's very straightforward, just read the code, acknowledge you know what the script it doing and **change I_KNOW_WHAT_I_AM_DOING=false to true to get it to run**.

# Environment
Tested on **Ubuntu 22.04** (on Amazon AWS EC2 /w M2.2Xlarge server) running as a non-root user (ubuntu) with sudo privileges.

# Hardware
The consensus on the minimum *recommended* requirements to run a validator seem to be 32gb RAM, 2TB disk and plenty of processing power (quadcore, xeon/ryzen, 4-8 vCPUs and such). These can come in the form of buying or building your own server and paying an upfront cost, utilities and maintenance OR renting a server from a VPS/cloud provider such as Amazon AWS (M2.2Xlarge server) and paying monthly to use their platform and resources. Both have advantages and disadvantages as well as varying time, monetary and management costs.

Could you get by with an old PC under your desk with a $50 battery backup? Maybe, but that would not be *recommended*. I'd rather not skimp on hardware for things that I would plan to run for years and pay for the peace of mind of not worrying about what I'm going to do if X fails one day, wishing I'd started with stronger foundations. If you try and do it right the first time, you might save a lot of time and headache.

# After running the script

The script automates a roughly estimated ~85% of what it takes to get the validator configured, but there's still a few manual steps you need to do to complete the setup and get the validator on the network.

**Generate validator keys with deposit tool and import them into Lighthouse**

**Run the staking deposit client (ON A DIFFERENT MACHINE, see notes below for details)**
```
$ sudo apt install -y python3-pip
$ git clone https://gitlab.com/pulsechaincom/staking-deposit-cli.git
$ cd staking-deposit-cli && pip3 install -r requirements.txt && sudo python3 setup.py install
$ ./deposit.sh new-mnemonic --chain=pulsechain-testnet-v4
```

**Then follow the instructions from there, copy them over to the validator and import into lighthouse AS THE NODE USER (not the 'ubuntu' user on ec2).**
```
$ sudo cp -R validator_keys /home/node
$ sudo chown -R node:node /home/node/validator_keys
$ sudo -u node bash

(as node user)
$ /opt/lighthouse/lighthouse/lh account validator import --directory ~/validator_keys --network=pulsechain_testnet_v4

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
```

**Start the beacon and validator clients**
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

**Once the blockchain clients are synced, you can make your 32m tPLS deposit (per validator)**

You can have multiple on one machine. The deposit is made @ https://launchpad.v4.testnet.pulsechain.com to get your validator activated and participating on the network.

If you do the deposit before the clients are fully synced and ready to go, then you risk penalities as your validator would join the network, but due to not being synced, unable to participate in validator duties (until it's fully synced).

Now let's get validating! @rhmaximalist

# Debugging

## Check the Blockchain Sync Progress

### Geth
```
$ curl -s http://localhost:8545 -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":67}' | jq

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
$ curl -s http://localhost:8545 -H "Content-Type: application/json" --data "{\"jsonrpc\":\"2.0\",\"method\":\"eth_syncing\",\"params\":[],\"id\":67}" | jq
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

# Reset Validator Script
This helper script deletes all your validator data so you can try the setup again if you want a fresh install or feel like you made an error.

Be careful! It deletes and resets things, so read the code and make sure you understand what it does before using it.

# AWS EC2 Helper Script
Just some nice-to-haves if you're using the AWS Cloud for your validator server.

# AWS Cloud Setup
* [How to run a cloud server on AWS](https://docs.google.com/document/d/1eW0SDT8IvZrla7gywK32Rl3QaQtVoiOu5OaVhUKIDg8/edit)

AWS also offers a [free tier](https://aws.amazon.com/free/free-tier-faqs/) option that allows you to spin up Linux VMs for free for a certain period of time, so you could use that for quick and easy tiny VMs running Ubuntu Linux. They are not beefy enough to be a validator, so that's not an option, but they are fine for small tasks and learning. You just need to sign up for an account and follow the instructions in the above document, except choose Free Tier options instead of the validator hardware configuration as described.

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

You can setup grafana for secure access externally as opposed to the less secure way of forwarding port 3000 on the firewall and open it up to the world, which could put your server at risk next time Grafana has a security bug that anyone interested enough can exploit.

```
ssh -i key.pem -N ubuntu@validator-server-IP -L 8080:localhost:3000
```

Then open a browser window on your computer and login to grafana yourself without exposing it externally to the world. Magic, huh!

Go to http://localhost:8080 and login with admin/admin (as the initial username/password). It will then ask you to set a new password, make it a good one.

In the lower left bar area, click the gear box -> Data Sources -> Add Data Source.
- Select Prometheus
- URL: http://localhost:9090
- Click Save & Test
- It should say “Datasource is working” in green

Use your mouse cursor to hover over the Dashboards icon (upper left bar area, 4 squares icon).
- Select Import
- Upload each JSON dashboard

Geth
- Download it @ https://gist.githubusercontent.com/karalabe/e7ca79abdec54755ceae09c08bd090cd/raw/3a400ab90f9402f2233280afd086cb9d6aac2111/dashboard.json to import
- Name: Geth
- Datasource: Prometheus (default)
- Click Import
- Click Save button (and confirm Save) in upper right toolbar
- Repeat for next dashboard

Lighthouse VC
- Download it @ https://raw.githubusercontent.com/sigp/lighthouse-metrics/master/dashboards/ValidatorClient.json to import
- Name: Lighthouse VC
- Datasource: Prometheus (default)
(same steps as previous)

Lighthouse Beacon
- Download it @ https://raw.githubusercontent.com/sigp/lighthouse-metrics/master/dashboards/Summary.json to import
- Name: Lighthouse Beacon
- Datasource: Prometheus (default)
(same steps as previous)

Now you can browse Dashboards and see various stats and data!

Also see the guides below for additional help (scripts were mostly based on those instructions)
* https://www.coincashew.com/coins/overview-eth/guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-i-installation/monitoring-your-validator-with-grafana-and-prometheus
* https://schh.medium.com/port-forwarding-via-ssh-ba8df700f34d

# Community Guides and Scripts
* https://gitlab.com/davidfeder/validatorscript/-/blob/5fa11c7f81d8292779774b8dff9144ec3e44d26a/PulseChain_V3_Script.txt
* https://www.hexpulse.info/docs/node-setup.html
* https://togosh.medium.com/pulsechain-validator-setup-guide-70edae00b344
* https://github.com/tdslaine/install_pulse_node

# Security
* https://www.youtube.com/watch?v=hHtvCGlPz-o
* https://www.coincashew.com/coins/overview-eth/guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-i-installation/guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node

# FAQ

* What server specs do you need to be a validator?

Specs and preferences vary between who you talk to, but at least 32gb ram and a beefy i7 or server-based processor and 2TB SSD hard disk. In the cloud, this roughly translates into a M2.2XLarge EC2 instance + 2TB disk.

* How long does it take to sync the blockchain clients?

It depends on your bandwidth, server specs and the state of the network, but you should expect anywhere from 24 - 96hrs for a validator node to sync.

* How can I see the stats on my validator(s)?

Look at your deposit JSON file to get the list of your validator(s) public keys, then check https://beacon.v4.testnet.pulsechain.com/validator/ + your validator's public key which each one that you want to check the stats on.

For example this validator's stats: https://beacon.v4.testnet.pulsechain.com/validator/8001503cd43190b01aaa444d966a41ddb95c140e4910bb00ad638a4c020bc3a070612f318e3372109f33e40e7c268b0b

* What if my validator stops working?

Did your server's IP address change? If so, update lighthouse beacon service file @ /etc/systemd/system/lighthouse-beacon.service.

Did your network/firewall role change? Make sure the required client ports are accessible.

What is your status on the beacon explorer? Active, Pending, Exited or something else? If not active, it may be a client issue which you can debug with the steps discussed in the Debugging section.

Are your clients fully synced? They must be synced, talking to each other and talking to the network for the validator to work properly.

* How much does it cost to be a validator?

Depends on if you're using your own hardware or the cloud. For example, you could build or buy your own hardware for initial cost of around $2k and then pay for electricity it uses from running 24/7 each month. Or you can rent a server in the Amazon AWS cloud for an estimated $300-$500 per month. Both ways have advantages and disadvantages.

* Where can I find additional help on PulseChain dev stuff and being a validator?

https://t.me/PulseDev

# Additional Resources and References
- https://gitlab.com/pulsechaincom
- https://gammadevops.substack.com/p/part-1-introduction-to-validator
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
