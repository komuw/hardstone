#!/usr/bin/env bash


SSH_KEY_PHRASE=$1

if [ -z "$SSH_KEY_PHRASE" ]; then
    printf "\n\n SSH_KEY_PHRASE should not be empty"
    exit
fi


printf "\n\n Update package cache"
sudo apt -y update

printf "\n\n fix broken dependencies"
sudo apt-get -f -y install

printf "\n\n create /etc/apt/sources.list.d file"
mkdir -p /etc/apt/sources.list.d

printf "\n\n rm skype"
sudo apt-get -y remove skype skype-bin:i386 skype:i386


printf "\n\n install skype dependency"
sudo apt-get -y install sni-qt:i386

printf "\n\n rm skype config"
sudo rm -rf ~/.Skype

printf "\n\n enable multiarch"
sudo dpkg --add-architecture i386

printf "\n\n add skype ppa"
sudo add-apt-repository -y "deb http://archive.canonical.com/ $(lsb_release -sc) partner"

printf "\n\n add sublime-text3 ppa"
sudo wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

printf "\n\n add some ppas"
sudo add-apt-repository -y ppa:eugenesan/ppa \
                           ppa:transmissionbt/ppa #transmission bittorrent \
                           ppa:jonathonf/ffmpeg-3 #ffmpeg \
                           ppa:mc3man/mpv-tests #mpv

printf "\n\n update cache"
sudo apt-get -y update

