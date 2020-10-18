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

printf "\n\n remove any current zig files\n"
rm -rf /usr/local/zig /usr/local/zig.*

printf "\n\n  download zig from master branch(change when zig gets to ver1)\n"
# TODO: parse content from https://ziglang.org/download/index.json
wget -nc --output-document=/usr/local/zig.tar.xz https://ziglang.org/builds/zig-linux-x86_64-0.6.0+b0684bf08.tar.xz
printf "\n\n  untar zig file\n"
mkdir -p /usr/local/zig && tar -xf /usr/local/zig.tar.xz -C /usr/local/zig --strip-components 1

# todo: add zig to $PATH
printf "\n\n use zig as: \n"
printf "\t /usr/local/zig/zig build-exe hel.zig \n"

# to install on Osx: brew install zig --HEAD
