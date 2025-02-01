with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/7af93d2e5372b0a12b3eda16dbb8eaddd0fe2176.tar.gz") {});

let

in stdenv.mkDerivation {
    name = "terminal";

    buildInputs = [
        pkgs.terminator
        # pkgs.ghostty # This one does not work
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

      setup_ghostty(){
          ghostty_conf_file="/home/$MY_NAME/.config/ghostty/config"
          if [ -f "$ghostty_conf_file" ]; then
            # config exists
            echo -n ""
          else
            wget -nc --output-document=/tmp/ghostty.deb "https://github.com/mkasberg/ghostty-ubuntu/releases/download/1.1.0-0-ppa1/ghostty_1.1.0-0.ppa1_amd64_24.04.deb"
            sudo apt install -y /tmp/ghostty.deb

            mkdir -p /home/$MY_NAME/.config/ghostty
            cp ./templates/terminal/ghostty_config /home/$MY_NAME/.config/ghostty/config
          fi
      }
      setup_ghostty

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
              wget -nc --output-document=/tmp/wezterm_nightly.deb "https://github.com/wez/wezterm/releases/download/nightly/wezterm-nightly.Ubuntu24.04.deb"
              sudo apt install -y /tmp/wezterm_nightly.deb
              mkdir -p /home/$MY_NAME/.config/wezterm
              cp ./templates/terminal/wezterm.lua /home/$MY_NAME/.config/wezterm/wezterm.lua
          fi
      }
      setup_wezterm

    '';
}
