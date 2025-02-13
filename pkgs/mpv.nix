{ pkgs, lib, ... }:

let
  myShellHook = ''
    echo "Welcome to the mpv.nix shell!"
    export MPV_VAR="This is from mpv.nix"
  '';

  packages = {
    fzf = pkgs.fzf;
    bat = pkgs.bat;
  };

in
lib.mapAttrs (name: value: value.overrideAttrs (oldAttrs: {
  shellHook = (oldAttrs.shellHook or "") + myShellHook;
})) packages