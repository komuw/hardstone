with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/21.05.tar.gz") {});

let

in stdenv.mkDerivation {
    name = "tools";

    buildInputs = [
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

    shellHook = ''
        # set -e # fail if any command fails
        # do not use `set -e` which causes commands to fail.
        # because it causes `nix-shell` to also exit if a command fails when running in the eventual shell

      printf "\n running hooks for tools.nix \n"

      MY_NAME=$(whoami)
    '';
}
