{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/21.05.tar.gz") {} }:

{
  inputs = [
    pkgs.go
  ];

  hooks = ''
      # set -e # fail if any command fails
      # do not use `set -e` which causes commands to fail.
      # because it causes `nix-shell` to also exit if a command fails when running in the eventual shell

    printf "\n\n running hooks for golang.nix \n\n"

    MY_NAME=$(whoami)

    install_go_pkgs(){
        printf "\n\n go install some golang packages\n"
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
    }
    install_go_pkgs

    install_gotip(){
        printf "\n\n install gotip https://godoc.org/golang.org/dl/gotip \n"
        go install golang.org/dl/gotip@latest
    }
    install_gotip

    change_owner(){
        printf "\n\n change ownership of ~/go\n"
        go version
        chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/go
        chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/.cache/
    }
    change_owner

  '';
}
