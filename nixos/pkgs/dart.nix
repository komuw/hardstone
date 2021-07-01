# { pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/21.05.tar.gz") {} }:

# {
#   inputs = [
#       pkgs.dart
#       pkgs.flutter
#   ];

#   hooks = ''
      # set -e # fail if any command fails
      # do not use `set -e` which causes commands to fail.
      # because it causes `nix-shell` to also exit if a command fails when running in the eventual shell

#     printf "\n\n running hooks for dart.nix \n\n"

#     MY_NAME=$(whoami)
#   '';
# }




# with import <nixpkgs> {};

# let
#   py = pkgs.python;
#   dart = pkgs.dart;
# in
# stdenv.mkDerivation rec {
#   name = "python-environment";

#   buildInputs = [
#     py
#     dart
#   ];

#   shellHook = ''
#     echo "using python: ${python.name}"
#   ''

#   installPhase = ''
#     mkdir -p $out/bin
#     ${pkgs.unzip}/bin/unzip $src -d $out/bin
#     chmod +x $out/bin/consul
#   ''

with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "node-environment";
  
  buildInputs = [
    pkgs.nodejs-12_x
  ];
}

# nix-env -f pkgs/dart.nix -i
