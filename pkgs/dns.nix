with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/7af93d2e5372b0a12b3eda16dbb8eaddd0fe2176.tar.gz") {});

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
          if [[ "$hosts_file" == *"app"* ]]; then
              # hosts file is already well populated.
              echo -n ""
          else
              hostnamectl set-hostname kw # set new hostname

              sudo chown -R $MY_NAME:$MY_NAME /etc/hosts
              sudo echo '
127.0.0.1   localhost

# new hostname
127.0.1.1   kw

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

# jb
127.0.0.1 hello.app.test hell.app.test
' >> /etc/hosts

          # google-chrome misbehaves when hostname is changed, so fix that.
          # see: https://askubuntu.com/a/476932/376092
          rm -rf ~/.config/google-chrome/Singleton*
         fi
      }
      add_dev_hosts

      setup_systemd_resolved_dns_files(){
          # This is a helper function that is called by `setup_systemd_resolved_dns`
          #
          # example usage:
          #    setup_systemd_resolved_dns_files etc_systemd_network_wireless_internet_dns.network
          #     or
          #    setup_systemd_resolved_dns_files etc_systemd_network_tethered_internet_dns.network

          sudo rm -rf /etc/systemd/network/*
          sudo cp ./templates/dns/etc.systemd.resolved.conf /etc/systemd/resolved.conf
          sudo cp "./templates/dns/$1" "/etc/systemd/network/$1"
          sudo cp ./templates/dns/etc.NetworkManager.NetworkManager.conf /etc/NetworkManager/NetworkManager.conf

          sudo systemctl daemon-reload
          sudo systemctl restart systemd-networkd
          sudo systemctl restart systemd-resolved
          sudo systemctl restart NetworkManager
      }

      setup_systemd_resolved_dns(){
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
              setup_systemd_resolved_dns_files "$the_file_name"
          fi
      }
      setup_systemd_resolved_dns

      setup_dnscrypt_proxy(){
          local_file="/etc/systemd/system/dnscrypt-proxy.service"
          if [ -f "$local_file" ]; then
              # exists
              echo -n ""
          else
              rm -rf /tmp/dnscrypt-proxy/
              mkdir -p /tmp/dnscrypt-proxy/
              wget -nc --output-document="/tmp/dnscrypt-proxy/dnscrypt-proxy.tar.gz" "https://github.com/DNSCrypt/dnscrypt-proxy/releases/download/2.1.8/dnscrypt-proxy-linux_x86_64-2.1.8.tar.gz"
              tar -xzf "/tmp/dnscrypt-proxy/dnscrypt-proxy.tar.gz" -C /tmp/dnscrypt-proxy/
              sudo cp /tmp/dnscrypt-proxy/linux-x86_64/dnscrypt-proxy /usr/local/bin

              sudo rm -rf /etc/dnscrypt-proxy
              sudo mkdir -p /etc/dnscrypt-proxy
              sudo cp ./templates/dns/dnscrypt.forwarding-rules.txt /etc/dnscrypt-proxy/dnscrypt.forwarding-rules.txt
              sudo cp ./templates/dns/dnscrypt-cloaking-rules.txt /etc/dnscrypt-proxy/dnscrypt-cloaking-rules.txt
              sudo cp ./templates/dns/dnscrypt-proxy.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml
              sudo cp ./templates/dns/dnscrypt-allowed-names.txt /etc/dnscrypt-proxy/dnscrypt-allowed-names.txt
              sudo cp ./templates/dns/dnscrypt-proxy-blocked-names.txt /etc/dnscrypt-proxy/blocked-names.txt

              dnscrypt-proxy -check -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml

              # only do this after you are done the downloading above.
              # otherwise you wont be able to download since dns will be down.
              sudo systemctl stop systemd-resolved
              sudo systemctl disable systemd-resolved
              sudo apt -y remove resolvconf
              sudo apt -y purge resolvconf

              # only do this after you are done the downloading above.
              # otherwise you wont be able to download since dns will be down.
              sudo rm -f /etc/resolv.conf
              sudo cp ./templates/dns/dnscrypt.resolv.conf /etc/resolv.conf

              sudo cp ./templates/dns/dnscrypt-proxy-systemd.service /etc/systemd/system/dnscrypt-proxy.service
              sudo chmod 0777 /etc/systemd/system/dnscrypt-proxy.service
              sudo systemctl daemon-reload
              sudo systemctl enable dnscrypt-proxy.service
              systemctl list-unit-files | grep enabled | grep -i dnscrypt-proxy
              sudo systemctl start dnscrypt-proxy # this will start dnscrypt-proxy.service

              sudo systemctl restart NetworkManager
          fi
      }
      setup_dnscrypt_proxy

      undo_setup_dnscrypt_proxy(){
          # Function that can be used to undo any unwanted DNS changes.
          # This restores things back to using systemd DNS.

          echo "
nameserver 127.0.0.53
options edns0 trust-ad
search ." | sudo tee /etc/resolv.conf

          sudo systemctl start systemd-resolved
          sudo systemctl enable systemd-resolved

          sudo systemctl daemon-reload
          sudo systemctl restart systemd-networkd
          sudo systemctl restart systemd-resolved
          sudo systemctl restart NetworkManager
      }

    '';
}
