with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/437e3a21de2d2e1e4c3f556edf968d212f454c7f.tar.gz") {});

let

in stdenv.mkDerivation {
    name = "terminal";

    buildInputs = [
        pkgs.terminator
        pkgs.eternal-terminal
        ];

    shellHook = ''
        # set -e # fail if any command fails
        # do not use `set -e` which causes commands to fail.
        # because it causes `nix-shell` to also exit if a command fails when running in the eventual shell

      printf "\n running hooks for terminal.nix \n"

      MY_NAME=$(whoami)

      setup_terminator_conf(){
          mkdir -p /home/$MY_NAME/.config
          mkdir -p /home/$MY_NAME/.config/terminator
          cp ./templates/terminal/terminator_config /home/$MY_NAME/.config/terminator/config
      }
      setup_terminator_conf

      setup_wezterm(){
          # The wezterm pkg in nixpkgs has issues starting.
          # so we install manually.
          # TODO: revert to nix, once fixed.
          #
          # https://wezfurlong.org/wezterm/install/linux.html

          wezterm_conf_file="/home/$MY_NAME/.config/wezterm/wezterm.lua"
          if [ -f "$wezterm_conf_file" ]; then
              # config exists
              echo -n ""
          else
              wget -nc --output-document=/tmp/wezterm_nightly.deb https://github.com/wez/wezterm/releases/download/nightly/wezterm-nightly.Ubuntu22.04.deb
              sudo apt install -y /tmp/wezterm_nightly.deb
              mkdir -p /home/$MY_NAME/.config/wezterm
              cp ./templates/terminal/wezterm.lua /home/$MY_NAME/.config/wezterm/wezterm.lua
          fi
      }
      setup_wezterm

    '';
}
