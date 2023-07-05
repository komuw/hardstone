with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/9eade54db008c4a1eccee60c9080d00d47932918.tar.gz") {});

let

in stdenv.mkDerivation {
    name = "tools";

    buildInputs = [
        pkgs.youtube-dl
        pkgs.asciinema
        pkgs.httpie
        # https://docs.aws.amazon.com/cli/latest/userguide/cliv2-migration.html
        pkgs.awscli
        pkgs.awscli2
        pkgs.bat
        pkgs.google-chrome # unfree
        pkgs.skypeforlinux # unfree
        pkgs.ripgrep
        pkgs.ripgrep-all
        pkgs.rr
        pkgs.unixtools.netstat
        pkgs.fzf
        pkgs.delta # https://github.com/dandavison/delta

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

      install_zoom(){
          # For some reason, zoom installed via nix is not working.
          # So we install it manually.
          # TODO: remove this once we get zoom working on nix.

          zoom_file="/usr/bin/zoom"
          if [ -f "$zoom_file" ]; then
              # exists
              echo -n ""
          else
              # Install zoom dependencies
              # Listed at; https://support.zoom.us/hc/en-us/articles/204206269-Installing-or-updating-Zoom-on-Linux#h_f75692f2-5e13-4526-ba87-216692521a82
              sudo apt -y update
              sudo apt-get -y install libgl1-mesa-glx \
                                      libegl1-mesa \
                                      libxcb-xtest0 \
                                      libxcb-xinerama0 \
                                      libxcb-cursor0

              rm -rf /tmp/zoom_amd64.deb
              rm -rf /home/$MY_NAME/.zoom/*
              rm -rf /usr/bin/zoom

              # Versions are found at; https://support.zoom.us/hc/en-us/articles/205759689-Release-notes-for-Linux
              # We have to choose the version carefully because some versions have bugs, even the latest versions.
              local VERSION="latest"
              local VERSION="5.14.7.2928" # may/2023
              wget -nc --output-document=/tmp/zoom_amd64.deb "https://zoom.us/client/$VERSION/zoom_amd64.deb"
              sudo dpkg -i /tmp/zoom_amd64.deb
          fi
      }
      install_zoom

      install_certutil(){
          certutil_file="/usr/bin/certutil"
          if [ -f "$certutil_file" ]; then
              # exists
              echo -n ""
          else
              sudo apt -y update
              sudo apt -y install libnss3-tools # has `certutil` that is needed by `FiloSottile/mkcert` & `komuw/ong`
          fi
      }
      install_certutil

    '';
}
