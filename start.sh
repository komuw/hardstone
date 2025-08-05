#!/usr/bin/env bash
shopt -s nullglob globstar
set -x # have bash print command been ran
set -e # fail if any command fails

export DEBIAN_FRONTEND=noninteractive

# Usage:
# 1. docker build -t hardstone-nix .
# 2. docker run -it hardstone-nix
# 3. bash start.sh
# 4. export SSH_KEY_PHRASE=SSH_KEY_PHRASE
# 5. nix-shell pkgs/ # nix-shell --repair pkgs/
#
# or:
# 1. docker-compose run my_nix_env
# or:
# 1. docker-compose run my_nix_env bash
# 2. bash start.sh
# 3. export SSH_KEY_PHRASE=SSH_KEY_PHRASE
# 4. nix-shell pkgs/


# TODO: setup ntp; https://help.ubuntu.com/community/UbuntuTime

MY_NAME=$(whoami)

pre_setup(){
    printf "\n\n\t 0. pre_setup \n"

    sudo rm -rf /etc/apt/sources.list.d/*
    sudo rm -rf /tmp/*.txt

    sudo apt-get -y update
    sudo rm -rf /var/cache/apt/archives/lock && sudo rm -rf /var/lib/dpkg/lock && sudo rm -rf /var/cache/debconf/*.dat  # remove potential apt lock
    sudo apt-get -f -y install                                                                                          # fix broken dependencies

    # setup gnome-terminal with custom config
    # https://askubuntu.com/a/1241849
    # use; `dconf dump /org/gnome/terminal/` to print the current config
    cat ./templates/terminal/gnome_terminal_config | dconf load /org/gnome/terminal/
    # config reference is: https://help.gnome.org/users/gnome-terminal/stable/pref.html.en
}
pre_setup

configure_timezone(){
    printf "\n\n\t 1. configure_timezone \n"

    echo "tzdata tzdata/Areas select Africa
    tzdata tzdata/Zones/Africa select Nairobi" | sudo tee /tmp/tzdata_preseed.txt
    sudo debconf-set-selections /tmp/tzdata_preseed.txt

    sudo rm -rf /etc/timezone
    echo "Africa/Nairobi" | sudo tee /etc/timezone
    sudo ln -sf /usr/share/zoneinfo/Africa/Nairobi /etc/localtime

    sudo apt -y update;sudo apt -y install tzdata
    sudo dpkg-reconfigure --frontend noninteractive tzdata
}
configure_timezone

install_nix_pre_requistes(){
    printf "\n\n\t 2. install_nix_pre_requistes \n"

    sudo apt -y update
    sudo apt -y install sudo usb-creator-gtk # Startup Disk Creator. Creates bootable USB/flash stick.
    sudo apt -y update
    sudo apt-get -y dist-upgrade # security updates
    sudo apt -y install curl xz-utils
}
install_nix_pre_requistes

un_install_nix() {
    printf "\n\n\t 3. un_install_nix \n"

    # According to the documentation, un_installing nix is as simple as;
    #  `rm -rf /nix`
    # see: https://nixos.org/manual/nix/stable/#sect-single-user-installation
    #
    # However, that will also remove the /nix/store.
    # This is okay if we really want to nuke nix.
    # But if all we want is to upgrade nix, then nuking the store doesn't seem like what we want.
    # Hence, here we only remove /nix/var and leave /nix/store.
    #

    sudo rm -rf /nix/var
    sudo rm -rf ~/.cache/nix/*
    sudo rm -rf /home/$MY_NAME/.nix-channels
    sudo rm -rf /home/$MY_NAME/.nix-defexpr
    sudo rm -rf /home/$MY_NAME/.nix-profile
    sudo rm -rf /home/$MY_NAME/.local/state/nix
}
un_install_nix

create_nix_conf_file(){
    printf "\n\n\t 4. create_nix_conf_file \n"

    sudo rm -rf /etc/nix/nix.conf
    sudo mkdir -p /etc/nix/
    sudo chown -R $MY_NAME:sudo /etc/nix/
    cp etc.nix.nix.conf /etc/nix/nix.conf

    mkdir -p ~/.config/nixpkgs
    mkdir -p /home/$MY_NAME/.config/nixpkgs

    cp config.nixpkgs.config.nix ~/.config/nixpkgs/config.nix
    cp config.nixpkgs.config.nix /home/$MY_NAME/.config/nixpkgs/config.nix
}
create_nix_conf_file

install_nix() {
    # versions can be found at: https://releases.nixos.org/?prefix=nix/
    #                           https://github.com/NixOs/Nix/tags
    NIX_PACKAGE_MANAGER_VERSION=2.30.2
    printf "\n\n\t 5. install_nix version%s \n" "$NIX_PACKAGE_MANAGER_VERSION"

    # This is a single-user installation: https://nixos.org/manual/nix/stable/#sect-single-user-installation
    # meaning that /nix is owned by the invoking user. Do not run as root.
    # The script will invoke sudo to create /nix
    # The install script will modify the first writable file from amongst ~/.bash_profile, ~/.bash_login and ~/.profile to source ~/.nix-profile/etc/profile.d/nix.sh

    curl -L "https://releases.nixos.org/nix/nix-$NIX_PACKAGE_MANAGER_VERSION/install" | sh -s -- --no-daemon
    . ~/.nix-profile/etc/profile.d/nix.sh # source a file
}
install_nix

upgrade_nix() {
    printf "\n\n\t 6. upgrade_nix \n"

    # see:
    # 1. https://nixos.org/manual/nix/stable/#ch-upgrading-nix
    # 2. https://nixos.org/manual/nix/stable/#sec-nix-channel

    # TODO: do we need these?
    # /home/$MY_NAME/.nix-profile/bin/nix-channel --list
    # /home/$MY_NAME/.nix-profile/bin/nix-channel --remove nixpkgs
    # /home/$MY_NAME/.nix-profile/bin/nix-channel --add "https://nixos.org/channels/nixpkgs-unstable" nixpkgs-unstable # TODO: use a stable/specific version
    # /home/$MY_NAME/.nix-profile/bin/nix-channel --update
    # /home/$MY_NAME/.nix-profile/bin/nix-channel --list

    # Channels are a way of distributing Nix software, but they are being phased out.
    # Even though they are still used by default,
    # it is recommended to avoid channels and <nixpkgs> by always setting NIX_PATH= to be empty.
    # see: https://nixos.org/guides/towards-reproducibility-pinning-nixpkgs.html#pinning-nixpkgs
}
upgrade_nix

setup_nix_ca_bundle(){
    printf "\n\n\t 7. setup_nix_ca_bundle \n"

    CURL_CA_BUNDLE=$(find /nix -name ca-bundle.crt |tail -n 1)
    export CURL_CA_BUNDLE=$CURL_CA_BUNDLE # this is also added in `preRequiste.nix`
}
setup_nix_ca_bundle

clear_stuff(){
    printf "\n\n\t 8. clear_stuff \n"

    sudo apt -y autoremove
    sudo apt -y clean
    sudo apt -y purge '~c'
    sudo rm -rf /var/lib/apt/lists/*
}
clear_stuff


create_nix_aliases(){
    printf "\n\n\t 9. create_nix_aliases \n"

    {
        . ~/.nix-profile/etc/profile.d/nix.sh # source a file

        # The Nix store sometimes contains entries which are no longer useful.
        # garbage collect them
        nix-store --gc # Do NOT use 'nix-collect-garbage -d', it messes with nix installation.

        # /home/$MY_NAME/.nix-profile/bin/nix-collect-garbage -d # This seems to also delete the file `/home/$MY_NAME/.nix-profile`
        # /home/$MY_NAME/.nix-profile/bin/nix-store --gc
        # /home/$MY_NAME/.nix-profile/bin/nix-store --optimise
        # ref: https://nixos.org/manual/nix/unstable/command-ref/nix-store.html
        # /home/$MY_NAME/.nix-profile/bin/nix-store --verify --repair
    } || {
        echo -n ''
    }

    { # try
        unalias nix
        unalias nix-build
        unalias nix-channel
        unalias nix-collect-garbage
        unalias nix-copy-closure
        unalias nix-daemon
        unalias nix-env
        unalias nix-hash
        unalias nix-instantiate
        unalias nix-prefetch-url
        unalias nix-shell
        unalias nix-store
    } || { # catch
        echo -n ""
    }

    sudo rm -rf ~/.bash_aliases
    touch ~/.bash_aliases # touch is silent if file already exists
    chown -R $MY_NAME:sudo ~/.bash_aliases
    cp templates/bash_aliases_conf ~/.bash_aliases
    cp templates/bash_aliases_conf /home/$MY_NAME/.bash_aliases

    . ~/.bash_aliases # source a file
}
create_nix_aliases


source_files(){
    printf "\n\n\t 10. source_files \n"

    . ~/.nix-profile/etc/profile.d/nix.sh
    . /home/$MY_NAME/.nix-profile/etc/profile.d/nix.sh
    . ~/.bash_aliases

    source ~/.nix-profile/etc/profile.d/nix.sh
    source /home/$MY_NAME/.nix-profile/etc/profile.d/nix.sh
    source ~/.bash_aliases
}
source_files


install_media_codecs(){
    printf "\n\n\t 11. install media codecs \n"

    sudo apt-get -y update
    echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections  # agree to ttf-mscorefonts-installer license(prepare media codecs install)
    sudo apt-get -y install ubuntu-restricted-extras                                                                  # install system packages media codecs
}
install_media_codecs


un_install_snapd(){
    printf "\n\n\t 12. un_install snapd \n"

    # https://askubuntu.com/questions/1035915/how-to-remove-snap-store-from-ubuntu

    {
       sudo systemctl stop snapd
       sudo umount /var/snap/firefox/common/host-hunspell
    } || {
       echo -n ''
    }

    {
        sudo chmod -R a+rw /snap/;sudo chmod -R a+rw /var/snap
        sudo apt -y autoremove --purge snapd gnome-software-plugin-snap firefox
    } || {
        echo -n ''
    }

    sudo rm -rf /snap
    sudo rm -fr ~/snap
    sudo rm -rf /var/snap
    sudo rm -rf /var/lib/snapd
    sudo rm -rf /var/cache/snapd

    # prevent the package from being automatically installed, upgraded or removed.
    sudo apt-mark hold snapd
}
un_install_snapd


# TODO: make it possible to run this function
uninstall_non_essential_apt_packages(){
    printf "\n\n\t 13. uninstall_non_essential_apt_packages \n"

    sudo rm -rf /tmp/*.txt

    # This are the packages that come with a clean install of ubuntu:20.04 docker image.
    # We should not remove this, else bad things can happen.
    # TODO: We should install a fresh ubuntu 20.04 in a laptop
    #       And then profile what packages it has by default, and see which ones we SHOULD add to this list.
    #       We do not want to remove essential packages, eg those that deal with WIFI etc
    #       Use `dpkg-query -Wf '${Package;-40}${Priority}\n' | sort -b -k2,2 -k1,1` to find out
    #       https://askubuntu.com/questions/79665/keep-only-essential-packages
    # REQUIRED_PACKAGES.
    # Found by running: `dpkg-query -Wf '${Package;-40}${Priority}\n' | sort -b -k2,2 -k1,1 | grep required | awk '{print $1}'``

    # make sure there at least one extra package installed that will be removed
    sudo apt -y update; sudo apt -y install cowsay

    EXTRA_PACKAGES_AND_OPTIONAL_PACKAGES=$(dpkg-query -Wf '${Package;-40}${Priority}\n' | awk '$2 ~ /optional|extra/ { print $1 }')
    # exclude sudo
    EXTRA_PACKAGES_AND_OPTIONAL_PACKAGES_MINUS_SUDO=$(echo $EXTRA_PACKAGES_AND_OPTIONAL_PACKAGES | tr " " "\n" | grep --invert-match sudo | tr "\n" " ")
    # exclude linux kernel and its headers
    EXTRA_PACKAGES_AND_OPTIONAL_PACKAGES_MINUS_LINUX_KERNEL=$(echo $EXTRA_PACKAGES_AND_OPTIONAL_PACKAGES_MINUS_SUDO | tr " " "\n" | grep --invert-match linux- | tr "\n" " ")
    # exclude grub
    EXTRA_PACKAGES_AND_OPTIONAL_PACKAGES_MINUS_GRUB=$(echo $EXTRA_PACKAGES_AND_OPTIONAL_PACKAGES_MINUS_LINUX_KERNEL | tr " " "\n" | grep --invert-match grub- | tr "\n" " ")
    # TODO: add more exclusions

    echo "$EXTRA_PACKAGES_AND_OPTIONAL_PACKAGES_MINUS_GRUB"
    sudo apt -y autoremove
    sudo apt purge -y $EXTRA_PACKAGES_AND_OPTIONAL_PACKAGES_MINUS_GRUB
}
# uninstall_non_essential_apt_packages
clear_stuff


# The main command for package management is nix-env.
# See: https://nixos.org/manual/nix/stable/#ch-basic-package-mgmt
# Although others think it should not be widely recommended
# https://news.ycombinator.com/item?id=26748696
