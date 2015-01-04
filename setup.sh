#!/usr/bin/env bash
#
# Set up Ansible on a Vagrant Ubuntu box, and run 
# playbook/s to setup/provision

echo "starting setup/provisioning...."

if [[ ! $(ansible --version 2> /dev/null) =~ 1\.6 ]]; then
        sudo apt-get update && \
	sudo apt-get -y install python-software-properties && \
        sudo apt-get -y install software-properties-common && \
	sudo add-apt-repository -y ppa:rquillo/ansible && \
        sudo apt-get update && \
	sudo apt-get -y install ansible
fi

PYTHONUNBUFFERED=1 ansible-playbook main.yml -i dev --connection=local #-vvvvv
