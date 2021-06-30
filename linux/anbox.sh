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

printf "\n\n install anbox\n"
sudo snap install --devmode --beta anbox

printf "\n\n install adb(android-tools-adb)\n"
sudo apt -y install android-tools-adb

printf "\n\n install showmax"
printf "\n\n 1. go to https://apkpure.com and download showmax"
printf "\n\n 2. then install it as `adb install showmax.apk`"

printf "/n/n NB: anbox does not currently support video playback. \n So showmax wont work. https://github.com/anbox/anbox/issues/956"