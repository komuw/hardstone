{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/20.09.tar.gz") {} }:

/*
    docs:
    1. https://nixos.org/manual/nix/stable/#chap-writing-nix-expressions
    2. https://nixos.org/guides/declarative-and-reproducible-developer-environments.html#declarative-reproducible-envs

    usage:
    - from this directory, run;
        THE_USER=$(whoami)
        /nix/var/nix/profiles/per-user/$THE_USER/profile/bin/nix-shell
*/

pkgs.mkShell {
  buildInputs = [
    pkgs.which
    pkgs.htop
    pkgs.zlib
    pkgs.zsh
    pkgs.mpv
    pkgs.vlc
    pkgs.nano
    pkgs.micro
  ];
}



