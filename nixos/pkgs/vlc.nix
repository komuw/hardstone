{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/4795e7f3a9cebe277bb4b5920caa8f0a2c313eb0.tar.gz") {} }:

{
  inputs = [ 
      pkgs.mpv
      pkgs.vlc
      ];
  hooks = ''
    echo "hello from vlc.nix"
  '';
}
