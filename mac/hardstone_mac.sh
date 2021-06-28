#!/usr/bin/env bash
if test "$BASH" = "" || "$BASH" -uc "a=();true \"\${a[@]}\"" 2>/dev/null; then
    # Bash 4.4, Zsh
    set -euo pipefail
else
    # Bash 4.3 and older chokes on empty arrays with set -u.
    set -eo pipefail
fi
export DEBIAN_FRONTEND=noninteractive

MY_NAME=$(whoami)

SSH_KEY_PHRASE_PERSONAL=${1:-sshKeyPhrasePersonalNotSet}
if [ "$SSH_KEY_PHRASE_PERSONAL" == "sshKeyPhrasePersonalNotSet"  ]; then
    printf "\n\n SSH_KEY_PHRASE_PERSONAL should not be empty\n"
    exit
fi



printf "\n::INSTALL brew and stuff\n\n"
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew analytics off
brew update
brew cask install iterm2

printf "\n::INSTALL some apps via brew\n\n"
brew install ack \
             autojump \
             automake \
             colordiff \
             curl \
             imagemagick \
             ossp-uuid \
             qt \
             readline \
             wget \
             pstree \
             bat \
             shellcheck \
             tfenv \
             rlwrap


printf "\n\n create personal ssh-key\n"
if [[ ! -e /Users/$MY_NAME/.ssh/personal_id_rsa.pub ]]; then
    mkdir -p /Users/$MY_NAME/.ssh
    ssh-keygen -t rsa -C "$MY_NAME@Mac" -b 8192 -q -N "$SSH_KEY_PHRASE_PERSONAL" -f /Users/$MY_NAME/.ssh/personal_id_rsa
fi
chmod 600 ~/.ssh/personal_id_rsa
chmod 600 ~/.ssh/personal_id_rsa.pub
chown -R $MY_NAME:staff /Users/$MY_NAME/.ssh

printf "\n::SHOW me my ssh key damn it\n\n"
cat /Users/$MY_NAME/.ssh/personal_id_rsa.pub


printf "\n::CREATE dirs\n\n"
mkdir -p /Users/$MY_NAME/work
mkdir -p /Users/$MY_NAME/mystuff

printf "\n::COPY conf files\n\n"
cp ../templates/ssh_conf.j2 /Users/$MY_NAME/.ssh/config
cp ../templates/mac/bash_aliases.j2 /Users/$MY_NAME/.bash_aliases
cp ../templates/mac/hgrc.j2 /Users/$MY_NAME/.hgrc


printf "\n::git config\n\n"
git config --global user.name "$MY_NAME"
git config --global user.email "$MY_NAME05@gmail.com"
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.hist "log --pretty=format:'%C(yellow)[%ad]%C(reset) %C(green)[%h]%C(reset) | %C(red)%s %C(bold red){{%an}}%C(reset) %C(blue)%d%C(reset)' --graph --date=short"

printf "\n\n configure gitattributes\n"
rm -rf ~/.gitattributes
touch ~/.gitattributes
echo '*.c     diff=cpp
*.h     diff=cpp
*.c++   diff=cpp
*.h++   diff=cpp
*.cpp   diff=cpp
*.hpp   diff=cpp
*.cc    diff=cpp
*.hh    diff=cpp
*.cs    diff=csharp
*.css   diff=css
*.html  diff=html
*.xhtml diff=html
*.ex    diff=elixir
*.exs   diff=elixir
*.go    diff=golang
*.php   diff=php
*.pl    diff=perl
*.py    diff=python
*.md    diff=markdown
*.rb    diff=ruby
*.rake  diff=ruby
*.rs    diff=rust' >> ~/.gitattributes


printf "\n\n install ripgrep\n"
if [[ ! -e /tmp/ripgrep.tar.gz ]]; then
    wget --output-document=/tmp/ripgrep.tar.gz "https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep-13.0.0-x86_64-apple-darwin.tar.gz"
fi
tar -xzf /tmp/ripgrep.tar.gz -C /tmp 
mv /tmp/ripgrep-13.0.0-x86_64-apple-darwin/rg /usr/local/bin/rg
chmod +x /usr/local/bin/rg

printf "\n\n install ripgrep-all(rga)\n"
if [[ ! -e /tmp/rga.tar.gz ]]; then
    wget --output-document=/tmp/rga.tar.gz "https://github.com/phiresky/ripgrep-all/releases/download/v0.9.6/ripgrep_all-v0.9.6-x86_64-apple-darwin.tar.gz"
fi
tar -xzf /tmp/rga.tar.gz -C /tmp
mv /tmp/ripgrep_all-v0.9.6-x86_64-apple-darwin/rga /usr/local/bin/rga
chmod +x /usr/local/bin/rga


