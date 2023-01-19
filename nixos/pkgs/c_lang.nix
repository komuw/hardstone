with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/d7021b0c4d62f4792ebfffb07f76b49b51595eda.tar.gz") {});

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
