with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/7af93d2e5372b0a12b3eda16dbb8eaddd0fe2176.tar.gz") {});

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
