with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/c4336c26616ff4405b7eb4e1ff39a9a51f3538ab.tar.gz") {});

let

in stdenv.mkDerivation {
    name = "tools";

    buildInputs = [
        # youtube-dl fork
        pkgs.yt-dlp
        pkgs.asciinema
        pkgs.httpie
        # https://docs.aws.amazon.com/cli/latest/userguide/cliv2-migration.html
        pkgs.awscli
        pkgs.awscli2
        pkgs.bat
        pkgs.skypeforlinux # unfree
        pkgs.firefox
        pkgs.ripgrep
        pkgs.gotraceui
        # nix-shell fails for `ripgrep-all` with error;
        #   ERROR: test1 failed! Could not find the word 'hello' 26 times in the sample data.
        # pkgs.ripgrep-all
        pkgs.rr
        pkgs.unixtools.netstat
        pkgs.fzf
        pkgs.delta # https://github.com/dandavison/delta
        pkgs.sqlite

        pkgs.google-chrome # unfree
        # `ungoogled-chromium` is chromium with dependencies on Google web services removed.
        # It will install programs called `chromium` & `chromium-browser`
        pkgs.ungoogled-chromium

        # For some reason, zoom installed via nix is not working.
        # So we install it manually in `./start.sh`.
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
              sudo apt-get -y install libxcb-xtest0 \
                                      libxcb-xinerama0 \
                                      libxcb-cursor0

              rm -rf /tmp/zoom_amd64.deb
              rm -rf /home/$MY_NAME/.zoom/*
              rm -rf /usr/bin/zoom

              # Versions are found at; https://support.zoom.com/hc/en/article?id=zm_kb&sysparm_article=KB0061222
              # We have to choose the version carefully because some versions have bugs, even the latest versions.
              local VERSION="latest"
              local VERSION="6.0.12.5501" # 31/may/2024 : last working version
              local VERSION="6.3.6.6315" # 15/jan/2025
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

      install_wireguard(){
          # We haven't found wireguard on nixpkgs

          wg_file="/usr/bin/wg"
          if [ -f "$wg_file" ]; then
              # exists
              echo -n ""
          else
              # Install wireguard dependencies
              sudo apt -y update
              sudo apt-get -y install wireguard
          fi
      }
      install_wireguard

      install_superhtml(){
        # html formatter and linter.

        superhtml_file="/usr/local/bin/superhtml"
        if [ -f "$superhtml_file" ]; then
            # exists
            echo -n ""
        else
            wget -nc --output-document="/tmp/superhtml.tar.gz" "https://github.com/kristoff-it/superhtml/releases/download/v0.5.0/x86_64-linux-musl.tar.gz"
            mkdir -p /tmp/superhtml/
            tar -xzf "/tmp/superhtml.tar.gz" -C /tmp/superhtml/
            sudo cp /tmp/superhtml/x86_64-linux-musl/superhtml /usr/local/bin/superhtml
        fi
      }
      install_superhtml

    '';
}
