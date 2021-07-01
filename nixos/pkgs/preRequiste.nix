{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/21.05.tar.gz") {} }:

{
  inputs = [
      pkgs.gcc
      pkgs.curl 
      pkgs.wget 
      pkgs.git
      ];
  hooks = ''
    printf "\n\n running hooks for preRequiste.nix \n\n"

    CURL_CA_BUNDLE=$(find /nix -name ca-bundle.crt |tail -n 1)

    export CURL_CA_BUNDLE="$CURL_CA_BUNDLE"
    export LC_ALL="en_US.UTF-8"
    export SOME_CUSTOM_ENV_VAR="hello there"
  '';
}
