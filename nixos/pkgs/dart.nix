with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/2eb46d5c50448d30f3ac94c8fcb1f3c0f6732352.tar.gz") {});

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
