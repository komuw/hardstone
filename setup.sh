#!/usr/bin/env bash
#
# Set up Ansible on a Vagrant Ubuntu box, and run 
# playbook/s to setup/provision

echo "starting setup/provisioning...."

if [[ ! $(ansible --version 2> /dev/null) =~ 1\.6 ]]; then
    sudo apt-get update && \
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

PYTHONUNBUFFERED=1 ansible-playbook main.yml -i dev --connection=local #-vvvvv
