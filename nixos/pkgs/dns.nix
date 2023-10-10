with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/0b36900606b9be03ccb554be867ae2405f6ba428.tar.gz") {});

let

in stdenv.mkDerivation {
    name = "dns";

    buildInputs = [
        # TODO: remove this dnsmasq.
        # Do we need this while I'm using systemd-resolved? https://tailscale.com/blog/sisyphean-dns-client-linux/
        pkgs.dnsmasq
    ];

    shellHook = ''
        # set -e # fail if any command fails
        # do not use `set -e` which causes commands to fail.
        # because it causes `nix-shell` to also exit if a command fails when running in the eventual shell

      printf "\n running hooks for dns.nix \n"

      MY_NAME=$(whoami)

      add_dev_hosts(){
          hosts_file=$(cat /etc/hosts)
          if [[ "$hosts_file" == *"ara"* ]]; then
              # hosts file is already well populated.
              echo -n ""
          else
              sudo echo '
127.0.0.1   localhost

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

# jb
127.0.0.1 mongodb-primary.ara-dev mongodb-secondary.ara-dev mongodb-arbiter.ara-dev
127.0.0.1 controller.ara.test dashboard.ara.test billing.ara.test
' >> /etc/hosts
         fi
      }
      add_dev_hosts

      setup_dns_files(){
          # example usage:
          #    setup_dns_files etc_systemd_network_wireless_internet_dns.network
          #     or
          #    setup_dns_files etc_systemd_network_tethered_internet_dns.network

          sudo rm -rf /etc/systemd/network/*
          sudo cp ../templates/etc.systemd.resolved.conf /etc/systemd/resolved.conf
          sudo cp "../templates/$1" "/etc/systemd/network/$1"
          sudo cp ../templates/etc.NetworkManager.NetworkManager.conf /etc/NetworkManager/NetworkManager.conf

          sudo systemctl daemon-reload
          sudo systemctl restart systemd-networkd
          sudo systemctl restart systemd-resolved
          sudo systemctl restart NetworkManager
      }

      setup_dns(){
          if [[ -z "$USING_TETHERED_INTERNET" ]]; then
              # that env var is unset, which means we are NOT using tethered internet.
              # ie, we are using wireless internet.
              the_file_name="etc_systemd_network_wireless_internet_dns.network"
          else
              the_file_name="etc_systemd_network_tethered_internet_dns.network"
          fi

          local_file="/etc/systemd/network/$the_file_name"
          if [ -f "$local_file" ]; then
              # exists
              echo -n ""
          else
              setup_dns_files "$the_file_name"
          fi
      }
      setup_dns

    '';
}
