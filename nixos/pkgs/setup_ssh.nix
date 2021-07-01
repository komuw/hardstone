{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/21.05.tar.gz") {} }:

{
  inputs = [
      pkgs.curl
  ];
  hooks = ''
    printf "\n\n running hooks for setup_ssh.nix \n\n"

    MY_NAME=$(whoami)

    validate(){
        if [[ -z "${SSH_KEY_PHRASE_PERSONAL}" ]]; then
            printf "\n SSH_KEY_PHRASE_PERSONAL is not set \n"
            exit 88
        else
            echo ""
        fi

        if [[ -z "${SSH_KEY_PHRASE_PERSONAL_WORK}" ]]; then
            printf "\n SSH_KEY_PHRASE_PERSONAL_WORK is not set \n"
            exit 88
        else
            echo ""
        fi

    }
    validate

    create_personal_ssh_key(){
        printf "\n\n create personal ssh-key\n"
        if [[ ! -e /home/$MY_NAME/.ssh/personal_id_rsa.pub ]]; then
            mkdir -p /home/$MY_NAME/.ssh
            ssh-keygen -t rsa -C "$MY_NAME@Ubuntu" -b 8192 -q -N "$SSH_KEY_PHRASE_PERSONAL" -f /home/$MY_NAME/.ssh/personal_id_rsa
        fi
        chmod 600 /home/$MY_NAME/.ssh/personal_id_rsa
        chmod 600 /home/$MY_NAME/.ssh/personal_id_rsa.pub
        chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/.ssh

        printf "\n\n your personal ssh public key is\n"
        cat /home/$MY_NAME/.ssh/personal_id_rsa.pub
    }
    create_personal_ssh_key


  '';
}
