{ pkgs, lib, ... }:

let
  myShellHook = ''
    echo "Welcome to the media.nix shell!"
    export MEDIA_VAR="This is from media.nix"
  '';

  packages = {
    httpie = pkgs.httpie;
    hello = pkgs.hello;
  };

in
lib.mapAttrs (name: value: value.overrideAttrs (oldAttrs: {
  shellHook = (oldAttrs.shellHook or "") + myShellHook;
})) packages