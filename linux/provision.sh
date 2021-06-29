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


printf "\n\n clear /tmp directory\n"
rm -rf /tmp/*

printf "\n\n rm custome ppas\n"
rm -rf /etc/apt/sources.list.d/*

printf "\n\n create my stuff dir\n"
mkdir -p /home/$MY_NAME/mystuff
chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/mystuff

printf "\n\n create personalWork dir\n"
mkdir -p /home/$MY_NAME/personalWork
chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/personalWork

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

printf "\n\n remove potential apt lock\n"
rm -rf /var/cache/apt/archives/lock && rm -rf /var/lib/dpkg/lock && rm -rf /var/cache/debconf/*.dat

printf "\n\n fix broken dependencies\n"
apt-get -f -y install

printf "\n\n configure\n"
dpkg --configure -a

printf "\n\n update system\n"
apt-get -y update

setup_terminator_conf(){
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
}
setup_terminator_conf


setup_grub_conf(){
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
}
setup_grub_conf

printf "\n\n  update\n"
apt-get -y update

printf "\n\n add security updates\n"
apt-get -y dist-upgrade

printf "\n\n clear /tmp directory\n"
rm -rf /tmp/*
