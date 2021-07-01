#!/usr/bin/env bash
shopt -s nullglob globstar
set -x # have bash print command been ran
set -e # fail if any command fails

export DEBIAN_FRONTEND=noninteractive

# Usage:
# 1. docker build -t hardstone-nix .
# 2. docker run -it hardstone-nix
# 3. bash start.sh
# 4. export NIXPKGS_ALLOW_UNFREE=1 && \ # for vscode
#    export SSH_KEY_PHRASE_PERSONAL=SSH_KEY_PHRASE_PERSONAL  && \
#    export SSH_KEY_PHRASE_PERSONAL_WORK=SSH_KEY_PHRASE_PERSONAL_WORK && \
#    export PERSONAL_WORK_EMAIL=PERSONAL_WORK_EMAIL@example.com && \
# 5. nix-shell pkgs/
#
# or:
# 1. docker-compose run my_nix_env
# or:
# 1. docker-compose run my_nix_env bash
# 2. bash start.sh
# 3. export SSH_KEY_PHRASE_PERSONAL=SSH_KEY_PHRASE_PERSONAL  && \
#    export SSH_KEY_PHRASE_PERSONAL_WORK=SSH_KEY_PHRASE_PERSONAL_WORK && \
#    export PERSONAL_WORK_EMAIL=PERSONAL_WORK_EMAIL@example.com && \
# 4. nix-shell pkgs/


# TODO: setup ntp; https://help.ubuntu.com/community/UbuntuTime

MY_NAME=$(whoami)

