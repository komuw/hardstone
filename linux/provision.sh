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

MY_NAME=$(whoami)

SSH_KEY_PHRASE_PERSONAL=${1:-sshKeyPhrasePersonalNotSet}
if [ "$SSH_KEY_PHRASE_PERSONAL" == "sshKeyPhrasePersonalNotSet"  ]; then
    printf "\n\n SSH_KEY_PHRASE_PERSONAL should not be empty\n"
    exit
fi

SSH_KEY_PHRASE_PERSONAL_WORK=${2:-sshKeyPhrasePersonalWorkNotSet}
if [ "$SSH_KEY_PHRASE_PERSONAL_WORK" == "sshKeyPhrasePersonalWorkNotSet"  ]; then
    printf "\n\n SSH_KEY_PHRASE_PERSONAL_WORK should not be empty\n"
    exit
fi

PERSONAL_WORK_EMAIL=${3:-PERSONAL_WORK_EMAILNotSet}
if [ "$PERSONAL_WORK_EMAIL" == "PERSONAL_WORK_EMAILNotSet"  ]; then
    printf "\n\n PERSONAL_WORK_EMAIL should not be empty\n"
    exit
fi

PERSONAL_WORK_NAME=${4:-PERSONAL_WORK_NAMENotSet}
if [ "$PERSONAL_WORK_NAME" == "PERSONAL_WORK_NAMENotSet"  ]; then
    printf "\n\n PERSONAL_WORK_NAME should not be empty\n"
    exit
fi


