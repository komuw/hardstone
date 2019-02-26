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


GOLANG_VERSION=go1.12.linux-amd64
GOBIN_VERSION=v0.0.4 #https://github.com/myitcv/gobin

printf "\n\n  download golang\n"
wget -nc --directory-prefix=/usr/local "https://dl.google.com/go/$GOLANG_VERSION.tar.gz"
printf "\n\n  untar golang file\n"
tar -xzf "/usr/local/$GOLANG_VERSION.tar.gz" -C /usr/local/

printf "\n\n  golang profileI\n"
GOLANG_PROFILE_CONFIG_FILE_CONTENTS='#golang
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$HOME/go/bin:$PATH'
GOLANG_PROFILE_CONFIG_FILE=/etc/profile
grep -qF -- "$GOLANG_PROFILE_CONFIG_FILE_CONTENTS" "$GOLANG_PROFILE_CONFIG_FILE" || echo "$GOLANG_PROFILE_CONFIG_FILE_CONTENTS" >> "$GOLANG_PROFILE_CONFIG_FILE"

printf "\n\n  create golang code github dir\n"
mkdir -p $HOME/go/src/github.com/komuw

printf "\n\n change ownership of ~/go\n"
chown -R komuw:komuw $HOME/go
chown -R komuw:komuw $HOME/.cache/go-build

# gomacro repl. usage: rlwrap gomacro --collect --force-overwrite --repl --very-verbose
printf "\n\n go get some golang packages\n"
export GOPATH="$HOME/go" && \
export PATH=$PATH:/usr/local/go/bin && \
export PATH=$HOME/go/bin:$PATH
for i in neugram.io/ng \
github.com/motemen/gore \
github.com/yunabe/lgo/cmd/lgo \
github.com/yunabe/lgo/cmd/lgo-internal \
github.com/stamblerre/gocode \
github.com/k0kubun/pp \
golang.org/x/tools/cmd/godoc \
github.com/rs/zerolog \
github.com/pkg/errors \
github.com/alecthomas/gometalinter \
github.com/d4l3k/go-pry \
github.com/cosmos72/gomacro \
github.com/sourcegraph/go-langserver \
github.com/golang/dep/cmd/dep \
github.com/google/gops \
github.com/maruel/panicparse/cmd/pp \
github.com/sanity-io/litter \
github.com/ianthehat/godef \
github.com/golang/lint/golint \
github.com/lukehoban/go-outline \
sourcegraph.com/sqs/goreturns \
golang.org/x/tools/cmd/gorename \
github.com/uudashr/gopkgs/cmd/gopkgs \
github.com/newhook/go-symbols \
golang.org/x/tools/cmd/guru \
github.com/ramya-rao-a/go-outline \
github.com/google/pprof
do
    printf "\n\ngo getting $i \n"
    go get -u "$i"
    printf "DONE getting $i"
done                    

printf "\n\n  install some golang packages\n"
export GOPATH="$HOME/go" && \
export PATH=$PATH:/usr/local/go/bin && \
export PATH=$HOME/go/bin:$PATH && \
go install github.com/d4l3k/go-pry # debugger/repl

# TODO: move to using gobin to install go tools instead of go get -u
# gobin can then be used to install go bin packages, eg;
# gobin github.com/google/pprof
printf "\n\n install https://github.com/myitcv/gobin \n"
export GOPATH="$HOME/go" && \
export PATH=$PATH:/usr/local/go/bin && \
export PATH=$HOME/go/bin:$PATH
wget -nc --directory-prefix=/tmp https://github.com/myitcv/gobin/releases/download/$GOBIN_VERSION/linux-amd64
mv /tmp/linux-amd64 /usr/local/bin/gobin
chmod +x /usr/local/bin/gobin

printf "\n\n gobin install some golang packages\n"
export GOPATH="$HOME/go" && \
export PATH=$PATH:/usr/local/go/bin && \
export PATH=$HOME/go/bin:$PATH
gobin github.com/rogpeppe/gohack
gobin honnef.co/go/tools/cmd/staticcheck@2019.1
gobin github.com/go-delve/delve/cmd/dlv
