{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/21.05.tar.gz") {} }:

{
  inputs = [
      pkgs.dart
      pkgs.flutter
  ];

  hooks = ''
    printf "\n\n running hooks for dart.nix \n\n"

    MY_NAME=$(whoami)
  '';
}