printf "\n\n clear /tmp directory\n"
rm -rf /tmp/*


printf "\n\n create my stuff dir\n"
mkdir -p $HOME/mystuff
chown -R $MY_NAME:$MY_NAME $HOME/mystuff

printf "\n\n create personalWork dir\n"
mkdir -p $HOME/personalWork
chown -R $MY_NAME:$MY_NAME $HOME/personalWork


printf "\n\n rm custome ppas\n"
rm -rf /etc/apt/sources.list.d/*

printf "\n\n Update package cache\n"
apt -y update

printf "\n\n fix broken dependencies\n"
apt-get -f -y install

printf "\n\n create /etc/apt/sources.list.d file\n"
mkdir -p /etc/apt/sources.list.d


# add-apt-repository takes one repo as arg
printf "\n\n add some ppas\n"
# TODO: as of ubuntu 21.04, it looks like these ppas are not neccesary
# add-apt-repository -y ppa:eugenesan/ppa                                                              # I don't know which package requires this ppa
# add-apt-repository -y ppa:mc3man/mpv-tests                                                           # for mpv player

apt-get -y update
rm -rf /var/cache/apt/archives/lock && rm -rf /var/lib/dpkg/lock && rm -rf /var/cache/debconf/*.dat  # remove potential apt lock
apt-get -f -y install                                                                                # fix broken dependencies
dpkg --configure -a                                                                                  # configure
apt-get -y update                                                                                    # update system

printf "\n\n Install mpv\n"
apt-get -y install mpv

printf "\n\n check DEBIAN_FRONTEND value.\n"
echo $DEBIAN_FRONTEND

printf "\n\n Install system packages\n"
apt-get -y install gcc \
        libssl-dev \
        apt-transport-https \
        ca-certificates \
        libffi-dev \
        openssh-client \
        kdiff3 \
        meld \
        python3-pip \
        software-properties- \
        terminator \
        lsof \
        telnet \
        curl \
        mercurial \
        git \
        unrar \
        transmission \
        transmission-cli \
        transmission-common \
        transmission-daemon \
        vlc \
        libpq-dev  \
        python2.7-dev \
        libxml2-dev  \
        libxslt1-dev \
	      postgresql-client \
        screen \
        build-essential \
        python-dev \
        python-setuptools \
        iftop \
        tcptrack \
        wireshark \
        nano \
        zip \
        lxc \
        lxc-templates  \
        cgroup-lite \
        redir \
        gdb \
        hexchat \
        mosh \
        vnstat \
        psmisc  \
        traceroute \
        graphviz \
        ffmpeg \
        x264  \
        x265  \
        gdebi \
        wireguard \
        net-tools \
        aria2 \
        shellcheck \
        rlwrap \
        tree \
        streamlink # livestreamer replacement
        # ifconfig

install_skype(){
    printf "\n\n install skype\n"

    apt-key del 1F3045A5DF7587C3 # https://askubuntu.com/questions/1348146/invalid-signature-from-repo-skype-com-how-can-i-clear-this/1348149
    curl https://repo.skype.com/data/SKYPE-GPG-KEY | apt-key add -
    apt-get -y purge skype*
    rm -rf /home/$MY_NAME/.Skype; rm -rf /home/$MY_NAME/.skype
    apt -y install gconf-service libgconf-2-4 gnome-keyring # pre-requistes
    wget -nc --output-document=/tmp/skype.deb https://go.skype.com/skypeforlinux-64.deb
    dpkg -i /tmp/skype.deb
}
install_skype

printf "\n\n remove potential apt lock\n"
rm -rf /var/cache/apt/archives/lock && rm -rf /var/lib/dpkg/lock && rm -rf /var/cache/debconf/*.dat

printf "\n\n fix broken dependencies\n"
apt-get -f -y install

printf "\n\n configure\n"
dpkg --configure -a

printf "\n\n update system\n"
apt-get -y update

printf "\n\n agree to ttf-mscorefonts-installer license(prepare media codecs install)\n"
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections

printf "\n\n Install system packages  media codecs\n"
apt-get -y install ubuntu-restricted-extras

printf "\n\n update system\n"
apt-get -y update

printf "\n\n install google chrome\n"
# install chrome dependencies
apt-get -y install libdbusmenu-glib4 \
                   libdbusmenu-gtk3-4 \
                   libindicator3-7 \
                   libappindicator3-1
wget -nc --output-document=/tmp/google_chrome_stable_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
dpkg -i /tmp/google_chrome_stable_amd64.deb
apt-get -f -y install # fix install chrome errors

printf "\n\n install bat(https://github.com/sharkdp/bat)\n"
wget -nc --output-document=/tmp/bat_amd64.deb https://github.com/sharkdp/bat/releases/download/v0.18.1/bat_0.18.1_amd64.deb
dpkg -i /tmp/bat_amd64.deb

printf "\n\n Install Python pip3 packages\n"
pip3 install --upgrade pip # upgrade  pip3 gloablly
python3 -m venv ~/.global_venv --without-pip # https://askubuntu.com/questions/879437/ensurepip-is-disabled-in-debian-ubuntu-for-the-system-python
source ~/.global_venv/bin/activate && pip3 install --upgrade \
         youtube-dl \
         docker-compose \
         asciinema \
         httpie \
         awscli \
         sewer

# printf "\n\n create users group"
# group: name={{ USER }} state=present

printf "\n\n create personal ssh-key\n"
if [[ ! -e /home/$MY_NAME/.ssh/personal_id_rsa.pub ]]; then
    mkdir -p /home/$MY_NAME/.ssh
    ssh-keygen -t rsa -C komuwUbuntu -b 8192 -q -N "$SSH_KEY_PHRASE_PERSONAL" -f /home/$MY_NAME/.ssh/personal_id_rsa
fi
chmod 600 /home/$MY_NAME/.ssh/personal_id_rsa
chmod 600 /home/$MY_NAME/.ssh/personal_id_rsa.pub
chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/.ssh

#printf "\n\n start ssh-agent"
#shell: ssh-agent /bin/bash

#printf "\n\n load your key to the agent"
#command: ssh-add /home/$MY_NAME/.ssh/personal_id_rsa

printf "\n\n your ssh public key is\n"
cat /home/$MY_NAME/.ssh/personal_id_rsa.pub


########################## personal work ssh key ##################
printf "\n\n create personal work ssh-key\n"
if [[ ! -e /home/$MY_NAME/.ssh/personal_work_id_rsa.pub ]]; then
    mkdir -p /home/$MY_NAME/.ssh
    ssh-keygen -t rsa -C "$PERSONAL_WORK_EMAIL" -b 8192 -q -N "$SSH_KEY_PHRASE_PERSONAL" -f /home/$MY_NAME/.ssh/personal_work_id_rsa
fi
chmod 600 /home/$MY_NAME/.ssh/personal_work_id_rsa
chmod 600 /home/$MY_NAME/.ssh/personal_work_id_rsa.pub
chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/.ssh

#printf "\n\n start ssh-agent"
#shell: ssh-agent /bin/bash

#printf "\n\n load your key to the agent"
#command: ssh-add /home/$MY_NAME/.ssh/personal_work_id_rsa

printf "\n\n your ssh public key for personal work is\n"
cat /home/$MY_NAME/.ssh/personal_work_id_rsa.pub
########################## personal work ssh key ##################

printf "\n\n configure ssh/config\n"
cp ../templates/ssh_conf.j2 /home/$MY_NAME/.ssh/config


# printf "\n\n configure bash aliases"
# template: src=../templates/bash_aliases.j2
#         dest=/home/$MY_NAME/.bash_aliases

printf "\n\n configure .bashrc\n"
# there ought to be NO newlines in the content
BASHRC_FILE_FILE_CONTENTS='#solve passphrase error in ssh
#enable auto ssh-agent forwading
#see: http://rabexc.org/posts/pitfalls-of-ssh-agents
ssh-add -l &>/dev/null
if [ "$?" == 2 ]; then
  test -r /home/$MY_NAME/.ssh-agent && \
    eval "$(</home/$MY_NAME/.ssh-agent)" >/dev/null
  ssh-add -l &>/dev/null
  if [ "$?" == 2 ]; then
    (umask 066; ssh-agent > /home/$MY_NAME/.ssh-agent)
    eval "$(</home/$MY_NAME/.ssh-agent)" >/dev/null
    ssh-add
  fi
fi
export HISTTIMEFORMAT="%d/%m/%Y %T "'
BASHRC_FILE=/home/$MY_NAME/.bashrc
grep -qF -- "$BASHRC_FILE_FILE_CONTENTS" "$BASHRC_FILE" || echo "$BASHRC_FILE_FILE_CONTENTS" >> "$BASHRC_FILE"


printf "\n\n configure gitconfig\n"
GIT_CONFIG_FILE_CONTENTS='
# https://blog.jiayu.co/2019/02/conditional-git-configuration/

[includeIf "gitdir:~/personalWork/"]
	path = ~/personalWork/.gitconfig

[includeIf "gitdir:~/mystuff/"]
	path = ~/mystuff/.gitconfig

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
  conflictstyle = diff3
[mergetool "meld"]
  keepBackup = false'

GIT_CONFIG_FILE=/home/$MY_NAME/.gitconfig
touch "$GIT_CONFIG_FILE"
grep -qF -- "$GIT_CONFIG_FILE_CONTENTS" "$GIT_CONFIG_FILE" || echo "$GIT_CONFIG_FILE_CONTENTS" >> "$GIT_CONFIG_FILE"


printf "\n\n configure ~/mystuff/ gitconfig\n"
MYSTUFF_GIT_CONFIG_FILE_CONTENTS='
[user]
    name = $MY_NAME
    email = komuw05@gmail.com'

MYSTUFF_GIT_CONFIG_FILE=/home/$MY_NAME/mystuff/.gitconfig
touch "$MYSTUFF_GIT_CONFIG_FILE"
grep -qF -- "$MYSTUFF_GIT_CONFIG_FILE_CONTENTS" "$MYSTUFF_GIT_CONFIG_FILE" || echo "$MYSTUFF_GIT_CONFIG_FILE_CONTENTS" >> "$MYSTUFF_GIT_CONFIG_FILE"


printf "\n\n configure ~/personalWork/ gitconfig\n"
PERSONAL_WORK_GIT_CONFIG_FILE_CONTENTS='
[user]
    name = "$PERSONAL_WORK_NAME"
    email = "$PERSONAL_WORK_EMAIL"'

PERSONAL_WORK_GIT_CONFIG_FILE=/home/$MY_NAME/personalWork/.gitconfig
touch "$PERSONAL_WORK_GIT_CONFIG_FILE"
grep -qF -- "$PERSONAL_WORK_GIT_CONFIG_FILE_CONTENTS" "$PERSONAL_WORK_GIT_CONFIG_FILE" || echo "$PERSONAL_WORK_GIT_CONFIG_FILE_CONTENTS" >> "$PERSONAL_WORK_GIT_CONFIG_FILE"

printf "\n\n configure gitattributes\n"
GIT_ATTRIBUTES_FILE_CONTENTS='
*.c     diff=cpp
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
*.rs    diff=rust'

GIT_ATTRIBUTES_FILE=/home/$MY_NAME/mystuff/.gitattributes
touch "$GIT_ATTRIBUTES_FILE"
grep -qF -- "$GIT_ATTRIBUTES_FILE_CONTENTS" "$GIT_ATTRIBUTES_FILE" || echo "$GIT_ATTRIBUTES_FILE_CONTENTS" >> "$GIT_ATTRIBUTES_FILE"


printf "\n\n configure hgrc(mercurial)\n"
MERCURIAL_CONFIG_FILE_CONTENTS='[ui]
username = $MY_NAME <komuw05@gmail.com>'
MERCURIAL_CONFIG_FILE=/home/$MY_NAME/.hgrc
touch "$MERCURIAL_CONFIG_FILE"
grep -qF -- "$MERCURIAL_CONFIG_FILE_CONTENTS" "$MERCURIAL_CONFIG_FILE" || echo "$MERCURIAL_CONFIG_FILE_CONTENTS" >> "$MERCURIAL_CONFIG_FILE"


printf "\n\n create pip conf\n"
mkdir -p /home/$MY_NAME/.pip
PIP_CONFIG_FILE_CONTENTS='[global]
download_cache = /home/$MY_NAME/.cache/pip'
PIP_CONFIG_FILE=/home/$MY_NAME/.pip/pip.conf
touch "$PIP_CONFIG_FILE"
grep -qF -- "$PIP_CONFIG_FILE_CONTENTS" "$PIP_CONFIG_FILE" || echo "$PIP_CONFIG_FILE_CONTENTS" >> "$PIP_CONFIG_FILE"

printf "\n\n create pip cache dir\n"
mkdir -p /home/$MY_NAME/.cache && mkdir -p /home/$MY_NAME/.cache/pip

printf "\n\n give root group ownership of pip cache dir\n"
chown -R root /home/$MY_NAME/.cache/pip

printf "\n\n create terminator conf dir\n"
mkdir -p /home/$MY_NAME/.config && mkdir -p /home/$MY_NAME/.config/terminator
TERMINATOR_CONFIG_FILE_CONTENTS='[global_config]
  enabled_plugins = LaunchpadCodeURLHandler, APTURLHandler, LaunchpadBugURLHandler
[keybindings]
  copy = <Primary>c
  paste = <Primary>v
[profiles]
  [[default]]
    use_system_font = False
    background_darkness = 0.94
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
TERMINATOR_CONFIG_FILE=/home/$MY_NAME/.config/terminator/config
touch "$TERMINATOR_CONFIG_FILE"
grep -qF -- "$TERMINATOR_CONFIG_FILE_CONTENTS" "$TERMINATOR_CONFIG_FILE" || echo "$TERMINATOR_CONFIG_FILE_CONTENTS" >> "$TERMINATOR_CONFIG_FILE"


printf "\n\n configure grub conf\n"
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

printf "\n\n update grub\n"
update-grub

# NB: do not install docker from snap, it is broken
printf "\n\n install docker\n"
apt -y remove docker docker-engine docker.io containerd runc
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -                                   # add key
apt-key fingerprint 0EBFCD88                                                                              # verify key
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"  # add docker repo
apt -y update
apt -y install docker-ce
usermod -aG docker $MY_NAME && usermod -aG docker $(whoami)                                                  # add user to docker group


printf "\n\n create docker dir\n"
mkdir -p /home/$MY_NAME/.docker
printf "\n\n make docker group owner of docker dir\n"
chown -R root:docker /home/$MY_NAME/.docker
printf "\n\n add proper permissions to docker dir\n"
chmod -R 775 /home/$MY_NAME/.docker

printf "\n\n configure /etc/docker/daemon.json file\n"
mkdir -p /etc/docker
DOCKER_DAEMON_CONFIG_FILE_CONTENTS='{
    "max-concurrent-downloads": 12,
    "max-concurrent-uploads": 5
}'
DOCKER_DAEMON_CONFIG_FILE=/etc/docker/daemon.json
touch "$DOCKER_DAEMON_CONFIG_FILE"
grep -qF -- "$DOCKER_DAEMON_CONFIG_FILE_CONTENTS" "$DOCKER_DAEMON_CONFIG_FILE" || echo "$DOCKER_DAEMON_CONFIG_FILE_CONTENTS" >> "$DOCKER_DAEMON_CONFIG_FILE"

printf "\n\n  update\n"
apt-get -y update

printf "\n\n add security updates\n"
apt-get -y dist-upgrade

printf "\n\n clear /tmp directory\n"
rm -rf /tmp/*
