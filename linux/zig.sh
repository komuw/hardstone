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


install_zig() {
    printf "\n\n remove any current zig files\n"
    sudo rm -rf /usr/local/zigDir && sudo mkdir -p /usr/local/zigDir && sudo chown -R komuw /usr/local/zigDir

    printf "\n\n  download zig from master branch(change when zig gets to ver1)\n"
    # TODO: parse content from https://ziglang.org/download/index.json
    LATEST_ZIG_MASTER=$(curl -s 'https://ziglang.org/download/index.json' | python3 -c "import sys, json; print(json.load(sys.stdin)['master']['x86_64-linux']['tarball'])")
    printf "\nLATEST_ZIG_MASTER is: $LATEST_ZIG_MASTER\n"

    wget -nc --output-document=/usr/local/zigDir/zig.tar.xz $LATEST_ZIG_MASTER
    printf "\n\n  untar zig file\n"
    tar -xf /usr/local/zigDir/zig.tar.xz -C /usr/local/zigDir --strip-components 1

    # todo: add zig to $PATH
    printf "\n\n use zig as: \n"
    printf "\t /usr/local/zigDir/zig fmt .; /usr/local/zigDir/zig run main.zig \n"

    # to install on Osx u can also use: brew install zig --HEAD
}

install_zig
