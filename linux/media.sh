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


install_media_codecs(){
    printf "\n\n install media codecs\n"
    
    apt-get -y update
    echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections  # agree to ttf-mscorefonts-installer license(prepare media codecs install)
    apt-get -y install ubuntu-restricted-extras                                                                  # install system packages  media codecs
}
install_media_codecs

# printf "\n\n  install acestreamplayer\n"
# snap install acestreamplayer

