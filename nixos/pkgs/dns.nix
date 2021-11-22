with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/b56d7a70a7158f81d964a55cfeb78848a067cc7d.tar.gz") {});

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
' >> /etc/hosts
         fi
      }
      add_dev_hosts

      setup_dns(){
          local_file="/etc/systemd/network/local_dns.network"
          if [ -f "$local_file" ]; then
              # exists
              echo -n ""
          else
              sudo cp ../templates/etc.systemd.resolved.conf /etc/systemd/resolved.conf
              sudo cp ../templates/etc.systemd.network.local_dns.network /etc/systemd/network/local_dns.network
              sudo cp ../templates/etc.NetworkManager.NetworkManager.conf /etc/NetworkManager/NetworkManager.conf

              sudo systemctl daemon-reload
              sudo systemctl restart systemd-networkd
              sudo systemctl restart systemd-resolved
              sudo systemctl restart NetworkManager
          fi
      }
      setup_dns

    '';
}
