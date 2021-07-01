{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/21.05.tar.gz") {} }:

{
  inputs = [
      pkgs.gcc
      pkgs.curl 
      pkgs.wget 
      pkgs.git
      ];
  hooks = ''
      # set -e # fail if any command fails
      # do not use `set -e` which causes commands to fail.
      # because it causes `nix-shell` to also exit if a command fails when running in the eventual shell

    printf "\n\n running hooks for preRequiste.nix \n\n"

    CURL_CA_BUNDLE=$(find /nix -name ca-bundle.crt |tail -n 1)
    export CURL_CA_BUNDLE="$CURL_CA_BUNDLE"
  '';

  # https://nixos.org/guides/declarative-and-reproducible-developer-environments.html#declarative-reproducible-envs
  LC_ALL = "en_US.UTF-8";
  SOME_CUSTOM_ENV_VAR = "hello there";
}
