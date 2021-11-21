with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/b56d7a70a7158f81d964a55cfeb78848a067cc7d.tar.gz") {});

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
                git clone https://github.com/robbyrussell/oh-my-zsh.git /home/$MY_NAME/.oh-my-zsh

                git clone https://github.com/zsh-users/zsh-autosuggestions /home/$MY_NAME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
                git clone https://github.com/zsh-users/zsh-completions /home/$MY_NAME/.oh-my-zsh/custom/plugins/zsh-completions

                cp ../templates/zshrc.j2 /home/$MY_NAME/.zshrc
                cp ../templates/zshrc.j2 ~/.zshrc
            fi

            chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/.zshrc
            chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/.oh-my-zsh

            # printf "\n activate zsh shell\n"
            # chsh -s $(which zsh)
        }
        install_ohmyzsh

    '';
}
