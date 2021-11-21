with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/b56d7a70a7158f81d964a55cfeb78848a067cc7d.tar.gz") {});

let
    # TODO: should we have a different passphrase per key?
    #
    # get env var from the external environment
    # https://stackoverflow.com/a/58018392
    SSH_KEY_PHRASE = builtins.getEnv "SSH_KEY_PHRASE" != "";

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
            if [[ -z "$SSH_KEY_PHRASE" ]]; then
                printf "\n\t ERROR: env var SSH_KEY_PHRASE is not set \n"
                exit 88
            else
                echo -n ""
            fi
        }

        personal_open_source_work_id_rsa_file="/home/$MY_NAME/.ssh/personal_open_source_work_id_rsa.pub"
        if [ -f "$personal_open_source_work_id_rsa_file" ]; then
            # file exists
            echo -n ""
        else
            validate_env_vars
        fi

        personal_NON_open_work_id_rsa_file="/home/$MY_NAME/.ssh/personal_NON_open_work_id_rsa.pub"
        if [ -f "$personal_NON_open_work_id_rsa_file" ]; then
            # file exists
            echo -n ""
        else
            validate_env_vars
        fi

        pd_work_id_rsa_file="/home/$MY_NAME/.ssh/pd_work_id_rsa.pub"
        if [ -f "$pd_work_id_rsa_file" ]; then
            # file exists
            echo -n ""
        else
            validate_env_vars
        fi


        create_personal_open_source_work_ssh_key(){
            if [[ ! -e /home/$MY_NAME/.ssh/personal_open_source_work_id_rsa.pub ]]; then
                mkdir -p /home/$MY_NAME/.ssh
                ssh-keygen -t rsa -C "$MY_NAME.personal_open_source_work@$MY_HOSTNAME" -b 8192 -q -N "$SSH_KEY_PHRASE" -f /home/$MY_NAME/.ssh/personal_open_source_work_id_rsa

                chmod 600 /home/$MY_NAME/.ssh/personal_open_source_work_id_rsa
                chmod 600 /home/$MY_NAME/.ssh/personal_open_source_work_id_rsa.pub
                chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/.ssh

                cat /home/$MY_NAME/.ssh/personal_open_source_work_id_rsa.pub
            fi
        }
        create_personal_open_source_work_ssh_key

        create_personal_NON_open_work_ssh_key(){
            if [[ ! -e /home/$MY_NAME/.ssh/personal_NON_open_work_id_rsa.pub ]]; then
                mkdir -p /home/$MY_NAME/.ssh
                ssh-keygen -t rsa -C "$MY_NAME.personal_NON_open_work@$MY_HOSTNAME" -b 8192 -q -N "$SSH_KEY_PHRASE" -f /home/$MY_NAME/.ssh/personal_NON_open_work_id_rsa

                chmod 600 /home/$MY_NAME/.ssh/personal_NON_open_work_id_rsa
                chmod 600 /home/$MY_NAME/.ssh/personal_NON_open_work_id_rsa.pub
                chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/.ssh

                cat /home/$MY_NAME/.ssh/personal_NON_open_work_id_rsa.pub
            fi
        }
        create_personal_NON_open_work_ssh_key

        create_pd_work_ssh_key(){
            if [[ ! -e /home/$MY_NAME/.ssh/pd_work_id_rsa.pub ]]; then
                mkdir -p /home/$MY_NAME/.ssh
                ssh-keygen -t rsa -C "$MY_NAME.pd_work@$MY_HOSTNAME" -b 8192 -q -N "$SSH_KEY_PHRASE" -f /home/$MY_NAME/.ssh/pd_work_id_rsa

                chmod 600 /home/$MY_NAME/.ssh/pd_work_id_rsa
                chmod 600 /home/$MY_NAME/.ssh/pd_work_id_rsa.pub
                chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/.ssh

                cat /home/$MY_NAME/.ssh/pd_work_id_rsa.pub
            fi
        }
        create_pd_work_ssh_key

        setup_ssh_conf(){
            cp ../templates/ssh_conf.j2 /home/$MY_NAME/.ssh/config
        }
        setup_ssh_conf
    '';
}
