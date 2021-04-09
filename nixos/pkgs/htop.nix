{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/4795e7f3a9cebe277bb4b5920caa8f0a2c313eb0.tar.gz") {} }:

{
  inputs = [ 
      pkgs.htop
      ];
  hooks = ''
    echo "hello from htop.nix"
  '';
}
