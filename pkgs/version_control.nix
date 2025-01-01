with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/7d9758079f4a14b4d397b0c4186d6168885586d4.tar.gz") {});

let

in stdenv.mkDerivation {
    name = "version_control";

    buildInputs = [];

    shellHook = ''
        # set -e # fail if any command fails
        # do not use `set -e` which causes commands to fail.
        # because it causes `nix-shell` to also exit if a command fails when running in the eventual shell

      printf "\n running hooks for version_control.nix \n"

      MY_NAME=$(whoami)

      # configure main gitconfig
      cp ./templates/version_control/main_git_config /home/$MY_NAME/.gitconfig

      # configure ~/mystuff/gitconfig
      cp  ./templates/version_control/personal_git_config /home/$MY_NAME/mystuff/.gitconfig

      # configure ~/personalWork/gitconfig
      cp ./templates/version_control/personal_work_git_config /home/$MY_NAME/personalWork/.gitconfig

      # configure ~/paidWork/gitconfig
      cp ./templates/version_control/paid_work_git_config /home/$MY_NAME/paidWork/.gitconfig

      # configure gitattributes
      cp ./templates/version_control/git_attributes_config /home/$MY_NAME/mystuff/.gitattributes

      # configure hgrc(mercurial)
      cp ./templates/version_control/hg_config /home/$MY_NAME/.hgrc

    '';
}
