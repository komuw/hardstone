{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/21.05.tar.gz") {} }:

{
  inputs = [
      pkgs.youtube-dl
      pkgs.docker-compose
      pkgs.asciinema
      pkgs.httpie
      # https://docs.aws.amazon.com/cli/latest/userguide/cliv2-migration.html
      pkgs.awscli
      pkgs.awscli2
      pkgs.bat
      pkgs.google-chrome # unfree
      pkgs.skypeforlinux # unfree
      pkgs.docker
      pkgs.ripgrep
      pkgs.ripgrep-all
      pkgs.rr
      pkgs.zoom-us # unfree

       # WE HAVENT FOUND THESE:
       # pip
       # sewer
  ];

  hooks = ''
    printf "\n\n running hooks for tools.nix \n\n"

    MY_NAME=$(whoami)
  '';
}


