with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/52842021e32b0ebd315a90a0ab9250dea759d653.tar.gz") {});

let

in stdenv.mkDerivation {
    name = "docker";

    buildInputs = [
        # When you install packages on non-NixOS distros, services/daemons(eg docker) are not set up.
        # Services are created by NixOS modules, hence they require NixOS.
        # For other linuxes, you would need to integrate with systemd yourself.
        # Without systemd integration, `docker version` works but `docker ps` doesn't because it needs dockerd to be running.
        # https://stackoverflow.com/a/48973911/2768067
        pkgs.docker
        pkgs.docker-compose
    ];

    shellHook = ''
        # set -e # fail if any command fails
        # do not use `set -e` which causes commands to fail.
        # because it causes `nix-shell` to also exit if a command fails when running in the eventual shell

      printf "\n running hooks for docker.nix \n"

      MY_NAME=$(whoami)
    '';
}
