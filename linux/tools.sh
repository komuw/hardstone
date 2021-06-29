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


printf "\n\n install ripgrep\n"
wget -nc --output-document=/tmp/ripgrep_amd64.deb "https://github.com/BurntSushi/ripgrep/releases/download/12.1.1/ripgrep_12.1.1_amd64.deb"
dpkg -i /tmp/ripgrep_amd64.deb


printf "\n\n install ripgrep-all(rga)\n"
if [[ ! -e /tmp/rga.tar.gz ]]; then
    wget --output-document=/tmp/rga.tar.gz "https://github.com/phiresky/ripgrep-all/releases/download/v0.9.6/ripgrep_all-v0.9.6-x86_64-unknown-linux-musl.tar.gz"
fi
tar -xzf /tmp/rga.tar.gz -C /tmp
mv /tmp/ripgrep_all-v0.9.6-x86_64-unknown-linux-musl/rga /usr/local/bin/rga
chmod +x /usr/local/bin/rga


printf "\n\n install mozilla rr debugger\n"
wget -nc --output-document=/tmp/rr_amd64.deb "https://github.com/rr-debugger/rr/releases/download/5.4.0/rr-5.4.0-Linux-x86_64.deb"
dpkg -i /tmp/rr_amd64.deb

install_zoom(){
    printf "\n\n install zoom\n"
    wget -nc --output-document=/tmp/zoom_amd64.deb https://zoom.us/client/latest/zoom_amd64.deb
    dpkg -i /tmp/zoom_amd64.deb
}
install_zoom

# install_nodeJs(){
#     printf "\n\n install nodeJs\n"
#     curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
#     apt-get install -y nodejs
# }
# install_nodeJs
