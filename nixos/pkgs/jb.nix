with {
  # Using multiple channels in a shell.nix file.
  # https://devpress.csdn.net/k8s/62f4ea85c6770329307fa981.html
  # https://nixos.org/guides/nix-pills/fundamentals-of-stdenv.html#idm140737319505936
  normalImport =  (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/9eade54db008c4a1eccee60c9080d00d47932918.tar.gz") {});
  
  # We need some specific versions of helm, kind, skaffold.
  #
  # skaffold: v2.0.3
  # see: https://lazamar.co.uk/nix-versions
  # see: https://lazamar.co.uk/nix-versions/?package=skaffold&version=2.0.3&fullName=skaffold-2.0.3&keyName=skaffold&revision=79b3d4bcae8c7007c9fd51c279a8a67acfa73a2a&channel=nixpkgs-unstable#instructions
  skaffoldImport = (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/79b3d4bcae8c7007c9fd51c279a8a67acfa73a2a.tar.gz") {});
  # helm version: v3.10.2
  helmImport = (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/b3a285628a6928f62cdf4d09f4e656f7ecbbcafb.tar.gz") {});
  # kind: v0.17.0 
  kindImport = (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/8ad5e8132c5dcf977e308e7bf5517cc6cc0bf7d8.tar.gz") {});
  # kubectl: v1.25.4
  kubectlImport = (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/b3a285628a6928f62cdf4d09f4e656f7ecbbcafb.tar.gz") {});
  # nodejs: v18.x
  nodeimport = (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/8ad5e8132c5dcf977e308e7bf5517cc6cc0bf7d8.tar.gz") {});
};
with import <nixpkgs> {};
let
in stdenv.mkDerivation {

    buildInputs = [
        normalImport.jq
        normalImport.mongodb-tools
        normalImport.bridge-utils
        normalImport.iptables
        # normalImport.jetbrains.goland
        normalImport.yarn
        normalImport.direnv

        # The following commented-out code is for minikube usage.
        # I'm not using minikube at the moment(I'm using skaffold/kind)
        #
        # normalImport.virtualbox
        # normalImport.qemu_kvm
        # normalImport.libvirt
        # normalImport.docker-machine-kvm2
        # normalImport.minikube
        # normalImport.mongodb
        #
        # When you install packages on non-NixOS distros, services/daemons(eg libvirtd) are not set up.
        # Services are created by NixOS modules, hence they require NixOS.
        # For other linuxes, you would need to integrate with systemd yourself(see func `add_libvirtd_systemd_files`).
        # Without systemd integration, `libvirtd` is not up and running by default.
        # https://stackoverflow.com/a/48973911/2768067

        skaffoldImport.skaffold
        helmImport.kubernetes-helm-wrapped
        kindImport.kind
        kubectlImport.kubectl-convert
        nodeimport.nodejs-18_x # will also install npm
    ];

    shellHook = ''
        # set -e # fail if any command fails
        # do not use `set -e` which causes commands to fail.
        # because it causes `nix-shell` to also exit if a command fails when running in the eventual shell

        printf "\n running hooks for jb.nix \n"

        MY_NAME=$(whoami)

        install_mongo_shell(){
            # https://docs.mongodb.com/manual/reference/program/mongo/
            #  The version of mongodb available in nixpkgs is older than the version we need. So we'll install manually.

            is_installed=$(dpkg --get-selections | grep -v deinstall | grep mongodb)
            if [[ "$is_installed" == *"mongodb-org-shell"* ]]; then
                # already installed
                echo -n ""
            else
                # the binary is installed with name `mongo`
                # we download an ubuntu18.04 since 21.04 isn't available from download page.
                wget -nc --output-document=/tmp/mongo_db_shell.deb https://repo.mongodb.org/apt/ubuntu/dists/bionic/mongodb-org/4.2/multiverse/binary-amd64/mongodb-org-shell_4.2.15_amd64.deb
                sudo apt install -y /tmp/mongo_db_shell.deb
            fi
        }
        install_mongo_shell

        install_mongo_tools(){
            is_installed=$(dpkg --get-selections | grep -v deinstall | grep mongodb)
            if [[ "$is_installed" == *"mongodb-database-tools"* ]]; then
                # already installed
                echo -n ""
            else
                # Also see: https://github.com/komuw/docker-debug/blob/mongo/mongo.sh
                # The list of installed tools is: https://www.mongodb.com/docs/database-tools/
                # - mongodump     - export of the contents of a mongo db.
                # - mongorestore  - restores data from a mongodump to db.
                # - bsondump      - convert bson dump files to json.
                # - mongoimport   - imports content from an extended JSON, CSV, or TSV export file.
                # - mongoexport   - produces a JSON, CSV, export 
                # - mongostat     - provide a quick overview of the stus of a running mongo db instance.
                # - mongotop      - provide an overview of the time a mongo instance spends reading and writing data.
                # - mongofiles    - supports manipulating files stored in your MongoDB instance in GridFS objects.
                wget -nc --output-document=/tmp/mongodb_database_tools.deb "https://fastdl.mongodb.org/tools/db/mongodb-database-tools-ubuntu2204-x86_64-100.6.1.deb"
                sudo apt install -y /tmp/mongodb_database_tools.deb
            fi
        }
        install_mongo_tools

        install_jb_go_pkgs(){
            structslop_bin_file="/home/$MY_NAME/go/bin/structslop"
            if [ -f "$structslop_bin_file" ]; then
                # modules exists
                echo -n ""
            else
                go install github.com/orijtech/structslop/cmd/structslop@latest
                go install github.com/ovh/venom/cmd/venom@latest
            fi
        }
        install_jb_go_pkgs

        add_max_watches_config(){
            file_exists="/etc/sysctl.d/intellij_goland.conf"
            if [ -f "$file_exists" ]; then
                # exists
                echo -n ""
            else
                printf "\n\t creating... \n"
                sudo cp ../templates/intellij_goland.conf /etc/sysctl.d/intellij_goland.conf
                sudo sysctl -p --system
                # remember to restart Goland after this
            fi
        }
        add_max_watches_config

        install_chart_doc_gen(){
            chart_doc_bin_file="/usr/local/bin/chart-doc-gen"
            if [ -f "$chart_doc_bin_file" ]; then
                # binary exists
                echo -n ""
            else
                wget -nc --output-document=/tmp/chart-doc-gen https://github.com/kubepack/chart-doc-gen/releases/download/v0.4.7/chart-doc-gen-linux-amd64
                sudo mv /tmp/chart-doc-gen /usr/local/bin/chart-doc-gen
                chmod +x /usr/local/bin/chart-doc-gen
            fi
        }
        install_chart_doc_gen

        ### The following commented-out code is for minikube usage. I'm not using minikube at the moment(I'm using skaffold/kind)##
        #
        # add_libvirtd_group(){
        #     # NB: You may need to restart the machine for some of this to kick in.
        #     # especially adding user to the group.

        #     my_groups=$(groups $MY_NAME)
        #     if [[ "$my_groups" == *"libvirt"* ]]; then
        #         # exists
        #         echo -n ""
        #     else
        #         sudo groupadd --force libvirt # --force causes to exit with success if group already exists
        #         sudo usermod -aG libvirt $MY_NAME

        #         # https://github.com/kubernetes/minikube/issues/927#issuecomment-407274870
        #         sudo groupadd --force libvirtd
        #         sudo usermod -aG libvirtd $MY_NAME
        #     fi
        # }
        # add_libvirtd_group

        # add_libvirtd_systemd_files(){
        #     # https://github.com/snabbco/libvirt/blob/a4431931393aeb1ac5893f121151fa3df4fde612/daemon/libvirtd.socket.in
        #     # https://github.com/snabbco/libvirt/blob/a4431931393aeb1ac5893f121151fa3df4fde612/daemon/libvirtd.service.in
        #     # https://github.com/snabbco/libvirt/blob/a4431931393aeb1ac5893f121151fa3df4fde612/daemon/libvirtd.conf
        #     # https://libvirt.org/format.html


        #     # troubleshoot using:
        #     # - `journalctl -u libvirtd`
        #     # - `journalctl -n50 -u libvirtd`

        #     libvirtd_systemd_file="/etc/systemd/system/libvirtd.service"
        #     if [ -f "$libvirtd_systemd_file" ]; then
        #         # exists
        #         echo -n ""
        #     else
        #         sudo systemctl stop libvirtd

        #         sudo mkdir -p /etc/libvirtd
        #         sudo chown -R root:libvirt /etc/libvirtd
        #         sudo chown -R root:libvirt /var/run/libvirt
        #         sudo chown -R root:libvirt /var/lib/libvirt
        #         sudo chown -R root:libvirt /var/lib/libvirt/dnsmasq

        #         sudo cp ../templates/libvirtd_socket_file /etc/systemd/system/libvirtd.socket
        #         sudo cp ../templates/libvirtd_systemd_service_file /etc/systemd/system/libvirtd.service
        #         sudo cp ../templates/libvirtd.conf /etc/libvirtd/libvirtd.conf
        #         sudo chown -R root:libvirt /etc/libvirtd/libvirtd.conf

        #         sudo chmod 0777 /etc/systemd/system/libvirtd.socket
        #         sudo chmod 0777 /etc/systemd/system/libvirtd.service
        #         sudo chown -R root:libvirt /etc/systemd/system/libvirtd.socket
        #         sudo chown -R root:libvirt /etc/systemd/system/libvirtd.service

        #         sudo systemctl daemon-reload
        #         sudo systemctl enable libvirtd.socket
        #         sudo systemctl enable libvirtd.service
        #         systemctl list-unit-files | grep enabled | grep -i libvirtd

        #         sudo systemctl start libvirtd

        #         # symlink to /usr/libexec/qemu-kvm
        #         # some libraries(eg minikube) expect that path.
        #         sudo ln --force --symbolic $(which qemu-kvm) /usr/libexec/qemu-kvm
        #         sudo chown -R root:libvirt /usr/libexec/qemu-kvm
        #     fi
        # }
        # add_libvirtd_systemd_files

        # add_virtlogd_systemd_files(){
        #     # this is needed by libvirtd for logging purposes
        #     # https://libvirt.org/daemons.html#logging-systemd-integration


        #     virtlogd_systemd_file="/etc/systemd/system/virtlogd.service"
        #     if [ -f "$virtlogd_systemd_file" ]; then
        #         # exists
        #         echo -n ""
        #     else
        #         sudo systemctl stop virtlogd

        #         sudo cp ../templates/virtlogd_systemd_socket_file /etc/systemd/system/virtlogd.socket
        #         sudo cp ../templates/virtlogd_systemd_service_file /etc/systemd/system/virtlogd.service

        #         sudo chmod 0777 /etc/systemd/system/virtlogd.socket
        #         sudo chmod 0777 /etc/systemd/system/virtlogd.service
        #         sudo chown -R root:libvirt /etc/systemd/system/virtlogd.socket
        #         sudo chown -R root:libvirt /etc/systemd/system/virtlogd.service

        #         sudo systemctl daemon-reload
        #         sudo systemctl enable virtlogd.socket
        #         sudo systemctl enable virtlogd.service
        #         systemctl list-unit-files | grep enabled | grep -i virtlogd

        #         sudo systemctl start virtlogd
        #     fi
        # }
        # add_virtlogd_systemd_files

        # symlink_docker_mach_driver(){
        #     # by default, minikube downloads it's own binary of `docker-machine-driver-kvm2`
        #     # and saves it in `$HOME/.minikube/bin/`. this download happens when you do `minikube --profile=ara start`
        #     # however, that binary fails to run. try and run
        #     # `$HOME/.minikube/bin/docker-machine-driver-kvm2 version` to see the errors.
        #     #     `error while loading shared libraries: libvirt-qemu.so.0`
        #     # see: https://github.com/kubernetes/minikube/issues/6023#issuecomment-567274494
        #     # instead, what we can do is symlink the one installed by nix.

        #     file_exists="$HOME/.minikube/bin/docker-machine-driver-kvm2"
        #     if [ -f "$file_exists" ]; then
        #         # the file has already been symlinked.
        #         echo -n ""
        #     else
        #         ln --force --symbolic $(which docker-machine-driver-kvm2) $HOME/.minikube/bin/docker-machine-driver-kvm2
        #     fi
        # }
        # symlink_docker_mach_driver

        # start_libvirt_default_network(){
        #     # https://wiki.debian.org/KVM#Installation
        #     # If you use libvirt to manage your VMs, libvirt provides a NATed bridged network named `default`
        #     # that allows the host to communicate with the guests.
        #     # This network is available only for the system domains (that is VMs created by root or using the qemu:///system connection URI)
        #     # This network is not automatically started

        #     # we need to start the default network.
        #     # see; https://wiki.libvirt.org/page/Networking

        #     export LIBVIRT_DEFAULT_URI='qemu:///system'

        #     is_default_net=$(virsh --connect qemu:///system net-list --all)
        #     if [[ "$is_default_net" == *"default   active   yes"* ]]; then
        #         # the `default` network exists, is active & is set to autostart.
        #         echo -n ""
        #     else
        #         the_default_network_file=$(find /nix -name "default.xml" | grep -i networks | grep -v autostart)
        #         virsh net-define $the_default_network_file
        #         virsh net-list --all
        #         virsh --connect qemu:///system net-list --all
        #         virsh net-autostart default
        #         virsh net-start default
        #     fi
        # }
        # start_libvirt_default_network

    '';
}
