#!/usr/bin/env bash
if test "$BASH" = "" || "$BASH" -uc "a=();true \"\${a[@]}\"" 2>/dev/null; then
    # Bash 4.4, Zsh
    set -euo pipefail
else
    # Bash 4.3 and older chokes on empty arrays with set -u.
    set -eo pipefail
fi
shopt -s nullglob globstar


printf "\n\n  configure pritunl source list"
PRITUNL_CONFIG_FILE_CONTENTS='deb https://repo.pritunl.com/stable/apt bionic main'
PRITUNL_CONFIG_FILE=/etc/apt/sources.list.d/pritunl.list
touch "$PRITUNL_CONFIG_FILE"
grep -qF -- "$PRITUNL_CONFIG_FILE_CONTENTS" "$PRITUNL_CONFIG_FILE" || echo "$PRITUNL_CONFIG_FILE_CONTENTS" >> "$PRITUNL_CONFIG_FILE"

printf "\n\n  add pritunl key"
apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A
printf "\n\n  update"
apt-get -y update
printf "\n\n  install pritunl"
apt-get -y install pritunl-client-gtk

printf "\n\n  give dev instructions for steps to follow"
printf "\n\n download profile(vpn config)\n start pritunl client from apps\n click import profile (import the config file)\n click connect\n enter 2fa code and u r good to go."
