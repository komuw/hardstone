with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/5167a4a283b4286e62ee8a95ffa0f69c88a9b8d3.tar.gz") {});

let

in stdenv.mkDerivation {
    name = "tools";

    buildInputs = [
        pkgs.youtube-dl
        pkgs.asciinema
        pkgs.httpie
        # https://docs.aws.amazon.com/cli/latest/userguide/cliv2-migration.html
        pkgs.awscli
        pkgs.awscli2
        pkgs.bat
        pkgs.google-chrome # unfree
        pkgs.skypeforlinux # unfree
        pkgs.ripgrep
        pkgs.ripgrep-all
        pkgs.rr
        pkgs.unixtools.netstat
        pkgs.fzf
        pkgs.delta # https://github.com/dandavison/delta

        # For some reason, zoom installed via nix is not working.
        # So we install it manually in `nixos/start.sh`.
        # TODO: remove this once we get zoom working on nix.
        # pkgs.zoom-us # unfree

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