printf "\n\n install Zsh \n"
brew install zsh
chsh -s /bin/zsh

printf "\n\n Install ohmyzsh \n"
rm -rf ~/.oh-my-zsh
git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh

printf "\n\n Install ohmyzsh plugins \n"
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions

printf "\n\n Add ohmyzsh config \n"
cp ../templates/zshrc.j2 ~/.zshrc

printf "\n\n change ownership of ohmyzsh dirs \n"
sudo chown -R $MY_NAME:staff /Users/$MY_NAME/.zshrc
sudo chown -R $MY_NAME:staff ~/.oh-my-zsh


printf "\n\n Install awscli \n"
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "/tmp/AWSCLIV2.pkg"
# this will install it inside /Applications/
sudo installer -pkg /tmp/AWSCLIV2.pkg -target /

printf "\n\n install kubectx\n"
if [[ ! -e /tmp/kubectx.tar.gz ]]; then
    wget --output-document=/tmp/kubectx.tar.gz "https://github.com/ahmetb/kubectx/releases/download/v0.9.3/kubectx_v0.9.3_darwin_x86_64.tar.gz"
fi
tar -xzf /tmp/kubectx.tar.gz -C /tmp
mv /tmp/kubectx /usr/local/bin/kubectx
chmod +x /usr/local/bin/kubectx

printf "\n\n install poetry\n"
curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/1.1.7/get-poetry.py | python3


install_vscode(){
    printf "\n::INSTALL Vscode\n\n"
    wget -nc --output-document=/tmp/vscode.zip https://code.visualstudio.com/sha/download?build=stable&os=darwin-universal
    unzip /tmp/vscode.zip -d /tmp/vscode
    mv "/tmp/vscode/Visual Studio Code.app/" /Applications/

    BASHRC_PROFILE_FILE=/Users/$MY_NAME/.bash_profile
    BASHRC_PROFILE_FILE_CONTENTS=$(cat <<-EOF

# Add Visual Studio Code to path
# https://code.visualstudio.com/docs/setup/mac
export PATH="\$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
EOF
)

    if  ! grep -q "Add Visual Studio Code to path" "$BASHRC_PROFILE_FILE"; then
      echo "adding vscode to path."
      echo "$BASHRC_PROFILE_FILE_CONTENTS" >> "$BASHRC_PROFILE_FILE"
    fi

    printf "\n\n  install vscode extensions\n"
    code --user-data-dir='.' --install-extension ms-python.python
    code --user-data-dir='.' --install-extension ms-python.vscode-pylance
    code --user-data-dir='.' --install-extension dart-code.dart-code
    code --user-data-dir='.' --install-extension dart-code.flutter
    code --user-data-dir='.' --install-extension donaldtone.auto-open-markdown-preview-single
    code --user-data-dir='.' --install-extension golang.go
    code --user-data-dir='.' --install-extension ms-azuretools.vscode-docker
    code --user-data-dir='.' --install-extension hashicorp.terraform
    # code --user-data-dir='.' --install-extension ms-vscode.cpptools
    code --list-extensions

    # https://code.visualstudio.com/docs/getstarted/settings#_settings-file-locations
    rm -rf "$HOME/Library/Application Support/Code/User/settings.json"
    cp ../templates/vscode.j2 "$HOME/Library/Application Support/Code/User/settings.json"
}
install_vscode


install_golang(){
    printf "\n::INSTALL golang\n\n"
    wget --output-document=/tmp/golang.pkg https://golang.org/dl/go1.16.darwin-amd64.pkg
    # this will install it inside /Applications/
    sudo installer -pkg /tmp/golang.pkg -target /

    printf "\n\n go install some golang packages\n"
    export PATH=$PATH:/usr/local/go/bin && \
    export PATH=$HOME/go/bin:$PATH
    go install github.com/rogpeppe/gohack@latest
    go install honnef.co/go/tools/cmd/staticcheck@latest
    go install github.com/go-delve/delve/cmd/dlv@latest
    go install golang.org/x/tools/gopls@latest
    go install golang.org/x/tools/cmd/godex@latest
    go install github.com/traefik/yaegi/cmd/yaegi@latest # yaegi repl. usage: rlwrap yaegi
    go install github.com/maruel/panicparse/v2/cmd/pp@latest
    go install github.com/securego/gosec/cmd/gosec@latest
    go install github.com/google/pprof@latest
    go install github.com/rs/curlie@latest
    go install github.com/tsenart/vegeta@latest
    go install mvdan.cc/gofumpt@latest
}
install_golang

install_dartlang(){
    printf "\n::INSTALL dartlang \n\n"
    brew tap dart-lang/dart
    brew install dart --head
    brew update
    brew upgrade dart
    brew reinstall --force dart
}
install_dartlang

