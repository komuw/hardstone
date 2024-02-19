with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/f63489a7f0a548df967dc58d7d8fd18a0046d37d.tar.gz") {});

let

in stdenv.mkDerivation {
    name = "vscode";

    buildInputs = [
        pkgs.vscode # unfree
    ];

    shellHook = ''
        # set -e # fail if any command fails
        # do not use `set -e` which causes commands to fail.
        # because it causes `nix-shell` to also exit if a command fails when running in the eventual shell

        printf "\n running hooks for vscode.nix \n"

        MY_NAME=$(whoami)

        add_vscode_cofig(){
            # on MacOs it is /Users/$MY_NAME/Library/Application\ Support/Code/User/settings.json

            # configure vscode user settings file
            mkdir -p /home/$MY_NAME/.config/Code/User
            mkdir -p /home/$MY_NAME/.vscode
            touch /home/$MY_NAME/.config/Code/User/settings.json
            chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/.config/Code/
            chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/.vscode
            cp ../templates/vscode_settings.json /home/$MY_NAME/.config/Code/User/settings.json
        }
        add_vscode_cofig

        install_vscode_extensions(){
            # install vscode extensions

            installed_extensions=$(code --list-extensions)
            if [[ "$installed_extensions" == *"hashicorp.terraform"* ]]; then
                # extensions already installed
                echo -n ""
            else
                code --user-data-dir='/tmp/' --install-extension ms-python.python
                code --user-data-dir='/tmp/' --install-extension ms-python.vscode-pylance
                code --user-data-dir='/tmp/' --install-extension dart-code.dart-code
                code --user-data-dir='/tmp/' --install-extension dart-code.flutter
                code --user-data-dir='/tmp/' --install-extension donaldtone.auto-open-markdown-preview-single
                code --user-data-dir='/tmp/' --install-extension golang.go
                code --user-data-dir='/tmp/' --install-extension ms-azuretools.vscode-docker
                code --user-data-dir='/tmp/' --install-extension hashicorp.terraform
                code --user-data-dir='/tmp/' --install-extension bbenoist.nix
                code --user-data-dir='/tmp/' --install-extension ms-vscode.cpptools
            fi
        }
        install_vscode_extensions

    '';
}
