{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/21.05.tar.gz") {} }:

{
  inputs = [];

  hooks = ''
    printf "\n\n running hooks for golang.nix \n\n"

    MY_NAME=$(whoami)

    GOLANG_VERSION=go1.16.linux-amd64;

    install_golang(){
        printf "\n\n  install golang\n"

        GOLANG_FILE=/usr/local/go/bin/go
        if [ -f "$GOLANG_FILE" ]; then
            # GOLANG_FILE exists
            echo ""
        else
            sudo rm -rf "/usr/local/$GOLANG_VERSION.tar.gz"
            sudo rm -rf /usr/local/go
            sudo wget -nc --output-document="/usr/local/$GOLANG_VERSION.tar.gz" "https://dl.google.com/go/$GOLANG_VERSION.tar.gz"
            printf "\n\n  untar golang file\n"
            sudo tar -xzf "/usr/local/$GOLANG_VERSION.tar.gz" -C /usr/local/
        fi
    }
    install_golang

    install_go_pkgs(){
        printf "\n\n go install some golang packages\n"
        /usr/local/go/bin/go install github.com/rogpeppe/gohack@latest
        /usr/local/go/bin/go install honnef.co/go/tools/cmd/staticcheck@latest
        /usr/local/go/bin/go install github.com/go-delve/delve/cmd/dlv@latest
        /usr/local/go/bin/go install golang.org/x/tools/gopls@latest
        /usr/local/go/bin/go install golang.org/x/tools/cmd/godex@latest
        /usr/local/go/bin/go install github.com/traefik/yaegi/cmd/yaegi@latest # yaegi repl. usage: rlwrap yaegi
        /usr/local/go/bin/go install github.com/maruel/panicparse/v2/cmd/pp@latest
        /usr/local/go/bin/go install github.com/securego/gosec/cmd/gosec@latest
        /usr/local/go/bin/go install github.com/google/pprof@latest
        /usr/local/go/bin/go install github.com/rs/curlie@latest
        /usr/local/go/bin/go install github.com/tsenart/vegeta@latest
        /usr/local/go/bin/go install mvdan.cc/gofumpt@latest
    }
    install_go_pkgs

    install_gotip(){
        printf "\n\n install gotip https://godoc.org/golang.org/dl/gotip \n"
        /usr/local/go/bin/go install golang.org/dl/gotip@latest
    }
    install_gotip

    change_owner(){
        printf "\n\n change ownership of ~/go\n"
        /usr/local/go/bin/go version
        chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/go
        chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/.cache/
    }
    change_owner

  '';
}
