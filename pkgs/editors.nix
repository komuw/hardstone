with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/79ad88f2565df1a4e4d8fdbca7a8b4d35e80876f.tar.gz") {});

let

in stdenv.mkDerivation {
    name = "editors";

    buildInputs = [
        pkgs.vscode # unfree
        pkgs.vscodium # free vscode
        # pkgs.sublime4 # does not work
    ];

    shellHook = ''
        # set -e # fail if any command fails
        # do not use `set -e` which causes commands to fail.
        # because it causes `nix-shell` to also exit if a command fails when running in the eventual shell

        printf "\n running hooks for editors.nix \n"

        MY_NAME=$(whoami)

        add_vscode_cofig(){
            # on MacOs it is /Users/$MY_NAME/Library/Application\ Support/Code/User/settings.json

            # configure vscode user settings file
            mkdir -p /home/$MY_NAME/.config/Code/User
            mkdir -p /home/$MY_NAME/.vscode
            touch /home/$MY_NAME/.config/Code/User/settings.json
            chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/.config/Code/
            chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/.vscode
            cp ./templates/editors/vscode_settings.json /home/$MY_NAME/.config/Code/User/settings.json
        }
        add_vscode_cofig

        install_vscode_extensions(){
            # install vscode extensions

            installed_extensions=$(code --list-extensions)
            if [[ "$installed_extensions" == *"golang.go"* ]]; then
                # extensions already installed
                echo -n ""
            else
                code --user-data-dir='/tmp/' --install-extension golang.go
                code --user-data-dir='/tmp/' --install-extension ms-python.python
                code --user-data-dir='/tmp/' --install-extension dart-code.dart-code
                code --user-data-dir='/tmp/' --install-extension dart-code.flutter
                code --user-data-dir='/tmp/' --install-extension ms-azuretools.vscode-docker
                code --user-data-dir='/tmp/' --install-extension hashicorp.terraform
                code --user-data-dir='/tmp/' --install-extension bbenoist.nix
                code --user-data-dir='/tmp/' --install-extension ms-vscode.cpptools
                # code --user-data-dir='/tmp/' --install-extension donaldtone.auto-open-markdown-preview-single
            fi
        }
        install_vscode_extensions

       install_sublime_text(){
           # Configuring sublime text for golang;
           # https://github.com/golang/tools/blob/master/gopls/doc/subl.md
           # https://agniva.me/gopls/2021/01/02/setting-up-gopls-sublime.html
           #
           sublime_bin_file="/usr/bin/subl"
           if [ -f "$sublime_bin_file" ]; then
               # bin file exists
               echo -n ""
           else
               wget -nc --output-document=/tmp/sublime_text_amd64.deb "https://download.sublimetext.com/sublime-text_build-4192_amd64.deb"
               sudo dpkg -i /tmp/sublime_text_amd64.deb
               cp ./templates/editors/Preferences.sublime-settings /home/$MY_NAME/.config/sublime-text/Packages/User/Preferences.sublime-settings
           fi
       }
       install_sublime_text

       setup_vscodium(){
            cp ./templates/editors/vscode_settings.json /home/$MY_NAME/.config/VSCodium/User/settings.json

            installed_extensions=$(codium --list-extensions)
            if [[ "$installed_extensions" == *"golang.go"* ]]; then
                # extensions already installed
                echo -n ""
            else
                # Install vscode extensions
                # From: https://open-vsx.org/
                #
                # codium --update-extensions
                #
                codium --user-data-dir='/tmp/' --install-extension golang.go
                codium --user-data-dir='/tmp/' --install-extension ms-python.python
                codium --user-data-dir='/tmp/' --install-extension dart-code.dart-code
                codium --user-data-dir='/tmp/' --install-extension dart-code.flutter
                codium --user-data-dir='/tmp/' --install-extension ms-azuretools.vscode-docker
                codium --user-data-dir='/tmp/' --install-extension hashicorp.terraform
                codium --user-data-dir='/tmp/' --install-extension bbenoist.nix
                # codium --user-data-dir='/tmp/' --install-extension ms-vscode.cpptools

                codium --list-extensions
            fi
       }
       setup_vscodium

    '';
}
