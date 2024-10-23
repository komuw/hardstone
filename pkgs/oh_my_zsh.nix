with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/fa6faf973d97caaea26b88eba007b61bb8228fd8.tar.gz") {});

let

in stdenv.mkDerivation {
    name = "oh_my_zsh";

    buildInputs = [
        pkgs.zsh
        ];

    shellHook = ''
        # set -e # fail if any command fails
        # do not use `set -e` which causes commands to fail.
        # because it causes `nix-shell` to also exit if a command fails when running in the eventual shell

        printf "\n running hooks for oh_my_zsh.nix \n"

        MY_NAME=$(whoami)

        install_ohmyzsh(){
            oh_my_zsh_licence="/home/$MY_NAME/.oh-my-zsh/LICENSE.txt"
            if [ -f "$oh_my_zsh_licence" ]; then
                # repo exists
                echo -n ""
            else
                rm -rf /home/$MY_NAME/.oh-my-zsh
                rm -rf /tmp/oh-my-zsh
                rm -rf /tmp/zsh-autosuggestions
                rm -rf /tmp/zsh-completions

                git clone --depth 3 https://github.com/ohmyzsh/ohmyzsh.git /home/$MY_NAME/.oh-my-zsh
                git clone --depth 3 https://github.com/zsh-users/zsh-autosuggestions.git /home/$MY_NAME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
                git clone --depth 3 https://github.com/zsh-users/zsh-completions.git /home/$MY_NAME/.oh-my-zsh/custom/plugins/zsh-completions

                cp ./templates/oh_my_zsh/zshrc.j2 /home/$MY_NAME/.zshrc
                cp ./templates/oh_my_zsh/zshrc.j2 ~/.zshrc
            fi

            chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/.zshrc
            chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/.oh-my-zsh

            # printf "\n activate zsh shell\n"
            # chsh -s $(which zsh)
        }
        install_ohmyzsh

        add_ohmyzsh_aliases(){
            oh_my_zsh_aliases="/home/$MY_NAME/.oh-my-zsh/custom/my_aliases.zsh"
            if [ -f "$oh_my_zsh_aliases" ]; then
                # file exists
                echo -n ""
            else
                cp ./templates/oh_my_zsh/oh_my_zsh_aliases.zsh /home/$MY_NAME/.oh-my-zsh/custom/my_aliases.zsh
                chown -R $MY_NAME:$MY_NAME $oh_my_zsh_aliases
            fi
        }
        add_ohmyzsh_aliases


        seed_shell_history(){
            # By default, zsh saves history to the file referenced by the env var `HISTFILE`
            # On my machine that happens to be `~/.zsh_history`.
            # There's also `~/.bash_history` which is used by bash.
            # We should ideally keep the two files in sync

            # 1. If .zsh_history file DOES not exists, use .bash_history file instead.
            # 2. Read the file found in 1(above) and only read the latest X size. Where X is the value specified by `programs.zsh.histSize`
            # 3. Backup .zsh_history file if it exists.
            # 4. Write `templates/oh_my_zsh/bash_history.txt` to both `.zsh_history` and `.bash_history`
            # 5. Write the buffer read in 2(above) to both `.zsh_history` and `.bash_history`
            # 6. end

            # 1.
            MY_FILE=/home/$MY_NAME/.zsh_history # should not have quotes
            if test -f "$MY_FILE"; then
                # zsh_history exists, so we will use it.
                echo -n ""
            else
                MY_FILE=/home/$MY_NAME/.bash_history # should not have quotes
            fi

            # 2.
            MY_BUFFER=$(tail -n 12000 "$MY_FILE") # we are reading 12000 which is greater than `programs.zsh.histSize` just to be sure.

            # 3.
            cp "$MY_FILE" "$MY_FILE".backup

            # empty the files. DO not use `>>`(which means append)
            # this will also create them if they dont exist.
            echo -n > /home/$MY_NAME/.zsh_history
            echo -n > /home/$MY_NAME/.bash_history

            # 4.
            # for the following, we want to use `>>` for append rather than `>` which truncates and then writes.
            printf "\n\n#\t SEEDED HISTORY::\n\n" >> /home/$MY_NAME/.zsh_history
            printf "\n\n#\t SEEDED HISTORY::\n\n" >> /home/$MY_NAME/.bash_history
            cat ./templates/oh_my_zsh/bash_history.txt >> /home/$MY_NAME/.zsh_history
            cat ./templates/oh_my_zsh/bash_history.txt >> /home/$MY_NAME/.bash_history

            # 5.
            printf "\n\n#\t RELOADED HISTORY::\n\n" >> /home/$MY_NAME/.zsh_history
            printf "\n\n#\t RELOADED HISTORY::\n\n" >> /home/$MY_NAME/.bash_history
            echo "$MY_BUFFER" >> /home/$MY_NAME/.zsh_history # use echo instead of printf to minimize errors about bad formatting.
            echo "$MY_BUFFER" >> /home/$MY_NAME/.bash_history
        }
        seed_shell_history
    '';
}
