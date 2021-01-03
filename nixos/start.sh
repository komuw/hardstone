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

# START
# docker run -it ubuntu:20.04 bash


# TODO: setup ntp; https://help.ubuntu.com/community/UbuntuTime



install_nix_pre_requistes(){
    printf "\n\n 1. install nix-installation pre-requistes A \n" 
    apt -y update;apt -y install tzdata sudo

    printf "\n\n 1.1 nix-installation pre-requistes: tzdata config A \n" 
    echo "tzdata tzdata/Areas select Africa
    tzdata tzdata/Zones/Africa select Nairobi" >> /tmp/tzdata_preseed.txt
    debconf-set-selections /tmp/tzdata_preseed.txt
    rm -rf /etc/timezone; echo "Africa/Nairobi" >> /etc/timezone
    sudo dpkg-reconfigure --frontend noninteractive tzdata

    printf "\n\n 1.2 install nix-installation pre-requistes B \n" 
    apt -y update;apt -y install curl xz-utils
}
install_nix_pre_requistes

un_install_nix() {
    # see: https://nixos.org/manual/nix/stable/#sect-single-user-installation
    printf "\n\n uninstall nix \n"
    rm -rf /nix
}
upgrade_nix() {
    # see: https://nixos.org/manual/nix/stable/#ch-upgrading-nix
    printf "\n\n upgrade nix \n"
    /nix/var/nix/profiles/default/bin/nix-channel --update
}


# TODO: install particular version of nix
# TODO: come up with my own nix config file(/etc/nix/nix.conf)
# https://nixos.org/manual/nix/unstable/command-ref/conf-file.html
install_nix() {
    printf "\n\n 2. install Nix \n"
    # This is a single-user installation: https://nixos.org/manual/nix/stable/#sect-single-user-installation
    # meaning that /nix is owned by the invoking user. Do not run as root.
    # The script will invoke sudo to create /nix
    # The install script will modify the first writable file from amongst ~/.bash_profile, ~/.bash_login and ~/.profile to source ~/.nix-profile/etc/profile.d/nix.sh
    un_install_nix
    rm -rf /etc/nix/nix.conf; mkdir -p /etc/nix/; echo "build-users-group =" >> /etc/nix/nix.conf # see: https://github.com/NixOS/nix/issues/697
    sh <(curl -L https://nixos.org/nix/install) --no-daemon
    source ~/.nix-profile/etc/profile.d/nix.sh
    upgrade_nix
}
install_nix

setup_nix_ca_bundle(){
    printf "\n\n 3. setup Nix CA bundle \n"
    CURL_CA_BUNDLE=$(find /nix -name ca-bundle.crt |tail -n 1)
    export CURL_CA_BUNDLE=$CURL_CA_BUNDLE
}
setup_nix_ca_bundle


clear_stuff(){
    printf "\n\n 4. clear stuff \n"
    apt -y clean
    rm -rf /var/lib/apt/lists/*
    # The Nix store sometimes contains entries which are no longer useful.
    # garbage collect them
    /nix/var/nix/profiles/default/bin/nix-collect-garbage -d
    /nix/var/nix/profiles/default/bin/nix-store --optimise
    # ref: https://nixos.org/manual/nix/unstable/command-ref/nix-store.html
    /nix/var/nix/profiles/default/bin/nix-store --verify --repair
}
clear_stuff

uninstall_non_essential_apt_packages(){
    printf "\n\n 5. list all non-essential apt packages \n"
    echo `dpkg-query -Wf '${Package;-40}${Priority}\n' | grep -i optional | awk '{print $1}'`

    printf "\n\n uninstall all non-essential apt packages \n"
    apt purge -y `dpkg-query -Wf '${Package;-40}${Priority}\n' | grep -i optional | awk '{print $1}'`
}
uninstall_non_essential_apt_packages



