with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/b56d7a70a7158f81d964a55cfeb78848a067cc7d.tar.gz") {});

let

in stdenv.mkDerivation {
    name = "c_lang";

    buildInputs = [
        pkgs.gcc
        pkgs.clang_12
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
