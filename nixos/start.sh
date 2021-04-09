#!/usr/bin/env bash
shopt -s nullglob globstar
export DEBIAN_FRONTEND=noninteractive

# Usage:
# 1. docker build -t hardstone-nix .
# 2. docker run -it hardstone-nix
# 3. bash start.sh
# 4. docker-compose run my_nix_env


# TODO: setup ntp; https://help.ubuntu.com/community/UbuntuTime

THE_USER=$(whoami)

configure_timezone(){
    printf "\t\n\n 1.1 nix-installation pre-requistes: tzdata config A \n" 

    sudo rm -rf /tmp/*.txt

    echo "tzdata tzdata/Areas select Africa
    tzdata tzdata/Zones/Africa select Nairobi" | sudo tee /tmp/tzdata_preseed.txt
    debconf-set-selections /tmp/tzdata_preseed.txt

    sudo rm -rf /etc/timezone
    echo "Africa/Nairobi" | sudo tee /etc/timezone
    sudo ln -sf /usr/share/zoneinfo/Africa/Nairobi /etc/localtime

    sudo apt -y update;sudo apt -y install tzdata
    sudo dpkg-reconfigure --frontend noninteractive tzdata
}

install_nix_pre_requistes(){
    printf "\t\n\n 1. install nix-installation pre-requistes A \n"
    sudo apt -y update;sudo apt -y install sudo

    configure_timezone

    printf "\t\n\n 1.2 install nix-installation pre-requistes B \n" 
    sudo apt -y update; sudo apt -y install curl xz-utils
}
install_nix_pre_requistes

un_install_nix() {
    # see: https://nixos.org/manual/nix/stable/#sect-single-user-installation
    printf "\t\n\n uninstall nix \n"
    sudo rm -rf /nix
}

upgrade_nix() {
    # see:
    # 1. https://nixos.org/manual/nix/stable/#ch-upgrading-nix
    # 2. https://nixos.org/manual/nix/stable/#sec-nix-channel
    printf "\t\n\n upgrade nix \n"
    /nix/var/nix/profiles/per-user/$THE_USER/profile/bin/nix-channel --list
    nix-channel --remove nixpkgs
    /nix/var/nix/profiles/per-user/$THE_USER/profile/bin/nix-channel --add "https://nixos.org/channels/nixpkgs-unstable" nixpkgs-unstable # TODO: use a stable/specific version
    /nix/var/nix/profiles/per-user/$THE_USER/profile/bin/nix-channel --update
    /nix/var/nix/profiles/per-user/$THE_USER/profile/bin/nix-channel --list

    # Channels are a way of distributing Nix software, but they are being phased out.
    # Even though they are still used by default,
    # it is recommended to avoid channels and <nixpkgs> by always setting NIX_PATH= to be empty.
    # see: https://nixos.org/guides/towards-reproducibility-pinning-nixpkgs.html#pinning-nixpkgs
}


create_nix_conf_file(){
    printf "\t\n\n create nix conf file(/etc/nix/nix.conf) \n"
    sudo rm -rf /etc/nix/nix.conf
    sudo mkdir -p /etc/nix/
    sudo cp etc.nix.nix.conf /etc/nix/nix.conf
}

install_nix() {
    NIX_PACKAGE_MANAGER_VERSION=2.3.10
    printf "\t\n\n 2. install Nix package manager version %s \n" "$NIX_PACKAGE_MANAGER_VERSION"
    # This is a single-user installation: https://nixos.org/manual/nix/stable/#sect-single-user-installation
    # meaning that /nix is owned by the invoking user. Do not run as root.
    # The script will invoke sudo to create /nix
    # The install script will modify the first writable file from amongst ~/.bash_profile, ~/.bash_login and ~/.profile to source ~/.nix-profile/etc/profile.d/nix.sh

    un_install_nix
    create_nix_conf_file

    sh <(curl -L https://releases.nixos.org/nix/nix-$NIX_PACKAGE_MANAGER_VERSION/install) --no-daemon
    . ~/.nix-profile/etc/profile.d/nix.sh # source a file

    upgrade_nix 
}
install_nix


setup_nix_ca_bundle(){
    printf "\t\n\n 3. setup Nix CA bundle \n"
    CURL_CA_BUNDLE=$(find /nix -name ca-bundle.crt |tail -n 1)
    # TODO: maybe this export should also be done in /etc/profile?
    export CURL_CA_BUNDLE=$CURL_CA_BUNDLE
}
setup_nix_ca_bundle


clear_stuff(){
    printf "\t\n\n 4. clear stuff \n"
    sudo apt -y autoremove
    sudo apt -y clean
    sudo rm -rf /var/lib/apt/lists/*
    # The Nix store sometimes contains entries which are no longer useful.
    # garbage collect them
    /nix/var/nix/profiles/per-user/$THE_USER/profile/bin/nix-collect-garbage -d
    /nix/var/nix/profiles/per-user/$THE_USER/profile/bin/nix-store --optimise
    # ref: https://nixos.org/manual/nix/unstable/command-ref/nix-store.html
    /nix/var/nix/profiles/per-user/$THE_USER/profile/bin/nix-store --verify --repair
}
clear_stuff



create_nix_aliases(){
    touch ~/.bash_aliases # touch is silent if file already exists

    echo "
    ##### nix package manager aliases #####
    alias nix='/nix/var/nix/profiles/per-user/$THE_USER/profile/bin/nix'
    alias nix-build='/nix/var/nix/profiles/per-user/$THE_USER/profile/bin/nix-build'
    alias nix-channel='/nix/var/nix/profiles/per-user/$THE_USER/profile/bin/nix-channel'
    alias nix-collect-garbage='/nix/var/nix/profiles/per-user/$THE_USER/profile/bin/nix-collect-garbage'
    alias nix-copy-closure='/nix/var/nix/profiles/per-user/$THE_USER/profile/bin/nix-copy-closure'
    alias nix-daemon='/nix/var/nix/profiles/per-user/$THE_USER/profile/bin/nix-daemon'
    alias nix-env='/nix/var/nix/profiles/per-user/$THE_USER/profile/bin/nix-env'
    alias nix-hash='/nix/var/nix/profiles/per-user/$THE_USER/profile/bin/nix-hash'
    alias nix-instantiate='/nix/var/nix/profiles/per-user/$THE_USER/profile/bin/nix-instantiate'
    alias nix--prefetch-url='/nix/var/nix/profiles/per-user/$THE_USER/profile/bin/nix--prefetch-url'
    alias nix-shell='/nix/var/nix/profiles/per-user/$THE_USER/profile/bin/nix-shell'
    alias nix-store='/nix/var/nix/profiles/per-user/$THE_USER/profile/bin/nix-store'
    ##### nix package manager aliases #####" | sudo tee ~/.bash_aliases
    . ~/.bash_aliases
}
create_nix_aliases


# TODO: make it possible to run this function
uninstall_non_essential_apt_packages(){
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

    printf "\t\n\n packages to be removed are; \n"
    echo "$EXTRA_PACKAGES_AND_OPTIONAL_PACKAGES_MINUS_GRUB"
    sudo apt -y autoremove
    sudo apt purge -y $EXTRA_PACKAGES_AND_OPTIONAL_PACKAGES_MINUS_GRUB
    clear_stuff
}
# uninstall_non_essential_apt_packages


# The main command for package management is nix-env.
# See: https://nixos.org/manual/nix/stable/#ch-basic-package-mgmt
# Although others think it should not be widely recommended
# https://news.ycombinator.com/item?id=26748696

