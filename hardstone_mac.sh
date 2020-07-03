#!/usr/bin/env bash
if test "$BASH" = "" || "$BASH" -uc "a=();true \"\${a[@]}\"" 2>/dev/null; then
    # Bash 4.4, Zsh
    set -euo pipefail
else
    # Bash 4.3 and older chokes on empty arrays with set -u.
    set -eo pipefail
fi
export DEBIAN_FRONTEND=noninteractive



SSH_KEY_PHRASE_PERSONAL=${1:-sshKeyPhrasePersonalNotSet}
if [ "$SSH_KEY_PHRASE_PERSONAL" == "sshKeyPhrasePersonalNotSet"  ]; then
    printf "\n\n SSH_KEY_PHRASE_PERSONAL should not be empty\n"
    exit
fi



# printf "\n::INSTALL brew and stuff\n\n"
# /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
# brew analytics off
# brew update
# brew cask install iterm2

# printf "\n::INSTALL some apps via brew\n\n"
# brew install ack \
#              autojump \
#              automake \
#              colordiff \
#              curl \
#              imagemagick \
#              ossp-uuid \
#              qt \
#              readline \
#              wget \
#              pstree \
#              bat


printf "\n\n create personal ssh-key\n"
if [[ ! -e /Users/komuw/.ssh/personal_id_rsa.pub ]]; then
    mkdir -p /Users/komuw/.ssh
    ssh-keygen -t rsa -C "komuw@Mac" -b 8192 -q -N "$SSH_KEY_PHRASE_PERSONAL" -f /Users/komuw/.ssh/personal_id_rsa
fi
chmod 600 ~/.ssh/personal_id_rsa
chmod 600 ~/.ssh/personal_id_rsa.pub
chown -R komuw:staff /Users/komuw/.ssh

printf "\n::SHOW me my ssh key damn it\n\n"
cat /Users/komuw/.ssh/personal_id_rsa.pub


printf "\n::CREATE dirs\n\n"
mkdir -p /Users/komuw/swat
mkdir -p /Users/komuw/mystuff


printf "\n::INSTALL golang\n\n"
brew install golang


printf "\n\n install https://github.com/myitcv/gobin \n"
export PATH=$PATH:/usr/local/go/bin && \
export PATH=$HOME/go/bin:$PATH
go get -u github.com/myitcv/gobin

printf "\n\n gobin install some golang packages\n"
export PATH=$PATH:/usr/local/go/bin && \
export PATH=$HOME/go/bin:$PATH
gobin -u github.com/rogpeppe/gohack
gobin -u honnef.co/go/tools/cmd/staticcheck@2020.1.4
gobin -u github.com/go-delve/delve/cmd/dlv
gobin -u golang.org/x/tools/gopls
gobin -u github.com/containous/yaegi/cmd/yaegi # yaegi repl. usage: rlwrap yaegi
gobin -u github.com/maruel/panicparse/cmd/pp
gobin -u github.com/securego/gosec/cmd/gosec
gobin -u github.com/google/pprof
gobin -u github.com/rs/curlie
gobin -u github.com/tsenart/vegeta


printf "\n::INSTALL dartlang \n\n"
brew tap dart-lang/dart
brew install dart --head
brew update
brew upgrade dart


printf "\n::COPY conf files\n\n"
cp templates/mac/bash_aliases.j2 /Users/komuw/.bash_aliases
cp templates/mac/gitconfig.j2 /Users/komuw/.ssh/config
cp templates/mac/hgrc.j2 /Users/komuw/.hgrc
cp templates/pep8.j2 /Users/komuw/.config/pep8


printf "\n::git config\n\n"
git config --global user.name "komuW"
git config --global user.email "komuw05@gmail.com"
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.hist "log --pretty=format:'%C(yellow)[%ad]%C(reset) %C(green)[%h]%C(reset) | %C(red)%s %C(bold red){{%an}}%C(reset) %C(blue)%d%C(reset)' --graph --date=short"


printf "\n\n install Java AWS Corretto openJDK\n"
# java11 is an LTS
if [[ ! -e /tmp/amazon_corretto.tar.gz ]]; then
    wget --output-document=/tmp/amazon_corretto.tar.gz https://corretto.aws/downloads/latest/amazon-corretto-11-x64-macos-jdk.tar.gz
fi
tar -xzf /tmp/amazon_corretto.tar.gz -C /Library/Java/JavaVirtualMachines/
java -version
javac -version
brew install gradle

printf "\n\n install ripgrep\n"
if [[ ! -e /tmp/ripgrep.tar.gz ]]; then
    wget --output-document=/tmp/ripgrep.tar.gz "https://github.com/BurntSushi/ripgrep/releases/download/12.1.1/ripgrep-12.1.1-x86_64-apple-darwin.tar.gz"
fi
tar -xzf /tmp/ripgrep.tar.gz -C /tmp 
mv /tmp/rripgrep-12.1.1-x86_64-apple-darwin/rg /usr/local/bin/rg
chmod +x /usr/local/bin/rg



printf "\n\n install Zsh \n"
brew install zsh
chsh -s $(which zsh)

printf "\n\n Install ohmyzsh \n"
rm -rf ~/.oh-my-zsh
git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh

printf "\n\n Install ohmyzsh plugins \n"
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions

printf "\n\n Add ohmyzsh config \n"
cp templates/zshrc.j2 ~/.zshrc

printf "\n\n change ownership of ohmyzsh dirs \n"
chown -R komuw:staff /Users/komuw/.zshrc
chown -R komuw:staff ~/.oh-my-zsh


printf "\n\n Install awscli \n"
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
# this will install it inside /Applications/
sudo installer -pkg AWSCLIV2.pkg -target /