printf "\n\n remove potential apt lock"
sudo rm -rf /var/cache/apt/archives/lock && sudo rm -rf /var/lib/dpkg/lock && sudo rm /var/cache/debconf/*.dat

printf "\n\n fix broken dependencies"
sudo apt-get -f -y install

printf "\n\n configure"
sudo dpkg --configure -a

printf "\n\n update system"
sudo apt-get -y update

printf "\n\n Install system packages"
sudo apt-get -y install gcc \ libssl-dev
        \ apt-transport-https
        \ ca-certificates
        \ libffi-dev
        \ openssh-client
        \ openssh-server
        \ kdiff3
        \ meld
        \ python-pip
        \ python3-pip #for docker-compose
        \ python-software-properties
        \ software-properties-common
        \ terminator
        \ lsof
        \ telnet
        \ curl
        \ mercurial
        \ git
        \ unrar
        \ transmission
        \ transmission-cli
        \ transmission-common
        \ transmission-daemon
        \ libav-tools #needed by vlc for streaming
        \ vlc
        \ mpv #player
        \ browser-plugin-vlc
        \ pep8
        \ libpq-dev 
        \ python2.7-dev
        \ libxml2-dev 
        \ libxslt1-dev
        \ postgresql 
        \ postgresql-contrib
        \ network-manager-vpnc
        \ vpnc
        \ screen
        \ build-essential
        \ python-dev
        \ python-setuptools
        \ iftop
        #\ ifconfig
        \ tcptrack
        \ wireshark
        \ nano
        \ git-flow
        \ zip
        \ lxc 
        \ lxc-templates 
        \ cgroup-lite 
        \ redir
        \ gdb
        \ hexchat #irc client
        \ mosh
        \ vnstat
        \ psmisc #pstree
        \ openvpn
        \ traceroute
        \ graphviz # needed by golang pprof tool
        \ ffmpeg
        \ libav-tools #ffmpeg tool
        \ x264 #ffmpeg tool
        \ x265 #ffmpeg tool
        \ gdebi
        \ skype
        \ sublime-text


printf "\n\n add nodeJs ppa"
curl -sL https://deb.nodesource.com/setup_9.x | sudo -E bash -

printf "\n\n install nodeJs"
sudo apt-get install -y nodejs

printf "\n\n remove potential apt lock"
sudo rm -rf /var/cache/apt/archives/lock && sudo rm -rf /var/lib/dpkg/lock && sudo rm /var/cache/debconf/*.dat

printf "\n\n fix broken dependencies"
sudo apt-get -f -y install

printf "\n\n configure"
sudo dpkg --configure -a

printf "\n\n update system"
sudo apt-get -y update

printf "\n\n agree to ttf-mscorefonts-installer license(prepare media codecs install)"
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections

printf "\n\n Install system packages  media codecs"
sudo apt-get -y install ubuntu-restricted-extras

printf "\n\n update system"
sudo apt-get -y update

printf "\n\n download google chrome"
sudo wget -nc --directory-prefix=/tmp https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

printf "\n\n install google chrome"
sudo dpkg -i /tmp/google-chrome-stable_current_amd64.deb

printf "\n\n fix install chrome errors"
sudo apt-get -f -y install  

printf "\n\n download and install vagrant"
sudo wget -nc --directory-prefix=/tmp https://releases.hashicorp.com/vagrant/2.1.1/vagrant_2.1.1_x86_64.deb
sudo dpkg -i /tmp/vagrant_2.1.1_x86_64.deb

printf "\n\n install vagrant cachier plugin"
vagrant plugin install vagrant-cachier vagrant-vbguest

printf "\n\n download and install virtualbox"
sudo wget -nc --directory-prefix=/tmp http://download.virtualbox.org/virtualbox/5.2.12/virtualbox-5.2_5.2.12-122591~Ubuntu~bionic_amd64.deb
sudo dpkg -i /tmp/virtualbox-5.2_5.2.12-122591~Ubuntu~bionic_amd64.deb

printf "\n\n Install Python packages"
sudo pip install --upgrade pip 
        \ virtualenv
        \ virtualenvwrapper
        \ youtube-dl
        \ yapf
        \ ansible
        \ httpie
        \ livestreamer
        \ awscli
        \ awsebcli
        \ prompt_toolkit
        \ pycodestyle #pep8
        \ autopep8
        \ flake8
        \ sewer
        \ Pygments
        \ pylint
        \ pylint-django
    
printf "\n\n Install Python pip3 packages"
sudo pip3 install --upgrade docker-compose
        \ asciinema
        \ jupyter
        \ jupyterlab
        \ jupyter-console

# printf "\n\n create users group"
# group: name={{ USER }} state=present

printf "\n\n create ssh-key"
if [[ ! -e ~/.ssh/id_rsa.pub ]]; then
    ssh-keygen -t rsa -C komuwUbuntu -b 8192 -q -N "$SSH_KEY_PHRASE" -f /home/komuw/.ssh/id_rsa
fi

#printf "\n\n start ssh-agent"
#shell: ssh-agent /bin/bash

#printf "\n\n load your key to the agent"
#command: ssh-add ~/.ssh/id_rsa

printf "\n\n your ssh public key is"
cat ~/.ssh/id_rsa.pub

printf "\n\n configure ssh/config"
# there ought to be NO newlines in the content
SSH_CONFIG_FILE_CONTENTS='Host *.github.com
  ForwardAgent yes
Host *.bitbucket.org
  ForwardAgent yes
Host *.compute.amazonaws.com
  ForwardAgent yes
ServerAliveInterval 60'
SSH_CONFIG_FILE=~/.ssh/config
touch "$SSH_CONFIG_FILE"
grep -qF -- "$SSH_CONFIG_FILE_CONTENTS" "$SSH_CONFIG_FILE" || echo "$SSH_CONFIG_FILE_CONTENTS" >> "$SSH_CONFIG_FILE"


# printf "\n\n configure bash aliases"
# template: src=templates/bash_aliases.j2
#         dest=~/.bash_aliases

printf "\n\n configure .bashrc"
BASHRC_FILE_FILE_CONTENTS='#solve passphrase error in ssh
#enable auto ssh-agent forwading
#see: http://rabexc.org/posts/pitfalls-of-ssh-agents
ssh-add -l &>/dev/null
if [ "$?" == 2 ]; then
  test -r ~/.ssh-agent && \
    eval "$(<~/.ssh-agent)" >/dev/null
  ssh-add -l &>/dev/null
  if [ "$?" == 2 ]; then
    (umask 066; ssh-agent > ~/.ssh-agent)
    eval "$(<~/.ssh-agent)" >/dev/null
    ssh-add
  fi
fi
export HISTTIMEFORMAT="%d/%m/%Y %T "'
BASHRC_FILE=~/.bashrc
grep -qF -- "$BASHRC_FILE_FILE_CONTENTS" "$BASHRC_FILE" || echo "$BASHRC_FILE_FILE_CONTENTS" >> "$BASHRC_FILE"


printf "\n\n configure gitconfig"

GIT_CONFIG_FILE_CONTENTS='[user]
	name = komuw
	email = komuw05@gmail.com
[alias]
  co = checkout
  ci = commit
  st = status
  br = branch
  hist = log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short
  type = cat-file -t
  dump = cat-file -p
[diff]
  tool = meld
[difftool "meld"]
[merge]
  tool = meld
[mergetool "meld"]
  keepBackup = false'

GIT_CONFIG_FILE=~/.gitconfig
touch "$GIT_CONFIG_FILE"
grep -qF -- "$GIT_CONFIG_FILE_CONTENTS" "$GIT_CONFIG_FILE" || echo "$GIT_CONFIG_FILE_CONTENTS" >> "$GIT_CONFIG_FILE"


printf "\n\n configure hgrc(mercurial)"
MERCURIAL_CONFIG_FILE_CONTENTS='[ui]
username = komuw <komuw05@gmail.com>'
MERCURIAL_CONFIG_FILE=~/.hgrc
touch "$MERCURIAL_CONFIG_FILE"
grep -qF -- "$MERCURIAL_CONFIG_FILE_CONTENTS" "$MERCURIAL_CONFIG_FILE" || echo "$MERCURIAL_CONFIG_FILE_CONTENTS" >> "$MERCURIAL_CONFIG_FILE"


printf "\n\n create pip conf"
mkdir -p ~/.pip
PIP_CONFIG_FILE_CONTENTS='[global]
download_cache = ~/.cache/pip'
PIP_CONFIG_FILE=~/.pip/pip.conf
touch "$PIP_CONFIG_FILE"
grep -qF -- "$PIP_CONFIG_FILE_CONTENTS" "$PIP_CONFIG_FILE" || echo "$PIP_CONFIG_FILE_CONTENTS" >> "$PIP_CONFIG_FILE"

printf "\n\n create pip cache dir"
mkdir -p ~/.cache && mkdir -p ~/.cache/pip

printf "\n\n give root group ownership of pip cache dir"
sudo chown -R root ~/.cache/pip


printf "\n\n create terminator conf dir"
mkdir -p ~/.config && mkdir -p ~/.config/terminator
TERMINATOR_CONFIG_FILE_CONTENTS='[global_config]
  enabled_plugins = LaunchpadCodeURLHandler, APTURLHandler, LaunchpadBugURLHandler
[keybindings]
  copy = <Primary>c
  paste = <Primary>v
[profiles]
  [[default]]
    use_system_font = False
    background_darkness = 0.77
    background_type = transparent
    background_image = None
    foreground_color = "#00ff00"
    font = Monospace 13
  [[{{ USER }}]]
    use_system_font = False
    background_darkness = 0.8
    background_type = transparent
    background_image = None
    foreground_color = "#00ff00"
    font = Monospace 14
[layouts]
  [[default]]
    [[[child1]]]
      profile = New Profile
      type = Terminal
      parent = window0
    [[[window0]]]
      type = Window
      parent = ""
[plugins]'
TERMINATOR_CONFIG_FILE=~/.config/terminator/config
touch "$TERMINATOR_CONFIG_FILE"
grep -qF -- "$TERMINATOR_CONFIG_FILE_CONTENTS" "$TERMINATOR_CONFIG_FILE" || echo "$TERMINATOR_CONFIG_FILE_CONTENTS" >> "$TERMINATOR_CONFIG_FILE"


printf "\n\n configure grub conf"
GRUB_CONFIG_FILE_CONTENTS='# If you change this file, run update-grub afterwards to update
# /boot/grub/grub.cfg.
# For full documentation of the options in this file, see:
#   info -f grub -n Simple configuration
GRUB_DEFAULT=0
GRUB_HIDDEN_TIMEOUT=0
GRUB_HIDDEN_TIMEOUT_QUIET=true
GRUB_TIMEOUT=10
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="no_console_suspend verbose debug ignore_loglevel"
GRUB_CMDLINE_LINUX=""
# you may want to change to this if you have any issues/bugs
# GRUB_CMDLINE_LINUX_DEFAULT="nomodeset no_console_suspend verbose debug ignore_loglevel"
# Uncomment to enable BadRAM filtering, modify to suit your needs
# This works with Linux (no patch required) and with any kernel that obtains
# the memory map information from GRUB (GNU Mach, kernel of FreeBSD ...)
#GRUB_BADRAM="0x01234567,0xfefefefe,0x89abcdef,0xefefefef"
# Uncomment to disable graphical terminal (grub-pc only)
#GRUB_TERMINAL=console
# The resolution used on graphical terminal
# note that you can use only modes which your graphic card supports via VBE
# you can see them in real GRUB with the command vbeinfo
#GRUB_GFXMODE=640x480
# Uncomment if you dont want GRUB to pass "root=UUID=xxx" parameter to Linux
#GRUB_DISABLE_LINUX_UUID=true
# Uncomment to disable generation of recovery mode menu entries
#GRUB_DISABLE_RECOVERY="true"
# Uncomment to get a beep at grub start
#GRUB_INIT_TUNE="480 440 1"
# To edit boot parameters before/during booting; reboot, after the boot sound, press ESC key once, click 'e' key to edit,
# remove `quiet splash` replace with `nomodeset no_console_suspend verbose debug ignore_loglevel` then press F10 to reboot.
# You may also have to choose to boot into either recovery mode or boot using a different kernel. 
# All this, can be selected by; rebooting, press ESC after boot sound and selecting Advanced boot settings.'
GRUB_CONFIG_FILE=/etc/default/grub
touch "$GRUB_CONFIG_FILE"
grep -qF -- "$GRUB_CONFIG_FILE_CONTENTS" "$GRUB_CONFIG_FILE" || echo "$GRUB_CONFIG_FILE_CONTENTS" >> "$GRUB_CONFIG_FILE"

printf "\n\n update grub"
sudo update-grub

printf "\n\n source bashrc"
source ~/.bashrc

printf "\n\n source profile"
source ~/.profile

printf "\n\n add docker apt key"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
printf "\n\n verify docker key"
sudo apt-key fingerprint 0EBFCD88
printf "\n\n add docker apt repo"
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
printf "\n\n install docker"
sudo apt-get -y autoremove && apt-get install -y docker-ce=*
printf "\n\n add user to docker group"
usermod -aG docker {{ANSIBLE_SSH_USER}} && sudo usermod -aG docker $(whoami)

printf "\n\n create docker dir"
mkdir -p ~/.docker
printf "\n\n make docker group owner of docker dir"
chown -R root:docker ~/.docker
printf "\n\n add proper permissions to docker dir"
chmod -R 775 ~/.docker

printf "\n\n configure /etc/docker/daemon.json file"
mkdir -p /etc/docker
DOCKER_DAEMON_CONFIG_FILE_CONTENTS='{
    "max-concurrent-downloads": 12,
    "max-concurrent-uploads": 5
}'
DOCKER_DAEMON_CONFIG_FILE=/etc/docker/daemon.json
touch "$DOCKER_DAEMON_CONFIG_FILE"
grep -qF -- "$DOCKER_DAEMON_CONFIG_FILE_CONTENTS" "$DOCKER_DAEMON_CONFIG_FILE" || echo "$DOCKER_DAEMON_CONFIG_FILE_CONTENTS" >> "$DOCKER_DAEMON_CONFIG_FILE"


printf "\n\n Remove some default system packages"
sudo apt-get -y purge netsurf-gtk

printf "\n\n create my stuff dir"
mkdir -p $HOME/mystuff


printf "\n\n  update"
sudo apt-get -y update

printf "\n\n  add security updates"
sudo apt-get -y dist-upgrade

printf "\n\n THATS IT. YOU are done."
