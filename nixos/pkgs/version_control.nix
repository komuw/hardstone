with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/10c2b21c3f8dea83cfa4304109eac00d00be707e.tar.gz") {});

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
      cp ../templates/main_git_config /home/$MY_NAME/.gitconfig

      # configure ~/mystuff/gitconfig
      cp  ../templates/personal_git_config /home/$MY_NAME/mystuff/.gitconfig

      # configure ~/personalWork/gitconfig
      cp ../templates/personal_work_git_config /home/$MY_NAME/personalWork/.gitconfig

      # configure ~/paidWork/gitconfig
      cp ../templates/paid_work_git_config /home/$MY_NAME/paidWork/.gitconfig

      # configure gitattributes
      cp ../templates/git_attributes_config /home/$MY_NAME/mystuff/.gitattributes

      # configure hgrc(mercurial)
      cp ../templates/hg_config /home/$MY_NAME/.hgrc

    '';
}
