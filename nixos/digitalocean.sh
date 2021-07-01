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

# from: https://docs.digitalocean.com/droplets/tutorials/recommended-setup/
digital_ocean_user_data(){
#!/bin/bash
set -euo pipefail

USERNAME=dembe # TODO: Customize the sudo non-root username here

# Create user and immediately expire password to force a change on login
useradd --create-home --shell "/bin/bash" --groups sudo "${USERNAME}"
passwd --delete "${USERNAME}"
chage --lastday 0 "${USERNAME}"

# Create SSH directory for sudo user and move keys over
home_directory="$(eval echo ~${USERNAME})"
mkdir --parents "${home_directory}/.ssh"
cp /root/.ssh/authorized_keys "${home_directory}/.ssh"
chmod 0700 "${home_directory}/.ssh"
chmod 0600 "${home_directory}/.ssh/authorized_keys"
chown --recursive "${USERNAME}":"${USERNAME}" "${home_directory}/.ssh"

# Disable root SSH login with password
sed --in-place 's/^PermitRootLogin.*/PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config
if sshd -t -q; then systemctl restart sshd fi
}

MY_NAME=$(whoami)
sudo apt -y update && \
sudo apt -y install python && \
sudo apt -y install python3-pip nano wget unzip curl screen

MY_NAME=$(whoami)
rm -rf /home/$MY_NAME/installDir
mkdir -p /home/$MY_NAME/installDir
cd /home/$MY_NAME/installDir

git clone https://github.com/komuw/hardstone.git
cd hardstone/
git checkout nix-inheritance
cd nixos/
bash start.sh && nix-shell pkgs/


screen -S nixSession
screen -ls
