{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/21.05.tar.gz") {} }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    plugins = [
      git
    ];
  };

  hooks = ''
    printf "\n\n running hooks for oh_my_zsh.nix \n\n"
    MY_NAME=$(whoami)

  '';
}