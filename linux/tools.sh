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
sudo rm -rf /tmp/*

setup_pip(){
    printf "\n\n setup_pip config \n"

    mkdir -p /home/$MY_NAME/.pip
    PIP_CONFIG_FILE_CONTENTS='[global]
    download_cache = /home/$MY_NAME/.cache/pip'
    PIP_CONFIG_FILE=/home/$MY_NAME/.pip/pip.conf
    touch "$PIP_CONFIG_FILE"
    grep -qF -- "$PIP_CONFIG_FILE_CONTENTS" "$PIP_CONFIG_FILE" || echo "$PIP_CONFIG_FILE_CONTENTS" >> "$PIP_CONFIG_FILE"

    mkdir -p /home/$MY_NAME/.cache && mkdir -p /home/$MY_NAME/.cache/pip  # cache directory
    chown -R $MY_NAME /home/$MY_NAME/.cache/pip                           # give $MY_NAME  group ownership of pip cache dir
}
setup_pip

install_python3_packages(){
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
}
install_python3_packages

install_bat(){
    printf "\n\n install bat(https://github.com/sharkdp/bat)\n"
    wget -nc --output-document=/tmp/bat_amd64.deb https://github.com/sharkdp/bat/releases/download/v0.18.1/bat_0.18.1_amd64.deb
    sudo dpkg -i /tmp/bat_amd64.deb
}
install_bat

install_google_chrome(){
    printf "\n\n install google chrome\n"

    sudo apt -y update
    # install chrome dependencies
    sudo apt-get -y install libdbusmenu-glib4 \
                        libdbusmenu-gtk3-4 \
                        libindicator3-7 \
                        libappindicator3-1
    wget -nc --output-document=/tmp/google_chrome_stable_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i /tmp/google_chrome_stable_amd64.deb
    sudo apt-get -f -y install # fix install chrome errors
}
install_google_chrome

install_skype(){
    printf "\n\n install skype\n"

    sudo apt -y update
    sudo apt-key del 1F3045A5DF7587C3 # https://askubuntu.com/questions/1348146/invalid-signature-from-repo-skype-com-how-can-i-clear-this/1348149
    curl https://repo.skype.com/data/SKYPE-GPG-KEY | sudo apt-key add -
    sudo apt-get -y purge skype*
    rm -rf /home/$MY_NAME/.Skype
    sudo apt -y install gconf-service libgconf-2-4 gnome-keyring # pre-requistes
    wget -nc --output-document=/tmp/skype.deb https://go.skype.com/skypeforlinux-64.deb
    sudo dpkg -i /tmp/skype.deb
}
install_skype

install_docker(){
    # NB: do not install docker from snap, it is broken
    printf "\n\n install docker\n"
    sudo apt -y purge docker docker.io containerd runc
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg                                                                                  # add key
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null  # add docker repo
    sudo apt -y update
    sudo apt -y install docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker $MY_NAME                                                                                                                                                                                # add user to docker group

    printf "\n\n create docker dir\n"
    mkdir -p /home/$MY_NAME/.docker
    printf "\n\n make docker group owner of docker dir\n"
    sudo chown -R $MY_NAME:docker /home/$MY_NAME/.docker
    printf "\n\n add proper permissions to docker dir\n"
    chmod -R 775 /home/$MY_NAME/.docker

    printf "\n\n configure /etc/docker/daemon.json file\n"
    sudo mkdir -p /etc/docker
    sudo chown -R $MY_NAME:docker /etc/docker
    DOCKER_DAEMON_CONFIG_FILE_CONTENTS='{
        "max-concurrent-downloads": 12,
        "max-concurrent-uploads": 5
    }'
    DOCKER_DAEMON_CONFIG_FILE=/etc/docker/daemon.json
    touch "$DOCKER_DAEMON_CONFIG_FILE"
    grep -qF -- "$DOCKER_DAEMON_CONFIG_FILE_CONTENTS" "$DOCKER_DAEMON_CONFIG_FILE" || echo "$DOCKER_DAEMON_CONFIG_FILE_CONTENTS" >> "$DOCKER_DAEMON_CONFIG_FILE"
}
install_docker

install_ripgrep(){
    printf "\n\n install ripgrep\n"
    wget -nc --output-document=/tmp/ripgrep_amd64.deb "https://github.com/BurntSushi/ripgrep/releases/download/12.1.1/ripgrep_12.1.1_amd64.deb"
    sudo dpkg -i /tmp/ripgrep_amd64.deb
}
install_ripgrep

install_ripgrep_all(){
    printf "\n\n install ripgrep-all(rga)\n"
    if [[ ! -e /tmp/rga.tar.gz ]]; then
        wget --output-document=/tmp/rga.tar.gz "https://github.com/phiresky/ripgrep-all/releases/download/v0.9.6/ripgrep_all-v0.9.6-x86_64-unknown-linux-musl.tar.gz"
    fi
    tar -xzf /tmp/rga.tar.gz -C /tmp
    sudo mv /tmp/ripgrep_all-v0.9.6-x86_64-unknown-linux-musl/rga /usr/local/bin/rga
    chmod +x /usr/local/bin/rga
}
install_ripgrep_all

install_mozilla_rr(){
    printf "\n\n install mozilla rr debugger\n"
    wget -nc --output-document=/tmp/rr_amd64.deb "https://github.com/rr-debugger/rr/releases/download/5.4.0/rr-5.4.0-Linux-x86_64.deb"
    sudo dpkg -i /tmp/rr_amd64.deb
}
install_mozilla_rr

install_zoom(){
    printf "\n\n install zoom\n"

    sudo apt -y update
    # install zoom dependencies
    sudo apt-get -y install libgl1-mesa-glx \
                        libegl1-mesa \
                        libxcb-xtest0 \
                        libxcb-xinerama0

    wget -nc --output-document=/tmp/zoom_amd64.deb https://zoom.us/client/latest/zoom_amd64.deb
    sudo dpkg -i /tmp/zoom_amd64.deb
}
install_zoom

# install_nodeJs(){
#     printf "\n\n install nodeJs\n"
#     curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
#     apt-get install -y nodejs
# }
# install_nodeJs
