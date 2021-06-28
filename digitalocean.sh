#!/usr/bin/env bash
if test "$BASH" = "" || "$BASH" -uc "a=();true \"\${a[@]}\"" 2>/dev/null; then
    # Bash 4.4, Zsh
    set -euo pipefail
else
    # Bash 4.3 and older chokes on empty arrays with set -u.
    set -eo pipefail
fi
shopt -s nullglob globstar

export DEBIAN_FRONTEND=noninteractive && \
apt -y update && \
apt -y install python && \
apt -y install python3-pip nano wget unzip curl screen

rm -rf $HOME/stuff
mkdir -p $HOME/stuff
cd $HOME/stuff

wget -nc --output-document=$HOME/stuff/hardstone.zip https://github.com/komuw/hardstone/archive/refs/heads/master.zip
unzip hardstone.zip
mv hardstone-master/ hardstone
cd $HOME/stuff/hardstone/linux/

screen -S hardstone
screen -ls
