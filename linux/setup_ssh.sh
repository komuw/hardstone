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
MY_HOSTNAME=$(hostname)


SSH_KEY_PHRASE_PERSONAL=${1:-sshKeyPhrasePersonalNotSet}
if [ "$SSH_KEY_PHRASE_PERSONAL" == "sshKeyPhrasePersonalNotSet"  ]; then
    printf "\n\n SSH_KEY_PHRASE_PERSONAL should not be empty\n"
    exit
fi

PERSONAL_WORK_EMAIL=${2:-PERSONAL_WORK_EMAILNotSet}
if [ "$PERSONAL_WORK_EMAIL" == "PERSONAL_WORK_EMAILNotSet"  ]; then
    printf "\n\n PERSONAL_WORK_EMAIL should not be empty\n"
    exit
fi


create_personal_ssh_key(){
    printf "\n\n create personal ssh-key\n"
    if [[ ! -e /home/$MY_NAME/.ssh/personal_id_rsa.pub ]]; then
        mkdir -p /home/$MY_NAME/.ssh
        ssh-keygen -t rsa -C "$MY_NAME.personal@$MY_HOSTNAME" -b 8192 -q -N "$SSH_KEY_PHRASE_PERSONAL" -f /home/$MY_NAME/.ssh/personal_id_rsa
    fi
    chmod 600 /home/$MY_NAME/.ssh/personal_id_rsa
    chmod 600 /home/$MY_NAME/.ssh/personal_id_rsa.pub
    chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/.ssh

    printf "\n\n your personal ssh public key is\n"
    cat /home/$MY_NAME/.ssh/personal_id_rsa.pub
}
create_personal_ssh_key

create_personal_work_ssh_key(){
    printf "\n\n create personal work ssh-key\n"
    if [[ ! -e /home/$MY_NAME/.ssh/personal_work_id_rsa.pub ]]; then
        mkdir -p /home/$MY_NAME/.ssh
        ssh-keygen -t rsa -C "$MY_NAME.personal_work@$MY_HOSTNAME" -b 8192 -q -N "$SSH_KEY_PHRASE_PERSONAL" -f /home/$MY_NAME/.ssh/personal_work_id_rsa
    fi
    chmod 600 /home/$MY_NAME/.ssh/personal_work_id_rsa
    chmod 600 /home/$MY_NAME/.ssh/personal_work_id_rsa.pub
    chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/.ssh

    printf "\n\n your ssh public key for personal work is\n"
    cat /home/$MY_NAME/.ssh/personal_work_id_rsa.pub
}
create_personal_work_ssh_key

setup_ssh_conf(){
    printf "\n\n configure ssh/config\n"
    cp ../templates/ssh_conf.j2 /home/$MY_NAME/.ssh/config
}
setup_ssh_conf
