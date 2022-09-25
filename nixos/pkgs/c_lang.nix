with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/397da86480b14f176181e245a49d13bb16d58a29.tar.gz") {});

let

in stdenv.mkDerivation {
    name = "c_lang";

    buildInputs = [
        pkgs.gcc
        pkgs.clang_13
        pkgs.valgrind
        pkgs.gdb
    ];

    shellHook = ''
        # set -e # fail if any command fails
        # do not use `set -e` which causes commands to fail.
        # because it causes `nix-shell` to also exit if a command fails when running in the eventual shell

      printf "\n running hooks for c_lang.nix \n"

      MY_NAME=$(whoami)
    '';
}
