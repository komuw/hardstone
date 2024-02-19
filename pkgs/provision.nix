with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/f63489a7f0a548df967dc58d7d8fd18a0046d37d.tar.gz") {});

let

in stdenv.mkDerivation {
    name = "provision";

    buildInputs = [
        pkgs.mpv
        pkgs.openssh # TODO: we only want client not server
        pkgs.kdiff3
        pkgs.meld
        pkgs.lsof
        # inetutils provides the following tools: ftp, hostname, ifconfig, ping, telnet, traceroute, whois, etc.
        pkgs.inetutils
        pkgs.htop
        # `unrar` has an unfree LICENSE. By default, nix refuses to install it.
        #  We can force nix to install by setting env var `export NIXPKGS_ALLOW_UNFREE=1` or `allowUnfree` in `~/.config/nixpkgs/config.nix`
        # pkgs.unrar
        pkgs.transmission
        pkgs.vlc
        pkgs.screen
        pkgs.iftop
        pkgs.tcptrack
        pkgs.wireshark
        pkgs.nano
        pkgs.zip
        pkgs.redir
        pkgs.gdb
        pkgs.hexchat
        pkgs.mosh
        pkgs.eternal-terminal
        pkgs.psmisc
        pkgs.graphviz
        pkgs.ffmpeg
        pkgs.x264
        pkgs.x265
        pkgs.nettools
        pkgs.aria
        pkgs.shellcheck
        pkgs.rlwrap
        pkgs.tree
        pkgs.streamlink

        # FOUND BUT NOT SURE WE NEED THESE:
        # lxc

          # WE HAVENT FOUND THESE:
          # postgresql-client
          # lxc-templates
          # cgroup-lite
          # gdebi
          # wireguard
          # openssh-client

        ];

    shellHook = ''
        # set -e # fail if any command fails
        # do not use `set -e` which causes commands to fail.
        # because it causes `nix-shell` to also exit if a command fails when running in the eventual shell

      printf "\n running hooks for provision.nix \n"

      MY_NAME=$(whoami)

      create_dirs(){
            directory_exists="/home/$MY_NAME/mystuff"
            if [ -d "$directory_exists" ]; then
                # directory exists
                echo -n ""
            else
                mkdir -p /home/$MY_NAME/mystuff
                chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/mystuff

                mkdir -p /home/$MY_NAME/personalWork
                chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/personalWork

                mkdir -p /home/$MY_NAME/paidWork
                chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/paidWork
            fi
      }
      create_dirs

      setup_mpv_conf(){
          mkdir -p /home/$MY_NAME/.config/mpv
          cp ../templates/mpv_input.conf /home/$MY_NAME/.config/mpv/input.conf
          cp ../templates/mpv_main.conf /home/$MY_NAME/.config/mpv/mpv.conf
      }
      setup_mpv_conf

    '';
}
