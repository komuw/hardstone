#!/bin/bash

while :
do
   case "$1"
     in
     --ssh_passphrase)
     SSH_PASSPHRASE="$2"
     shift 2
     ;;
     --) # End of all options
          shift
          break
          ;;
     *)  # No more options
          break
          ;;
   esac
done

printf "\n::INSTALL brew and stuff\n\n"
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

printf "\n::PRELIMINARY setup\n\n"
brew install ack \
             autojump \
             automake \
             colordiff \
             curl \
             git \
             git-flow \
             hub icoutils \
             imagemagick \
             libmemcached \
             memcached \
             openssl \
             ossp-uuid \
             qt \
             readline \
             redis \
             tmux \
             wget \
             xonsh

brew tap caskroom/cask

brew install caskroom/cask/brew-cask

easy_install pip

pip install -U pip

printf "\n::INSTALL apts(i know)\n\n"
brew cask install google-chrome \
                  vagrant \
                  docker \
                  vlc \
                  git \
                  hexchat \
                  mosh \
                  virtualbox \
                  iterm2


printf "\n::INSTALL vagrant plugins\n\n"
vagrant plugin install vagrant-cachier

printf "\n::INSTALL pip packages\n\n"
pip install virtualenv \
           virtualenvwrapper \
           pep8 \
           yapf \
           ansible==1.9.4 \
           httpie \
           livestreamer \
           awsebcli \
           youtube-dl \
           prompt_toolkit

printf "\n::SETUP ssh key, but do not overwrite\n\n"
cat /dev/zero | ssh-keygen -t rsa -C "komuw@Mac" -b 4096 -q -N $SSH_PASSPHRASE -f ~/.ssh/id_rsa

printf "\n::SHOW me my ssh key dammint\n\n"
cat ~/.ssh/id_rsa.pub

printf "\n::CREATE dirs\n\n"
mkdir -p ~/swat
mkdir -p ~/mystuff

printf "\n::COPY conf files\n\n"
cp templates/mac/atom.config.cson.j2 ~/.atom/config.cson
cp templates/mac/bash_aliases.j2 ~/.bash_aliases
cp templates/mac/gitconfig.j2 ~/.ssh/config
cp templates/mac/hgrc.j2 ~/.hgrc
cp templates/pip.conf.j2 ~/.pip/pip.conf
cp templates/xonsh.config.json.j2 ~/.config/xonsh/config.json

printf "\n::WGET sublimetext and install\n\n"
wget -nc --directory-prefix=/tmp "https://download.sublimetext.com/Sublime%20Text%20Build%203124.dmg"
hdiutil mount "Sublime Text Build 3124.dmg" || printf "\n already installed\n"
cp -R "/Volumes/Sublime Text" /Applications || printf "\n already installed\n"
cd ~ && hdiutil unmount "/Volumes/Sublime Text" || printf "\n already installed\n"

printf "\n::git config\n\n"
git config --global user.name "komuW"
git config --global user.email "komuw05@gmail.com"
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.hist "log --pretty=format:'%C(yellow)[%ad]%C(reset) %C(green)[%h]%C(reset) | %C(red)%s %C(bold red){{%an}}%C(reset) %C(blue)%d%C(reset)' --graph --date=short"

printf "\n::SET xonsh as default shell\n\n"
grep -q "/usr/local/bin/xonsh" "/etc/shells" || sudo -u root /bin/bash -c 'echo "/usr/local/bin/xonsh" >> "/etc/shells"'
chsh -s /usr/local/bin/xonsh

