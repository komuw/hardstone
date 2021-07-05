with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/21.05.tar.gz") {});

let
    # get env var from the external environment
    # https://stackoverflow.com/a/58018392
    SSH_KEY_PHRASE_PERSONAL = builtins.getEnv "SSH_KEY_PHRASE_PERSONAL" != "";

in stdenv.mkDerivation {
    name = "setup_ssh";

    buildInputs = [];

    shellHook = ''
        # set -e # fail if any command fails
        # do not use `set -e` which causes commands to fail.
        # because it causes `nix-shell` to also exit if a command fails when running in the eventual shell

        printf "\n running hooks for setup_ssh.nix \n"

        MY_NAME=$(whoami)
        MY_HOSTNAME=$(hostname)

        validate_env_vars(){
            if [[ -z "$SSH_KEY_PHRASE_PERSONAL" ]]; then
                printf "\n\t ERROR: env var SSH_KEY_PHRASE_PERSONAL is not set \n"
                exit 88
            else
                echo -n ""
            fi
        }

        personal_id_rsa_file="/home/$MY_NAME/.ssh/personal_id_rsa.pub"
        if [ -f "$personal_id_rsa_file" ]; then
            # file exists
            echo -n ""
        else
            validate_env_vars
        fi

        personal_work_id_rsa_file="/home/$MY_NAME/.ssh/personal_work_id_rsa.pub"
        if [ -f "$personal_work_id_rsa_file" ]; then
            # file exists
            echo -n ""
        else
            validate_env_vars
        fi


        create_personal_ssh_key(){
            if [[ ! -e /home/$MY_NAME/.ssh/personal_id_rsa.pub ]]; then
                mkdir -p /home/$MY_NAME/.ssh
                ssh-keygen -t rsa -C "$MY_NAME.personal@$MY_HOSTNAME" -b 8192 -q -N "$SSH_KEY_PHRASE_PERSONAL" -f /home/$MY_NAME/.ssh/personal_id_rsa

                chmod 600 /home/$MY_NAME/.ssh/personal_id_rsa
                chmod 600 /home/$MY_NAME/.ssh/personal_id_rsa.pub
                chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/.ssh

                cat /home/$MY_NAME/.ssh/personal_id_rsa.pub
            fi
        }
        create_personal_ssh_key

        create_personal_work_ssh_key(){
            if [[ ! -e /home/$MY_NAME/.ssh/personal_work_id_rsa.pub ]]; then
                mkdir -p /home/$MY_NAME/.ssh
                ssh-keygen -t rsa -C "$MY_NAME.personal_work@$MY_HOSTNAME" -b 8192 -q -N "$SSH_KEY_PHRASE_PERSONAL" -f /home/$MY_NAME/.ssh/personal_work_id_rsa

                chmod 600 /home/$MY_NAME/.ssh/personal_work_id_rsa
                chmod 600 /home/$MY_NAME/.ssh/personal_work_id_rsa.pub
                chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/.ssh

                cat /home/$MY_NAME/.ssh/personal_work_id_rsa.pub
            fi
        }
        create_personal_work_ssh_key

        setup_ssh_conf(){
            cp ../templates/ssh_conf.j2 /home/$MY_NAME/.ssh/config
        }
        setup_ssh_conf
    '';
}
