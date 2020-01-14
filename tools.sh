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


PECO_VERSION=v0.5.7
printf "\n\n install peco\n"
wget -nc --directory-prefix=/tmp "https://github.com/peco/peco/releases/download/$PECO_VERSION/peco_linux_amd64.tar.gz"
tar -xzf /tmp/peco_linux_amd64.tar.gz -C /tmp 
mv /tmp/peco_linux_amd64/peco /usr/local/bin/peco
chmod +x /usr/local/bin/peco

printf "\n\n install ripgrep\n"
wget -nc --directory-prefix=/tmp "https://github.com/BurntSushi/ripgrep/releases/download/11.0.2/ripgrep_11.0.2_amd64.deb"
dpkg -i /tmp/ripgrep_11.0.2_amd64.deb
