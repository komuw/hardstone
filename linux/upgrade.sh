#!/usr/bin/env bash
if test "$BASH" = "" || "$BASH" -uc "a=();true \"\${a[@]}\"" 2>/dev/null; then
    # Bash 4.4, Zsh
    set -xeuo pipefail
else
    # Bash 4.3 and older chokes on empty arrays with set -u.
    set -xeo pipefail
fi
shopt -s nullglob globstar
export DEBIAN_FRONTEND=noninteractive

printf "\n\n  upgrade ubuntu\n"
sudo apt -y update
sudo apt -y full-upgrade
sudo apt -y dist-upgrade
sudo apt -y autoremove
sudo do-release-upgrade
sudo apt -y autoremove
