{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/21.05.tar.gz") {} }:

{
  inputs = [
      pkgs.gcc
      pkgs.curl 
      pkgs.wget 
      pkgs.git
      ];
  hooks = ''
    echo "hello from preRequiste.nix"
    export LC_ALL="en_US.UTF-8"
    export SOME_CUSTOM_ENV_VAR="hello there"
  '';
}
