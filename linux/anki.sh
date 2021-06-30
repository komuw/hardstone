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

printf "\n\n download anki\n"
wget -nc --output-document=/tmp/anki_amd64.tar.bz2 "https://apps.ankiweb.net/downloads/current/anki-2.1.15-linux-amd64.tar.bz2"

printf "\n\n untar anki\n"
tar xjf "/tmp/anki_amd64.tar.bz2" -C /tmp/

printf "\n\n install anki\n"
cd /tmp/anki-2.1.15-linux-amd64
sudo make install
cd -
