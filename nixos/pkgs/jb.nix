with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/21.05.tar.gz") {});

let

in stdenv.mkDerivation {
    name = "jb";

    buildInputs = [
        pkgs.virtualbox
        pkgs.qemu_kvm
        # When you install packages on non-NixOS distros, services/daemons(eg libvirtd) are not set up.
        # Services are created by NixOS modules, hence they require NixOS.
        # For other linuxes, you would need to integrate with systemd yourself(see func `add_libvirtd_systemd_files`).
        # Without systemd integration, `libvirtd` is not up and running by default.
        # https://stackoverflow.com/a/48973911/2768067
        pkgs.libvirt
        pkgs.docker-machine-kvm2
        pkgs.minikube
        pkgs.kubectl
        pkgs.jq
        # The mongo shell is included as part of the MongoDB server installation.
        # https://docs.mongodb.com/manual/reference/program/mongo/
        pkgs.mongodb
        pkgs.mongodb-tools
        pkgs.kubernetes-helm
    ];

    shellHook = ''
        # set -e # fail if any command fails
        # do not use `set -e` which causes commands to fail.
        # because it causes `nix-shell` to also exit if a command fails when running in the eventual shell

        printf "\n running hooks for jb.nix \n"

        MY_NAME=$(whoami)

        add_libvirtd_group(){
            # NB: You may need to restart the machine for some of this to kick in.
            # especially adding user to the group.

            my_groups=$(groups $MY_NAME)
            SUB='Linux'
            if [[ "$my_groups" == *"libvirt"* ]]; then
                # exists
                echo -n ""
            else
                sudo groupadd --force libvirt # --force causes to exit with success if group already exists
                sudo usermod -aG libvirt $MY_NAME
            fi
        }
        add_libvirtd_group

        add_libvirtd_systemd_files(){
            # https://github.com/snabbco/libvirt/blob/a4431931393aeb1ac5893f121151fa3df4fde612/daemon/libvirtd.socket.in
            # https://github.com/snabbco/libvirt/blob/a4431931393aeb1ac5893f121151fa3df4fde612/daemon/libvirtd.service.in
            # https://github.com/snabbco/libvirt/blob/a4431931393aeb1ac5893f121151fa3df4fde612/daemon/libvirtd.conf
            # https://libvirt.org/format.html


            # troubleshoot using:
            # - `journalctl -u libvirtd`
            # - `journalctl -n50 -u libvirtd`

            libvirtd_systemd_file="/etc/systemd/system/libvirtd.service"
            if [ -f "$libvirtd_systemd_file" ]; then
                # exists
                printf "\n\t OH NO \n"
                echo -n ""
            else
                printf "\n\t STrt \n"
                sudo systemctl stop libvirtd

                sudo mkdir -p /etc/libvirtd
                sudo chown -R root:libvirt /etc/libvirtd
                sudo cp ../templates/libvirtd_socket_file /etc/systemd/system/libvirtd.socket
                sudo cp ../templates/libvirtd_systemd_service_file /etc/systemd/system/libvirtd.service
                sudo cp ../templates/libvirtd_config_file /etc/libvirtd/libvirtd.conf
                sudo chown -R root:libvirt /etc/libvirtd/libvirtd.conf

                sudo chmod 0777 /etc/systemd/system/libvirtd.socket
                sudo chmod 0777 /etc/systemd/system/libvirtd.service
                sudo chown -R root:libvirt /etc/systemd/system/libvirtd.socket
                sudo chown -R root:libvirt /etc/systemd/system/libvirtd.service

                sudo systemctl daemon-reload
                sudo systemctl enable libvirtd.socket
                sudo systemctl enable libvirtd.service
                systemctl list-unit-files | grep enabled | grep -i libvirtd

                sudo systemctl start libvirtd

                # symlink to /var/run/libvirt/libvirt-sock
                # some libraries(eg minikube) expect that sock path.
                sudo chown -R root:libvirt /var/run/libvirt
                sudo ln --force --symbolic /run/libvirt.sock /var/run/libvirt/libvirt-sock
                sudo chown -R root:libvirt /var/run/libvirt/libvirt-sock

                # symlink to /usr/libexec/qemu-kvm
                # some libraries(eg minikube) expect that path.
                sudo ln --force --symbolic $(which qemu-kvm) /usr/libexec/qemu-kvm
                sudo chown -R root:libvirt /usr/libexec/qemu-kvm

                printf "\n\t GOT HERE \n"
            fi
      }
      add_libvirtd_systemd_files

    '';
}
