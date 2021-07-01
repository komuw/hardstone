{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/21.05.tar.gz") {} }:

{
  inputs = [];
  hooks = ''
      # set -e # fail if any command fails
      # do not use `set -e` which causes commands to fail.
      # because it causes `nix-shell` to also exit if a command fails when running in the eventual shell

    printf "\n\n running hooks for auto.nix \n\n"

    MY_NAME=$(whoami)

    create_auto_dir(){
        rm -rf /home/$MY_NAME/.myNixFiles
        mkdir -p /home/$MY_NAME/.myNixFiles
        cp -r pkgs/ /home/$MY_NAME/.myNixFiles/
    }
    create_auto_dir

    setup_bashrc(){
        # there ought to be NO newlines in the content
        BASHRC_FILE_FILE_CONTENTS='

        # auto setup nix-shell
        export NIXPKGS_ALLOW_UNFREE=1 # for vscode
        nix-shell /home/$MY_NAME/.myNixFiles/pkgs/'

        BASHRC_FILE=/home/$MY_NAME/.bashrc
        touch "$BASHRC_FILE"
        grep -qxF "$BASHRC_FILE_FILE_CONTENTS" "$BASHRC_FILE" || echo "$BASHRC_FILE_FILE_CONTENTS" >> "$BASHRC_FILE"
    }
    setup_bashrc
  '';
}

