{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/21.05.tar.gz") {} }:

{

# #   https://nixos.org/manual/nixpkgs/stable/#sec-allow-unfree
#   allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
#     "vscode"
#   ];

  inputs = [
      pkgs.vscode # unfree
  ];

  hooks = ''
      # set -e # fail if any command fails
      # do not use `set -e` which causes commands to fail.
      # because it causes `nix-shell` to also exit if a command fails when running in the eventual shell

    printf "\n\n running hooks for vscode.nix \n\n"

    MY_NAME=$(whoami)

    add_vscode_cofig(){
        # on MacOs it is /Users/$MY_NAME/Library/Application\ Support/Code/User/settings.json

        # configure vscode user settings file
        mkdir -p /home/$MY_NAME/.config/Code/User
        mkdir -p /home/$MY_NAME/.vscode
        touch /home/$MY_NAME/.config/Code/User/settings.json
        chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/.config/Code/
        chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/.vscode
        cp ../templates/vscode.j2 /home/$MY_NAME/.config/Code/User/settings.json
    }
    add_vscode_cofig

    install_vscode_extensions(){
        # install vscode extensions

        installed_extensions=$(code --list-extensions)
        if [[ "$installed_extensions" == *"hashicorp.terraform"* ]]; then
            # extensions already installed
            echo ""
        else
            code --user-data-dir='.' --install-extension ms-python.python
            code --user-data-dir='.' --install-extension ms-python.vscode-pylance
            code --user-data-dir='.' --install-extension dart-code.dart-code
            code --user-data-dir='.' --install-extension dart-code.flutter
            code --user-data-dir='.' --install-extension donaldtone.auto-open-markdown-preview-single
            code --user-data-dir='.' --install-extension golang.go
            code --user-data-dir='.' --install-extension ms-azuretools.vscode-docker
            code --user-data-dir='.' --install-extension hashicorp.terraform
            # code --user-data-dir='.' --install-extension ms-vscode.cpptools
        fi
    }
    install_vscode_extensions

  '';
}


