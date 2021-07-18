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
        pkgs.dnsmasq
        pkgs.bridge-utils
        pkgs.iptables
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

                # https://github.com/kubernetes/minikube/issues/927#issuecomment-407274870
                sudo groupadd --force libvirtd
                sudo usermod -aG libvirtd $MY_NAME
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
                sudo cp ../templates/libvirtd.conf /etc/libvirtd/libvirtd.conf
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

      symlink_docker_mach_driver(){
          # by default, minikube downloads it's own binary of `docker-machine-driver-kvm2`
          # and saves it in `$HOME/.minikube/bin/`. this download happens when you do `minikube --profile=ara start`
          # however, that binary fails to run. try and run
          # `$HOME/.minikube/bin/docker-machine-driver-kvm2 version` to see the errors.
          #     `error while loading shared libraries: libvirt-qemu.so.0`
          # see: https://github.com/kubernetes/minikube/issues/6023#issuecomment-567274494
          # instead, what we can do is symlink the one installed by nix.

          this_file=$(stat $HOME/.minikube/bin/docker-machine-driver-kvm2)
          if [[ "$this_file" == *"/nix/store"* ]]; then
              # the file has already been symlinked.
              echo -n ""
          else
              ln --force --symbolic $(which docker-machine-driver-kvm2) $HOME/.minikube/bin/docker-machine-driver-kvm2
          fi
      }
      symlink_docker_mach_driver

      start_libvirt_default_network(){
          # https://wiki.debian.org/KVM#Installation
          # If you use libvirt to manage your VMs, libvirt provides a NATed bridged network named `default`
          # that allows the host to communicate with the guests.
          # This network is available only for the system domains (that is VMs created by root or using the qemu:///system connection URI)
          # This network is not automatically started

          # we need to start the default network.
          # see; https://wiki.libvirt.org/page/Networking

          # TODO: do this conditionally based on whether `virsh net-list --all` has the string `default` in it.
          # also if present, its state should be `active`

          export LIBVIRT_DEFAULT_URI='qemu:///system'
          the_default_network_file=$(find /nix -name "default.xml" | grep -i networks | grep -v autostart)
          virsh net-define $the_default_network_file
          virsh net-list --all
          virsh --connect qemu:///system net-list --all
          virsh net-autostart default
          virsh net-start default
      }
      start_libvirt_default_network

    '';
}
