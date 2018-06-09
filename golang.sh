#!/usr/bin/env bash

GOLANG_VERSION=go1.10.linux-amd64

printf "\n\n  download golang"
wget -nc --directory-prefix=/usr/local "https://dl.google.com/go/$GOLANG_VERSION.tar.gz"
printf "\n\n  untar golang file"
tar -xzf "/usr/local/$GOLANG_VERSION.tar.gz" -C /usr/local/

printf "\n\n  golang profileI"
GOLANG_PROFILE_CONFIG_FILE_CONTENTS='#golang
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$HOME/go/bin:$PATH'
GOLANG_PROFILE_CONFIG_FILE=/etc/profile
grep -qF -- "$GOLANG_PROFILE_CONFIG_FILE_CONTENTS" "$GOLANG_PROFILE_CONFIG_FILE" || echo "$GOLANG_PROFILE_CONFIG_FILE_CONTENTS" >> "$GOLANG_PROFILE_CONFIG_FILE"

printf "\n\n  create golang code github dir"
mkdir -p $HOME/go/src/github.com/komuw

printf "\n\n  source profile"
source /etc/profile

# gomacro repl. usage: rlwrap gomacro --collect --force-overwrite --repl --very-verbose
printf "\n\n go get some golang packages"
export GOPATH="$HOME/go" && source /etc/profile && go get -u neugram.io/ng \
                                                             github.com/motemen/gore \
                                                             github.com/yunabe/lgo/cmd/lgo \
                                                             github.com/yunabe/lgo/cmd/lgo-internal \
                                                             github.com/nsf/gocode \
                                                             github.com/k0kubun/pp \
                                                             golang.org/x/tools/cmd/godoc \
                                                             github.com/derekparker/delve/cmd/dlv \
                                                             github.com/rs/zerolog \
                                                             github.com/pkg/errors \
                                                             github.com/alecthomas/gometalinter \
                                                             github.com/d4l3k/go-pry \
                                                             github.com/cosmos72/gomacro \
                                                             github.com/sourcegraph/go-langserver \
                                                             github.com/golang/dep/cmd/dep \
                                                             github.com/google/gops \
                                                             github.com/sanity-io/litter \
                                                             github.com/rogpeppe/godef \
                                                             github.com/golang/lint/golint \
                                                             github.com/lukehoban/go-outline \
                                                             sourcegraph.com/sqs/goreturns \
                                                             golang.org/x/tools/cmd/gorename \
                                                             github.com/tpng/gopkgs \
                                                             github.com/newhook/go-symbols \
                                                             golang.org/x/tools/cmd/guru \
                                                             github.com/ramya-rao-a/go-outline       
                                                            

printf "\n\n  install some golang packages"
export GOPATH="$HOME/go" && source /etc/profile && go install github.com/d4l3k/go-pry # debugger/repl
 
printf "\n\n  install go linters"
export GOPATH="$HOME/go" && source /etc/profile && gometalinter --install
