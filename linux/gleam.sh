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


install_gleamLang() {
    GLEAM_VERSION="https://github.com/gleam-lang/gleam/releases/download/v0.14.3/gleam-v0.14.3-linux-amd64.tar.gz"

    printf "\n\n remove any current gleam \n"
    sudo rm -rf /usr/local/bin/gleam /tmp/gleam /tmp/gleam.tar.gz

    printf "\n\n  download gleam \n"
    wget -nc --output-document=/tmp/gleam.tar.gz "$GLEAM_VERSION"

    printf "\n\n  untar gleam file\n"
    tar -xvf /tmp/gleam.tar.gz -C /tmp/

    printf "\n\n add gleam to PATH: \n"
    chmod +x /tmp/gleam
    mv /tmp/gleam /usr/local/bin/gleam 
}

install_gleamLang