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


printf "\n\n  install xonsh and dependencies\n"
python3 -m pip install -U xonsh ptk prompt_toolkit pygments

printf "\n\n  configure xonsh.config.json.j2\n"
XONSH_CONFIG_FILE_CONTENTS='# docs:
# 1. http://xon.sh/envvars.html
# 2. http://xon.sh/xonshrc.html
# 3. https://github.com/gforsyth/dotfiles/blob/master/.xonshrc
$SHELL_TYPE="prompt_toolkit"
$XONSH_SHOW_TRACEBACK = True
$XONSH_STORE_STDOUT = True
$AUTO_SUGGEST = True
$XONSH_CACHE_EVERYTHING = True
$INDENT = "`·.,¸,.·*¯`·.,¸,.·*¯"
$MULTILINE_PROMPT = "`·.,¸,.·*¯`·.,¸,.·*¯"
$PATH = ["$HOME/.nvm/bin/", "$HOME/go/bin", "/usr/local/go/bin", "/usr/local/go/bin", "/usr/local/flutter/bin", "/usr/local/sbin", "/usr/local/bin", "/usr/sbin", "/usr/bin", "/sbin:/bin", "/usr/games", "/usr/local/games", "/snap/bin", "/usr/local/lib/python2.7/dist-packages", "/usr/local/lib/python3.5/dist-packages", "/usr/local/lib/python3.6/dist-packages/", "/usr/lib/dart/bin", "/home/komuw/.pub-cache/bin"]
$PROMPT = "{user}:{short_cwd}({curr_branch}{branch_color})>"
$TITLE = "{short_cwd}:{curr_branch}"
$XONSH_DATETIME_FORMAT = "%M:%H %d-%m-%Y"'
XONSH_CONFIG_FILE=/home/komuw/.xonshrc
touch "$XONSH_CONFIG_FILE"
grep -qF -- "$XONSH_CONFIG_FILE_CONTENTS" "$XONSH_CONFIG_FILE" || echo "$XONSH_CONFIG_FILE_CONTENTS" >> "$XONSH_CONFIG_FILE"

printf "\n\n  add xonsh to shells\n"
ETC_SHELLS_CONFIG_FILE_CONTENTS='/usr/local/bin/xonsh'
ETC_SHELLS_CONFIG_FILE=/etc/shells
touch "$ETC_SHELLS_CONFIG_FILE"
grep -qF -- "$ETC_SHELLS_CONFIG_FILE_CONTENTS" "$ETC_SHELLS_CONFIG_FILE" || echo "$ETC_SHELLS_CONFIG_FILE_CONTENTS" >> "$ETC_SHELLS_CONFIG_FILE"

printf "\n\n  activate xonsh shell\n"
chsh -s /usr/local/bin/xonsh
