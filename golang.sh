#!/usr/bin/env bash

GOLANG_VERSION=go1.10.linux-amd64

printf "\n\n  download golang"
sudo wget -nc --directory-prefix=/usr/local "https://dl.google.com/go/$GOLANG_VERSION.tar.gz"
printf "\n\n  untar golang file"
sudo tar -xzf "/usr/local/$GOLANG_VERSION.tar.gz" -C /usr/local/

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

printf "\n\n go get some golang packages"
export GOPATH="$HOME/go" && source /etc/profile && go get -u neugram.io/ng                           # golang repl and shell language
                                                            \ github.com/motemen/gore                 # golang repl
                                                            \ github.com/yunabe/lgo/cmd/lgo           # golang repl and jupyter notebook integration
                                                            \ github.com/yunabe/lgo/cmd/lgo-internal
                                                            \ github.com/nsf/gocode                   # golang auto-completion
                                                            \ github.com/k0kubun/pp                   # pretty print
                                                            \ golang.org/x/tools/cmd/godoc            # docs
                                                            \ github.com/derekparker/delve/cmd/dlv    # debugger
                                                            \ github.com/rs/zerolog                   # zero allocation logger
                                                            \ github.com/pkg/errors                   # nice error handling
                                                            \ github.com/alecthomas/gometalinter      # linter of linters
                                                            \ github.com/d4l3k/go-pry                 # debugger/repl
                                                            \ github.com/cosmos72/gomacro             # repl. usage: rlwrap gomacro --collect --force-overwrite --repl --very-verbose
                                                            \ github.com/sourcegraph/go-langserver    # vscode stuff
                                                            \ github.com/golang/dep/cmd/dep           # dependency mgmnt
                                                            \ github.com/google/gops                  # ps for golang apps
                                                            \ github.com/sanity-io/litter             # pretty print
                                                            \ github.com/rogpeppe/godef               # vscode stuff
                                                            \ github.com/golang/lint/golint           # vscode stuff
                                                            \ github.com/lukehoban/go-outline         # vscode stuff
                                                            \ sourcegraph.com/sqs/goreturns           # vscode stuff
                                                            \ golang.org/x/tools/cmd/gorename         # vscode stuff
                                                            \ github.com/tpng/gopkgs                  # vscode stuff
                                                            \ github.com/newhook/go-symbols           # vscode stuff
                                                            \ golang.org/x/tools/cmd/guru             # vscode stuff
                                                            \ github.com/ramya-rao-a/go-outline       # vscode stuff
                                                            

printf "\n\n  install some golang packages"
export GOPATH="$HOME/go" && source /etc/profile && go install github.com/d4l3k/go-pry # debugger/repl
 
printf "\n\n  install go linters"
export GOPATH="$HOME/go" && source /etc/profile && gometalinter --install
