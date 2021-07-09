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

      add_systemd_files(){
          # https://docs.docker.com/engine/install/linux-postinstall/#configure-docker-to-start-on-boot
          # https://docs.docker.com/config/daemon/systemd/#manually-create-the-systemd-unit-files
          # https://github.com/moby/moby/blob/v20.10.7/contrib/init/systemd/docker.socket
          # https://github.com/moby/moby/blob/v20.10.7/contrib/init/systemd/docker.service

          # troubleshoot using:
          # - `journalctl -u docker`
          # - `journalctl -n50 -u docker`

          # NB: You may need to restart the machine for some of this to kick in.
          # especially adding user to the docker group.

          sudo systemctl stop docker

          sudo rm -rf /var/lib/docker
          sudo rm -rf /home/$MY_NAME/.docker
          sudo rm -rf /etc/docker

          sudo cp ../templates/docker_systemd_socket_file /etc/systemd/system/docker.socket
          sudo cp ../templates/docker_systemd_service_file /etc/systemd/system/docker.service

          sudo chmod 0777 /etc/systemd/system/docker.socket
          sudo chmod 0777 /etc/systemd/system/docker.service
          sudo chown -R root:docker /etc/systemd/system/docker.socket
          sudo chown -R root:docker /etc/systemd/system/docker.service

          sudo groupadd --force docker
          sudo usermod -aG docker $MY_NAME

          mkdir -p /home/$MY_NAME/.docker
          sudo chown -R $MY_NAME:docker /home/$MY_NAME/.docker
          chmod -R 775 /home/$MY_NAME/.docker

          sudo mkdir -p /etc/docker
          sudo chown -R $MY_NAME:docker /etc/docker
          cp ../templates/docker_daemon_config.json /etc/docker/daemon.json

          sudo systemctl daemon-reload
          sudo systemctl enable docker.socket
          sudo systemctl enable docker.service
          systemctl list-unit-files | grep enabled | grep -i docker

          sudo systemctl start docker # this will start docker.service
      }
      add_systemd_files

    '';
}
