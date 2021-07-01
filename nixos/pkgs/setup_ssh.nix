{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/21.05.tar.gz") {} }:

{
  inputs = [];

  # get env var from the external environment
  # https://stackoverflow.com/a/58018392
  SSH_KEY_PHRASE_PERSONAL = builtins.getEnv "SSH_KEY_PHRASE_PERSONAL" != "";
  SSH_KEY_PHRASE_PERSONAL_WORK = builtins.getEnv "SSH_KEY_PHRASE_PERSONAL_WORK" != "";
  PERSONAL_WORK_EMAIL = builtins.getEnv "PERSONAL_WORK_EMAIL" != "";

  hooks = ''
      # set -e # fail if any command fails
      # do not use `set -e` which causes commands to fail.
      # because it causes `nix-shell` to also exit if a command fails when running in the eventual shell

    printf "\n\n running hooks for setup_ssh.nix \n\n"

    MY_NAME=$(whoami)

    validate_env_vars(){
        if [[ -z "$SSH_KEY_PHRASE_PERSONAL" ]]; then
            printf "\n env var SSH_KEY_PHRASE_PERSONAL is not set \n"
            exit 88
        else
            echo ""
        fi

        if [[ -z "$SSH_KEY_PHRASE_PERSONAL_WORK" ]]; then
            printf "\n env var SSH_KEY_PHRASE_PERSONAL_WORK is not set \n"
            exit 88
        else
            echo ""
        fi

        if [[ -z "$PERSONAL_WORK_EMAIL" ]]; then
            printf "\n env var PERSONAL_WORK_EMAIL is not set \n"
            exit 88
        else
            echo ""
        fi
    }

    personal_id_rsa_file="/home/$MY_NAME/.ssh/personal_id_rsa.pub"
    if [ -f "$personal_id_rsa_file" ]; then
        # file exists
        echo ""
    else
        validate_env_vars
    fi

    personal_work_id_rsa_file="/home/$MY_NAME/.ssh/personal_work_id_rsa.pub"
    if [ -f "$personal_work_id_rsa_file" ]; then
        # file exists
        echo ""
    else
        validate_env_vars
    fi


    create_personal_ssh_key(){
        if [[ ! -e /home/$MY_NAME/.ssh/personal_id_rsa.pub ]]; then
            mkdir -p /home/$MY_NAME/.ssh
            ssh-keygen -t rsa -C "$MY_NAME@Ubuntu" -b 8192 -q -N "$SSH_KEY_PHRASE_PERSONAL" -f /home/$MY_NAME/.ssh/personal_id_rsa
        fi
        chmod 600 /home/$MY_NAME/.ssh/personal_id_rsa
        chmod 600 /home/$MY_NAME/.ssh/personal_id_rsa.pub
        chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/.ssh

        cat /home/$MY_NAME/.ssh/personal_id_rsa.pub
    }
    create_personal_ssh_key

    create_personal_work_ssh_key(){
        if [[ ! -e /home/$MY_NAME/.ssh/personal_work_id_rsa.pub ]]; then
            mkdir -p /home/$MY_NAME/.ssh
            ssh-keygen -t rsa -C "$PERSONAL_WORK_EMAIL" -b 8192 -q -N "$SSH_KEY_PHRASE_PERSONAL" -f /home/$MY_NAME/.ssh/personal_work_id_rsa
        fi
        chmod 600 /home/$MY_NAME/.ssh/personal_work_id_rsa
        chmod 600 /home/$MY_NAME/.ssh/personal_work_id_rsa.pub
        chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/.ssh

        cat /home/$MY_NAME/.ssh/personal_work_id_rsa.pub
    }
    create_personal_work_ssh_key

    setup_ssh_conf(){
        cp ../templates/ssh_conf.j2 /home/$MY_NAME/.ssh/config
    }
    setup_ssh_conf

    setup_bashrc(){
        # there ought to be NO newlines in the content
        BASHRC_FILE_FILE_CONTENTS='

        setup_ssh_agent(){
            # start ssh-agent and add keys.
            # https://stackoverflow.com/a/38619604
            if [ ! -S ~/.ssh/ssh_auth_sock ]; then
                eval `ssh-agent`
                ln -sf "$SSH_AUTH_SOCK" ~/.ssh/ssh_auth_sock
            fi
            export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock
            ssh-add /home/$MY_NAME/.ssh/personal_id_rsa /home/$MY_NAME/.ssh/personal_work_id_rsa
            ssh-add -l
        }
        setup_ssh_agent

        export HISTTIMEFORMAT="%d/%m/%Y %T "'

        BASHRC_FILE=/home/$MY_NAME/.bashrc
        touch "$BASHRC_FILE"
        grep -qxF "$BASHRC_FILE_FILE_CONTENTS" "$BASHRC_FILE" || echo "$BASHRC_FILE_FILE_CONTENTS" >> "$BASHRC_FILE"
    }
    setup_bashrc

  '';
}

