with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/d7021b0c4d62f4792ebfffb07f76b49b51595eda.tar.gz") {});

let

in stdenv.mkDerivation {
    name = "preRequistes";

    buildInputs = [
      pkgs.gcc
      pkgs.curl 
      pkgs.wget 
      pkgs.git
      ];

    shellHook = ''
        # set -e # fail if any command fails
        # do not use `set -e` which causes commands to fail.
        # because it causes `nix-shell` to also exit if a command fails when running in the eventual shell

      printf "\n\n running hooks for preRequiste.nix \n\n"

      MY_NAME=$(whoami)

      CURL_CA_BUNDLE=$(find /nix -name ca-bundle.crt |tail -n 1)
      export CURL_CA_BUNDLE="$CURL_CA_BUNDLE"

      export SOME_CUSTOM_ENV_VAR="hello_there"

      setup_locale(){
          my_file=$(cat /etc/locale.gen)
          if [[ "$my_file" == *"en_AG"* ]]; then
                # it means that the `/etc/locale.gen` file still has the default settings it came with.
                # lets replace them
                sudo cp ../templates/etc_locale.gen /etc/locale.gen
                sudo locale-gen
            else
                echo -n ""
            fi
      }
      setup_locale

      update_ubuntu(){
          # https://askubuntu.com/a/589036/37609
          # https://github.com/ansible/ansible/blob/v2.13.0/lib/ansible/modules/apt.py#L1081-L1091
          # https://serverfault.com/a/151112

          local NOW=$(date +%s) # current unix timestamp.
          local the_file="/home/$MY_NAME/.config/last_ubuntu_update.txt"
          if [ -f "$the_file" ]; then
            # exists
            local LAST_UPDATE=$(cat $the_file)
            local diffSinceUpdate=$((NOW - LAST_UPDATE))  # seconds
            local daysSinceUpdate="$((diffSinceUpdate/(60*60*24)))"    # days
            local updateInterval="$((21 * 24 * 60 * 60))" # 21 days
            if [ "$diffSinceUpdate" -gt "$updateInterval" ]; then
                sudo apt -y update
                sudo apt-get -y dist-upgrade # security updates
                sudo apt -y autoremove
                sudo apt -y clean
                sudo apt -y purge '~c' # https://askubuntu.com/a/181965
                echo "$NOW" > $the_file
            else
              printf "\n\n No need to run 'apt update', it was last ran $daysSinceUpdate days ago. \n\n"
            fi
          else
            # file does not exist, update eitherway
            sudo apt -y update
            sudo apt-get -y dist-upgrade # security updates
            sudo apt -y autoremove
            sudo apt -y clean
            sudo apt -y purge '~c'
            echo "$NOW" > $the_file
          fi
      }
      update_ubuntu
    '';

    # set some env vars.
    # https://nixos.org/guides/declarative-and-reproducible-developer-environments.html#declarative-reproducible-envs
    # https://stackoverflow.com/a/27719330/2768067
    LC_ALL = "en_US.UTF-8";
    SOME_CUSTOM_ENV_VAR = "hello_there";
}
