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

        # When you install packages on non-NixOS distros, services/daemons(eg docker) are not set up.
        # Services are created by NixOS modules, hence they require NixOS.
        # For other linuxes, you would need to integrate with systemd yourself.
        # Without systemd integration, `docker version` works but `docker ps` doesn't because it needs dockerd to be running.
        # https://stackoverflow.com/a/48973911/2768067
        pkgs.docker

        pkgs.ripgrep
        pkgs.ripgrep-all
        pkgs.rr

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
