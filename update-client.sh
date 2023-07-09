#!/usr/bin/env bash
#
# PulseChain Client update helper script stuff to pull down latest code for Geth (go-pulse) and Lighthouse on a validator server
#

I_KNOW_WHAT_I_AM_DOING=false # CHANGE ME ONLY IF YOU TRULY UNDERSTAND

if [ "$I_KNOW_WHAT_I_AM_DOING" = false ]; then
    echo "Make sure you understand what this script does, then flip I_KNOW_WHAT_I_AM_DOING to true if you want to run it"
    exit 1
fi

NODE_USER="node"

trap sigint INT

function sigint() {
    exit 1
}

# client repos for reference
#GETH_REPO="https://gitlab.com/pulsechaincom/go-pulse.git"
#LIGHTHOUSE_REPO="https://gitlab.com/pulsechaincom/lighthouse-pulse.git"

echo -e "ARE YOU SURE YOU WANT TO GO OFFLINE TO STOP, UPDATE AND RESTART PULSECHAIN CLIENTS ON THE VALIDATOR?\n"
echo -e "* it could take 30 - 60 minutes to complete -- depending mostly on bandwidth and server specs *\n"

read -p "Hit [Enter] to Continue OR Ctrl+C to Cancel"

echo -e "\nStep 1: Prepare client environment (Geth and Lighthouse)"

# Continue validating and once we have pulled the latest changes and built the
# latest binaries, we will gracefully restart the processes to run the latest changes

# update git config
sudo -u $NODE_USER bash -c "cd \$HOME && git config --global user.name client"
sudo -u $NODE_USER bash -c "cd \$HOME && git config --global user.email client@update.now"
sudo -u $NODE_USER bash -c "cd \$HOME && git config --global pull.rebase true"

# fix perms and make sure rust is properly installed in the environment
#sudo -u node bash -c "cd \$HOME && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
sudo -u $NODE_USER bash -c "cd \$HOME && source \$HOME/.cargo/env && rustup install stable && rustup default stable"
sudo chown -R $NODE_USER:$NODE_USER /home/$NODE_USER/.cargo

echo -e "\nStep 2: Pull updates and rebuild clients\n"

# pull updates from official repos for geth
sudo -u $NODE_USER bash -c "cd /opt/geth && git pull && make"

# pull updates from official repos for lighthouse
sudo -u $NODE_USER bash -c "cd \$HOME && source \$HOME/.cargo/env && rustup default stable"
sudo -u $NODE_USER bash -c "cd \$HOME && source \$HOME/.cargo/env && cd /opt/lighthouse && git pull && make"

echo -e "\nStep 3: Restarting PulseChain clients"

# restart updated services to gracefully stop "old" binaries and start the newly built ones
sudo systemctl restart geth lighthouse-beacon lighthouse-validator

echo -e "\nProcess is complete"
