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

printf "\n\n install Java openJDK\n"
apt -y update
apt -y install default-jre
apt -y install default-jdk

printf "\n\n install intellij idea\n"
snap install intellij-idea-community --classic 