install_terraform(){
    printf "\n\n install terraform\n"
    tfenv install latest
    tfenv install 1.0.1
    tfenv use latest
}
install_terraform


# install_ecr_login_bash_helper(){
# printf "\n\n Add `ecr_login` bash helper function \n"
# BASHRC_PROFILE_FILE_CONTENTS="""
# function ecr_login () {
#   # login to AWS ECR.
#   local profile="\$1" # escape so that they remain
#   local aws_account_id="\$2"
#   aws --profile "\$profile" --region eu-west-1 ecr get-login-password | \
#   docker login --username AWS --password-stdin "\$aws_account_id".dkr.ecr.eu-west-1.amazonaws.com
# }"""
# BASHRC_PROFILE_FILE=/Users/$MY_NAME/.bash_profile
# if  ! grep -q "ecr_login" "$BASHRC_PROFILE_FILE"; then
#   echo "adding ecr_login bash helper function."
#   echo "$BASHRC_PROFILE_FILE_CONTENTS" >> "$BASHRC_PROFILE_FILE"
# fi
# }
# install_ecr_login_bash_helper

# install_pritunl(){
#     printf "\n\n install Pritunl\n"
#     if [[ ! -e /tmp/pritunl.pkg.zip ]]; then
#         wget --output-document=/tmp/pritunl.pkg.zip "https://github.com/pritunl/pritunl-client-electron/releases/download/1.0.2440.93/Pritunl.pkg.zip"
#     fi
#     unzip /tmp/pritunl.pkg.zip -d /tmp/pritunl
#     sudo installer -pkg /tmp/pritunl/Pritunl.pkg -target /
# }
# install_pritunl

# install_java(){
#     printf "\n\n install Java AWS Corretto openJDK\n"
#     # java11 is an LTS
#     if [[ ! -e /tmp/amazon_corretto.tar.gz ]]; then
#         wget --output-document=/tmp/amazon_corretto.tar.gz https://corretto.aws/downloads/latest/amazon-corretto-11-x64-macos-jdk.tar.gz
#     fi
#     mkdir -p /Library/Java/JavaVirtualMachines/
#     sudo chown -R $MY_NAME:staff /Library/Java/JavaVirtualMachines/
#     tar -xzf /tmp/amazon_corretto.tar.gz -C /Library/Java/JavaVirtualMachines/
#     java -version
#     javac -version
#     brew install gradle
# }
# install_java

# install_zig() {
#     printf "\n\n remove any current zig files\n"
#     sudo rm -rf /usr/local/zigDir && sudo mkdir -p /usr/local/zigDir && sudo chown -R $MY_NAME /usr/local/zigDir

#     printf "\n\n  download zig from master branch(change when zig gets to ver1)\n"
#     # TODO: parse content from https://ziglang.org/download/index.json
#     LATEST_ZIG_MASTER=$(curl -s 'https://ziglang.org/download/index.json' | python3 -c "import sys, json; print(json.load(sys.stdin)['master']['x86_64-macos']['tarball'])")
#     printf "\nLATEST_ZIG_MASTER is: $LATEST_ZIG_MASTER\n"

#     wget -nc --output-document=/usr/local/zigDir/zig.tar.xz $LATEST_ZIG_MASTER
#     printf "\n\n  untar zig file\n"
#     tar -xf /usr/local/zigDir/zig.tar.xz -C /usr/local/zigDir --strip-components 1

#     # todo: add zig to $PATH
#     printf "\n\n use zig as: \n"
#     printf "\t /usr/local/zigDir/zig fmt .; /usr/local/zigDir/zig run main.zig \n"

#     # to install on Osx u can also use: brew install zig --HEAD
# }
# install_zig

# install_gleamLang() {
#     GLEAM_VERSION="https://github.com/gleam-lang/gleam/releases/download/v0.14.3/gleam-v0.14.3-macos.tar.gz"

#     printf "\n\n remove any current gleam \n"
#     sudo rm -rf /usr/local/bin/gleam /tmp/gleam /tmp/gleam.tar.gz

#     printf "\n\n  download gleam \n"
#     wget -nc --output-document=/tmp/gleam.tar.gz "$GLEAM_VERSION"

#     printf "\n\n  untar gleam file\n"
#     tar -xvf /tmp/gleam.tar.gz -C /tmp/

#     printf "\n\n add gleam to PATH: \n"
#     chmod +x /tmp/gleam
#     mv /tmp/gleam /usr/local/bin/gleam

#     printf "\n\n install erlang & rebar3 \n"
#     brew update
#     brew install erlang
#     brew install rebar3
# }
# install_gleamLang
