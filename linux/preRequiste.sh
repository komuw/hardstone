#!/usr/bin/env bash
if test "$BASH" = "" || "$BASH" -uc "a=();true \"\${a[@]}\"" 2>/dev/null; then
    # Bash 4.4, Zsh
    set -euo pipefail
else
    # Bash 4.3 and older chokes on empty arrays with set -u.
    set -eo pipefail
fi
shopt -s nullglob globstar
export DEBIAN_FRONTEND=noninteractive

MY_NAME=$(whoami)


printf "\n\n add current user to sudo group\n"
sudo usermod -aG sudo $MY_NAME

printf "\n\n starting setup/provisioning....\n"
printf "\n\n install pre-requiste stuff reequired by the other scripts. \nthe other scripts should be able to run in parallel....\n"
sudo rm -rf /etc/apt/sources.list.d/*
sudo rm -rf /tmp/*
sudo apt-get -y update
sudo apt-get -y install gcc \
                    build-essential \
                    libssl-dev \
                    libffi-dev \
                    python-dev \
                    software-properties-common \
                    curl \
                    wget \
                    git

# If you need pip see:: https://github.com/pypa/pip/issues/5240
sudo apt-get -y update

printf "\n\n set locale\n"
sudo chown -R $MY_NAME:sudo /etc/profile
LOCALE_CONFIG_FILE_CONTENTS='

#locale
export LC_ALL="en_US.UTF-8"'
grep -qF -- "$LOCALE_CONFIG_FILE_CONTENTS" /etc/profile || echo "$LOCALE_CONFIG_FILE_CONTENTS" >> /etc/profile
