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


GOLANG_VERSION=go1.13.linux-amd64

printf "\n\n  download golang\n"
wget -nc --directory-prefix=/usr/local "https://dl.google.com/go/$GOLANG_VERSION.tar.gz"
printf "\n\n  untar golang file\n"
tar -xzf "/usr/local/$GOLANG_VERSION.tar.gz" -C /usr/local/

printf "\n\n  golang profileI\n"
GOLANG_PROFILE_CONFIG_FILE_CONTENTS="#golang
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$HOME/go/bin:$PATH"
GOLANG_PROFILE_CONFIG_FILE=/etc/profile
grep -qF -- "$GOLANG_PROFILE_CONFIG_FILE_CONTENTS" "$GOLANG_PROFILE_CONFIG_FILE" || echo "$GOLANG_PROFILE_CONFIG_FILE_CONTENTS" >> "$GOLANG_PROFILE_CONFIG_FILE"

printf "\n\n install https://github.com/myitcv/gobin \n"
export GOPATH="$HOME/go" && \
export PATH=$PATH:/usr/local/go/bin && \
export PATH=$HOME/go/bin:$PATH
go get -u github.com/myitcv/gobin

printf "\n\n gobin install some golang packages\n"
export GOPATH="$HOME/go" && \
export PATH=$PATH:/usr/local/go/bin && \
export PATH=$HOME/go/bin:$PATH
gobin -u github.com/rogpeppe/gohack
gobin -u honnef.co/go/tools/cmd/staticcheck@2019.2.3
gobin -u github.com/go-delve/delve/cmd/dlv
gobin -u golang.org/x/tools/cmd/gopls
gobin -u github.com/containous/yaegi/cmd/yaegi # yaegi repl. usage: rlwrap yaegi
gobin -u github.com/maruel/panicparse/cmd/pp
gobin -u github.com/google/pprof
gobin -u github.com/rs/curlie

printf "\n\n install gotip https://godoc.org/golang.org/dl/gotip \n"
go get golang.org/dl/gotip
gotip download

printf "\n\n change ownership of ~/go\n"
go version
chown -R komuw:komuw $HOME/go
chown -R komuw:komuw $HOME/.cache/go-build
