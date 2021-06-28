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

printf "\n\n  install xonsh and dependencies\n"
# we need prompt_toolkit < 2.0 see bug; https://github.com/xonsh/xonsh/issues/2662
python3 -m pip install -U xonsh ptk prompt_toolkit==1.0.15 pygments

printf "\n\n  configure xonsh.config.json.j2\n"
touch /home/$MY_NAME/.xonshrc
cp ../templates/xonsh.j2 /home/$MY_NAME/.xonshrc

printf "\n\n  add xonsh to shells\n"
ETC_SHELLS_CONFIG_FILE_CONTENTS='/usr/local/bin/xonsh'
ETC_SHELLS_CONFIG_FILE=/etc/shells
touch "$ETC_SHELLS_CONFIG_FILE"
grep -qF -- "$ETC_SHELLS_CONFIG_FILE_CONTENTS" "$ETC_SHELLS_CONFIG_FILE" || echo "$ETC_SHELLS_CONFIG_FILE_CONTENTS" >> "$ETC_SHELLS_CONFIG_FILE"

printf "\n\n  activate xonsh shell\n"
chsh -s /usr/local/bin/xonsh
