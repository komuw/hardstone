{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/21.05.tar.gz") {} }:

{
  inputs = [
      pkgs.zsh
      ];
  hooks = ''
    printf "\n\n running hooks for oh_my_zsh.nix \n\n"

    MY_NAME=$(whoami)

    install_ohmyzsh(){
        printf "\n\n Install ohmyzsh \n"

        rm -rf /home/$MY_NAME/.oh-my-zsh
        git clone https://github.com/robbyrussell/oh-my-zsh.git /home/$MY_NAME/.oh-my-zsh

        git clone https://github.com/zsh-users/zsh-autosuggestions /home/$MY_NAME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
        git clone https://github.com/zsh-users/zsh-completions /home/$MY_NAME/.oh-my-zsh/custom/plugins/zsh-completions

        cp ../templates/zshrc.j2 /home/$MY_NAME/.zshrc
        cp ../templates/zshrc.j2 ~/.zshrc

        chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/.zshrc
        chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/.oh-my-zsh

        printf "\n\n  activate zsh shell\n"
        chsh -s $(which zsh)
    }
    install_ohmyzsh

  '';
}



