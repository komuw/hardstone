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
             pstree \
             xonsh #this will also install python3 and pip3

brew tap caskroom/cask

brew install caskroom/cask/brew-cask

easy_install pip

pip install -U pip
pip3 install prompt_toolkit pygments

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
vagrant plugin install vagrant-cachier vagrant-vbguest

printf "\n::INSTALL pip packages\n\n"
pip install -U virtualenv \
           virtualenvwrapper \
           pep8 \
           yapf \
           ansible==1.9.4 \
           httpie \
           livestreamer \
           awsebcli \
           youtube-dl \
           prompt_toolkit \
           pycodestyle \
           autopep8 \
           flake8

printf "\n::SETUP ssh key, but do not overwrite\n\n"
cat /dev/zero | ssh-keygen -t rsa -C "komuw@Mac" -b 4096 -q -N $SSH_PASSPHRASE -f ~/.ssh/id_rsa

printf "\n::SHOW me my ssh key damn it\n\n"
cat ~/.ssh/id_rsa.pub

printf "\n::CREATE dirs\n\n"
mkdir -p ~/swat
mkdir -p ~/mystuff

printf "\n::INSTALL golang\n\n"
wget -nc "https://storage.googleapis.com/golang/go1.7.1.darwin-amd64.pkg"
tar -C /usr/local -xzf golang/go1.7.1.darwin-amd64.pkg

printf "\n::COPY conf files\n\n"
cp templates/mac/atom.config.cson.j2 ~/.atom/config.cson
cp templates/mac/bash_aliases.j2 ~/.bash_aliases
cp templates/mac/gitconfig.j2 ~/.ssh/config
cp templates/mac/hgrc.j2 ~/.hgrc
cp templates/pep8.j2 ~/.config/pep8
cp templates/xonshrc.j2 ~/.xonshrc

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

printf "\n::copy over things to enable auto suggestion in xonsh\n\n"
cp -R /usr/local/Cellar/python3/3.6.5/Frameworks/Python.framework/Versions/3.6/lib/python3.6/site-packages/prompt_toolkit /usr/local/Cellar/xonsh/0.6.5/libexec/lib/python3.6/site-packages
cp -R /usr/local/Cellar/python3/3.6.5/Frameworks/Python.framework/Versions/3.6/lib/python3.6/site-packages/wcwidth /usr/local/Cellar/xonsh/0.6.5/libexec/lib/python3.6/site-packages
cp -R /usr/local/Cellar/python3/3.6.5/Frameworks/Python.framework/Versions/3.6/lib/python3.6/site-packages/six* /usr/local/Cellar/xonsh/0.6.5/libexec/lib/python3.6/site-packages
cp -R /usr/local/Cellar/python3/3.6.5/Frameworks/Python.framework/Versions/3.6/lib/python3.6/site-packages/pygments /usr/local/Cellar/xonsh/0.6.5/libexec/lib/python3.6/site-packages

printf "\n::INSTALL golang pkgs\n\n"
go get github.com/motemen/gore                 #golang repl
go get github.com/nsf/gocode                   #golang auto-completion
go get github.com/k0kubun/pp                   #pretty print
go get golang.org/x/tools/cmd/godoc            #docs
go get github.com/derekparker/delve/cmd/dlv    #debugger
go get github.com/mailgun/godebug              #another debugger
