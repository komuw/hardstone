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


printf "\n\n create personal ssh-key\n"
if [[ ! -e /home/$MY_NAME/.ssh/personal_id_rsa.pub ]]; then
    mkdir -p /home/$MY_NAME/.ssh
    ssh-keygen -t rsa -C komuwUbuntu -b 8192 -q -N "$SSH_KEY_PHRASE_PERSONAL" -f /home/$MY_NAME/.ssh/personal_id_rsa
fi
chmod 600 /home/$MY_NAME/.ssh/personal_id_rsa
chmod 600 /home/$MY_NAME/.ssh/personal_id_rsa.pub
chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/.ssh

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


printf "\n\n your ssh public key for personal work is\n"
cat /home/$MY_NAME/.ssh/personal_work_id_rsa.pub
########################## personal work ssh key ##################

printf "\n\n configure ssh/config\n"
cp ../templates/ssh_conf.j2 /home/$MY_NAME/.ssh/config

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