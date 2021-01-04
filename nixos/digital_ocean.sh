#!/usr/bin/env bash
shopt -s nullglob globstar
export DEBIAN_FRONTEND=noninteractive


digital_ocean_user(){
    adduser --disabled-password --gecos "" my_dummy_user
    usermod -aG sudo my_dummy_user
    rsync --archive --chown=my_dummy_user:my_dummy_user ~/.ssh /home/my_dummy_user
    passwd -d my_dummy_user
}
digital_ocean_user

git clone https://github.com/komuw/hardstone.git
cd hardstone/
git checkout nix
cd nixos/
bash start.sh
