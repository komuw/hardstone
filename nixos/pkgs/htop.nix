{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/21.05.tar.gz") {} }:

{
  inputs = [ 
      pkgs.htop
      ];
  hooks = ''
    echo "hello from htop.nix"
  '';
}
