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

printf "\n\n update cache\n"
apt-get -y update

printf "\n\n Install zsh \n"
apt-get -y install zsh

printf "\n\n Install ohmyzsh \n"
rm -rf ~/.oh-my-zsh
git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh

printf "\n\n Install ohmyzsh plugins \n"
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions

printf "\n\n Add ohmyzsh config \n"
cp templates/zshrc.j2 ~/.zshrc

printf "\n\n  activate zsh shell\n"
chsh -s $(which zsh)