configure_timezone(){
    printf "\n\n\t 1. configure_timezone \n"

    sudo rm -rf /tmp/*.txt

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

    sudo rm -rf /etc/apt/sources.list.d/*
    sudo apt -y update
    sudo apt -y install sudo
    sudo apt -y update
    sudo apt-get -y dist-upgrade # security updates
    sudo apt -y install curl xz-utils
}
install_nix_pre_requistes

un_install_nix() {
    printf "\n\n\t 3. un_install_nix \n"

    # see: https://nixos.org/manual/nix/stable/#sect-single-user-installation
    sudo rm -rf /nix
}
un_install_nix

create_nix_conf_file(){
    printf "\n\n\t 4. create_nix_conf_file \n"

    sudo rm -rf /etc/nix/nix.conf
    sudo mkdir -p /etc/nix/
    sudo cp etc.nix.nix.conf /etc/nix/nix.conf
}
create_nix_conf_file

install_nix() {
    NIX_PACKAGE_MANAGER_VERSION=2.3.13
    printf "\n\n\t 5. install_nix version%s \n" "$NIX_PACKAGE_MANAGER_VERSION"

    # This is a single-user installation: https://nixos.org/manual/nix/stable/#sect-single-user-installation
    # meaning that /nix is owned by the invoking user. Do not run as root.
    # The script will invoke sudo to create /nix
    # The install script will modify the first writable file from amongst ~/.bash_profile, ~/.bash_login and ~/.profile to source ~/.nix-profile/etc/profile.d/nix.sh

    sh <(curl -L https://releases.nixos.org/nix/nix-$NIX_PACKAGE_MANAGER_VERSION/install) --no-daemon
    . ~/.nix-profile/etc/profile.d/nix.sh # source a file
}
install_nix

upgrade_nix() {
    printf "\n\n\t 6. upgrade_nix \n"

    # see:
    # 1. https://nixos.org/manual/nix/stable/#ch-upgrading-nix
    # 2. https://nixos.org/manual/nix/stable/#sec-nix-channel

    # TODO: do we need these?
    # /nix/var/nix/profiles/per-user/$MY_NAME/profile/bin/nix-channel --list
    # /nix/var/nix/profiles/per-user/$MY_NAME/profile/bin/nix-channel --remove nixpkgs
    # /nix/var/nix/profiles/per-user/$MY_NAME/profile/bin/nix-channel --add "https://nixos.org/channels/nixpkgs-unstable" nixpkgs-unstable # TODO: use a stable/specific version
    # /nix/var/nix/profiles/per-user/$MY_NAME/profile/bin/nix-channel --update
    # /nix/var/nix/profiles/per-user/$MY_NAME/profile/bin/nix-channel --list

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
    sudo rm -rf /var/lib/apt/lists/*
    # The Nix store sometimes contains entries which are no longer useful.
    # garbage collect them
    /nix/var/nix/profiles/per-user/$MY_NAME/profile/bin/nix-collect-garbage -d
    /nix/var/nix/profiles/per-user/$MY_NAME/profile/bin/nix-store --optimise
    # ref: https://nixos.org/manual/nix/unstable/command-ref/nix-store.html
    /nix/var/nix/profiles/per-user/$MY_NAME/profile/bin/nix-store --verify --repair
}
clear_stuff



create_nix_aliases(){
    printf "\n\n\t 9. create_nix_aliases \n"

    touch ~/.bash_aliases # touch is silent if file already exists

    echo "##### nix package manager aliases #####
alias nix='/nix/var/nix/profiles/per-user/$MY_NAME/profile/bin/nix'
alias nix-build='/nix/var/nix/profiles/per-user/$MY_NAME/profile/bin/nix-build'
alias nix-channel='/nix/var/nix/profiles/per-user/$MY_NAME/profile/bin/nix-channel'
alias nix-collect-garbage='/nix/var/nix/profiles/per-user/$MY_NAME/profile/bin/nix-collect-garbage'
alias nix-copy-closure='/nix/var/nix/profiles/per-user/$MY_NAME/profile/bin/nix-copy-closure'
alias nix-daemon='/nix/var/nix/profiles/per-user/$MY_NAME/profile/bin/nix-daemon'
alias nix-env='/nix/var/nix/profiles/per-user/$MY_NAME/profile/bin/nix-env'
alias nix-hash='/nix/var/nix/profiles/per-user/$MY_NAME/profile/bin/nix-hash'
alias nix-instantiate='/nix/var/nix/profiles/per-user/$MY_NAME/profile/bin/nix-instantiate'
alias nix--prefetch-url='/nix/var/nix/profiles/per-user/$MY_NAME/profile/bin/nix--prefetch-url'
alias nix-shell='/nix/var/nix/profiles/per-user/$MY_NAME/profile/bin/nix-shell'
alias nix-store='/nix/var/nix/profiles/per-user/$MY_NAME/profile/bin/nix-store'
##### nix package manager aliases #####" | sudo tee ~/.bash_aliases

    . ~/.bash_aliases # source a file
}
create_nix_aliases


# TODO: make it possible to run this function
uninstall_non_essential_apt_packages(){
    printf "\n\n\t 10. uninstall_non_essential_apt_packages \n"

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
    clear_stuff
}
# uninstall_non_essential_apt_packages


source_files(){
    printf "\n\n\t 11. source_files \n"

    . ~/.nix-profile/etc/profile.d/nix.sh
    . /home/$MY_NAME/.nix-profile/etc/profile.d/nix.sh
    . ~/.bash_aliases

    source ~/.nix-profile/etc/profile.d/nix.sh
    source /home/$MY_NAME/.nix-profile/etc/profile.d/nix.sh
    source ~/.bash_aliases
}
source_files

install_media_codecs(){
    printf "\n\n\t 12. install media codecs \n"

    sudo apt-get -y update
    echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections  # agree to ttf-mscorefonts-installer license(prepare media codecs install)
    sudo apt-get -y install ubuntu-restricted-extras                                                                  # install system packages  media codecs
}
install_media_codecs

# The main command for package management is nix-env.
# See: https://nixos.org/manual/nix/stable/#ch-basic-package-mgmt
# Although others think it should not be widely recommended
# https://news.ycombinator.com/item?id=26748696
