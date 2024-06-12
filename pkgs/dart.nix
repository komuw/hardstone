with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/437e3a21de2d2e1e4c3f556edf968d212f454c7f.tar.gz") {});

let

in stdenv.mkDerivation {
    name = "dart";

    buildInputs = [
        pkgs.dart
        pkgs.flutter
    ];

    shellHook = ''
        # set -e # fail if any command fails
        # do not use `set -e` which causes commands to fail.
        # because it causes `nix-shell` to also exit if a command fails when running in the eventual shell

      printf "\n running hooks for dart.nix \n"

      MY_NAME=$(whoami)
    '';
}
