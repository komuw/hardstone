#!/usr/bin/env bash


SSH_KEY_PHRASE=$1

if [ -z "$SSH_KEY_PHRASE" ]; then
    printf "\n\n SSH_KEY_PHRASE should not be empty"
    exit
fi


printf "\n\n starting setup/provisioning....\n"
apt-get -y update
apt-get -y install gcc \
                        build-essential \
                        libssl-dev \
                        libffi-dev \
                        python-dev \
                        software-properties-common \
                        python-pip
pip install --ignore-installed -U pip jinja2 paramiko
apt-get -y update
apt-get -y install ansible
pip install -U ansible

# When using the bash command to execute the scripts below;
# the script are executed as other processes, so variables and functions in the other scripts will not be accessible in the hardstone.sh script
# https://stackoverflow.com/questions/8352851/how-to-call-shell-script-from-another-shell-script

printf "\n\n CALLING provision.sh::\n\n"
/bin/bash provision.sh "$SSH_KEY_PHRASE"
printf "\n\n provision.sh done::\n"

printf "\n\n CALLING editors.sh::\n\n"
/bin/bash editors.sh
printf "\n\n editors.sh done::\n"

printf "\n\n CALLING golang.sh::\n\n"
/bin/bash golang.sh
printf "\n\n golang.sh done::\n"

printf "\n\n CALLING dart.sh::\n\n"
/bin/bash dart.sh
printf "\n\n dart.sh done::\n"

printf "\n\n CALLING work_stuff.sh::\n\n"
/bin/bash work_stuff.sh
printf "\n\n work_stuff.sh done::\n"

printf "\n\n CALLING xonsh.sh::\n\n"
/bin/bash xonsh.sh
printf "\n\n xonsh.sh done::\n"

printf "\n\n WHOLE SYSTEM SUCCESFULLY SETUP.\n"
