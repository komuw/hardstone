#!/usr/bin/env bash
#
# Set up Ansible on a Vagrant Ubuntu box, and run 
# playbook/s to setup/provision

SSH_KEY_PHRASE=$1

if [ -z "$SSH_KEY_PHRASE" ]; then
    printf "\n\n SSH_KEY_PHRASE should not be empty"
    exit
fi


echo "starting setup/provisioning...."

if [[ ! $(ansible --version 2> /dev/null) =~ 1\.6 ]]; then
    sudo apt-get -y update && \
    sudo apt-get -y install gcc build-essential libssl-dev libffi-dev python-dev && \
    sudo apt-get -y install python-software-properties && \
    sudo apt-get -y install software-properties-common && \
    sudo apt-get -y install python-pip && \
    sudo pip install --ignore-installed -U pip && \
    sudo pip install --ignore-installed jinja2 && \
    sudo pip install --ignore-installed paramiko && \
    sudo apt-get update && \
    sudo apt-get -y install ansible && \
    sudo pip install ansible
fi

printf "\n\n CALLING provision.sh::\n\n"
provision.sh "$SSH_KEY_PHRASE"

printf "\n\n CALLING editors.sh::\n\n"
editors.sh

printf "\n\n CALLING golang.sh::\n\n"
golang.sh

printf "\n\n CALLING dart.sh::\n\n"
dart.sh

printf "\n\n CALLING work_stuff.sh::\n\n"
work_stuff.sh

printf "\n\n CALLING xonsh.sh::\n\n"
xonsh.sh
