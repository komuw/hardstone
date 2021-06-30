{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/21.05.tar.gz") {} }:

{
  inputs = [ 
      pkgs.mpv
      pkgs.vlc
      ];
  hooks = ''
    echo "hello from vlc.nix"
  '';
}
