{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/21.05.tar.gz") {} }:

{
  inputs = [
    pkgs.go
  ];

  hooks = ''
      # set -e # fail if any command fails
      # do not use `set -e` which causes commands to fail.
      # because it causes `nix-shell` to also exit if a command fails when running in the eventual shell

    printf "\n running hooks for golang.nix \n"

    MY_NAME=$(whoami)

    install_go_pkgs(){

        curlie_bin_file="/home/$MY_NAME/go/bin/curlie"
        if [ -f "$curlie_bin_file" ]; then
            # modules exists
            echo ""
        else
            go version
            go install github.com/rogpeppe/gohack@latest
            go install honnef.co/go/tools/cmd/staticcheck@latest
            go install github.com/go-delve/delve/cmd/dlv@latest
            go install golang.org/x/tools/gopls@latest
            go install golang.org/x/tools/cmd/godex@latest
            go install github.com/traefik/yaegi/cmd/yaegi@latest # yaegi repl. usage: rlwrap yaegi
            go install github.com/maruel/panicparse/v2/cmd/pp@latest
            go install github.com/securego/gosec/cmd/gosec@latest
            go install github.com/google/pprof@latest
            go install github.com/rs/curlie@latest
            go install github.com/tsenart/vegeta@latest
            go install mvdan.cc/gofumpt@latest
            go install golang.org/dl/gotip@latest
        fi
    }
    install_go_pkgs

    change_owner(){
        chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/go
        chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/.cache/
    }
    change_owner

  '';
}

