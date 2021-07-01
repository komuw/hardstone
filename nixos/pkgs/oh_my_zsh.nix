{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/21.05.tar.gz") {} }:

{
  inputs = [
      pkgs.zsh
      pkgs.oh-my-zsh

      ];
  hooks = ''
    printf "\n\n running hooks for oh_my_zsh.nix \n\n"

    MY_NAME=$(whoami)

    # To copy the Oh My Zsh configuration file to your home directory, run the following command:
    # see: https://search.nixos.org/packages?channel=21.05&show=oh-my-zsh&from=0&size=50&sort=relevance&query=oh+my

    cp -v $(nix-env -q --out-path oh-my-zsh | cut -d' ' -f3)/share/oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

    cp -v $(nix-env -q --out-path oh-my-zsh | cut -d' ' -f3)/share/oh-my-zsh/templates/zshrc.zsh-template /home/dembe/alas_zshrc

  '';
}


