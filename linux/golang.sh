#!/usr/bin/env bash
if test "$BASH" = "" || "$BASH" -uc "a=();true \"\${a[@]}\"" 2>/dev/null; then
    # Bash 4.4, Zsh
    set -euo pipefail
else
    # Bash 4.3 and older chokes on empty arrays with set -u.
    set -eo pipefail
fi
shopt -s nullglob globstar
export DEBIAN_FRONTEND=noninteractive

MY_NAME=$(whoami)
GOLANG_VERSION=go1.16.linux-amd64

printf "\n\n  download golang\n"
sudo rm -rf "/usr/local/$GOLANG_VERSION.tar.gz"
sudo rm -rf /usr/local/go
sudo wget -nc --output-document="/usr/local/$GOLANG_VERSION.tar.gz" "https://dl.google.com/go/$GOLANG_VERSION.tar.gz"
printf "\n\n  untar golang file\n"
sudo tar -xzf "/usr/local/$GOLANG_VERSION.tar.gz" -C /usr/local/

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

printf "\n\n install gotip https://godoc.org/golang.org/dl/gotip \n"
/usr/local/go/bin/go install golang.org/dl/gotip@latest
# /home/$MY_NAME/go/bin/gotip download

printf "\n\n change ownership of ~/go\n"
/usr/local/go/bin/go version
chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/go
chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/.cache/
