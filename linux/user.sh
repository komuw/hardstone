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


USER_PASSWORD=${1:-userPass}
if [ "$USER_PASSWORD" == "userPass"  ]; then
    printf "\n\n USER_PASSWORD should not be empty\n"
    exit
fi


printf "\n\n create user, if not exists. \n"
id -u komuw &>/dev/null || useradd --groups=sudo --create-home --password="$USER_PASSWORD" --shell=/bin/bash komuw
