with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/21.05.tar.gz") {});

let

in stdenv.mkDerivation {
    name = "jb";

    buildInputs = [
        pkgs.virtualbox
        pkgs.libvirt
        pkgs.minikube
        pkgs.kubectl
        pkgs.jq
        # The mongo shell is included as part of the MongoDB server installation.
        # https://docs.mongodb.com/manual/reference/program/mongo/
        pkgs.mongodb
        pkgs.mongodb-tools
        pkgs.kubernetes-helm
    ];

    shellHook = ''
        # set -e # fail if any command fails
        # do not use `set -e` which causes commands to fail.
        # because it causes `nix-shell` to also exit if a command fails when running in the eventual shell

        printf "\n running hooks for jb.nix \n"

        MY_NAME=$(whoami)

        add_to_group(){
            # NB: You may need to restart the machine for some of this to kick in.
            # especially adding user to the group.

            my_groups=$(groups $MY_NAME)
            SUB='Linux'
            if [[ "$my_groups" == *"libvirt"* ]]; then
                # exists
                echo -n ""
            else
                sudo groupadd --force libvirt # --force causes to exit with success if group already exists
                sudo usermod -aG libvirt $MY_NAME
            fi
        }
        add_to_group

    '';
}
