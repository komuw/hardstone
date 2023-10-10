with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/0b36900606b9be03ccb554be867ae2405f6ba428.tar.gz") {});

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

      insert_if_not_exists() {
        # This will write something to a text file if it doesnt already exist.
        # usage:
        #   insert_if_not_exists "example" "78.3.21 example.com" /etc/hosts

        to_check=$1
        to_add=$2
        file=$3

        if grep -q "$to_check" "$file"; then
          # already exists
          echo -n ""
        else
          # append
          { # try
            printf "$to_add" >> "$file"
          } || { # catch
            printf "$to_add" | sudo tee -a "$file"
          }
        fi
      }

      setup_limits_config(){
            # ulimit -a
            #
            # By default limits are taken from the /etc/security/limits.conf config file. 
            # Then individual *.conf files from the /etc/security/limits.d/ directory are read. 
            # See: "man pam_limits"
            #
            file_exists="/etc/security/limits.d/file_limits.conf"
            if [ -f "$file_exists" ]; then
                # exists
                echo -n ""
            else
                sudo cp ../templates/file_limits.conf /etc/security/limits.d/file_limits.conf

                # systemd ignores the values from the /etc/security/limits.conf
                # See: https://askubuntu.com/a/1086382
                # Use "systemd-analyze cat-config systemd/system.conf" to analyze entire config.
                # Or "systemctl --user show | grep -i LimitNOFILE; systemctl show | grep -i LimitNOFILE"
                #
                sudo mkdir -p /etc/systemd/system.conf.d/
                sudo mkdir -p /etc/systemd/user.conf.d/
                sudo cp ../templates/custom_systemd.conf /etc/systemd/system.conf.d/custom_systemd.conf
                sudo cp ../templates/custom_systemd.conf /etc/systemd/user.conf.d/custom_systemd.conf

                insert_if_not_exists "65535" "\nDefaultLimitNOFILE=65535:524288\nDefaultLimitNOFILESoft=65535" /etc/systemd/system.conf
                insert_if_not_exists "65535" "\nDefaultLimitNOFILE=65535:524288\nDefaultLimitNOFILESoft=65535" /etc/systemd/user.conf

                systemctl --user daemon-reload
                sudo systemctl daemon-reload
            fi
      }
      setup_limits_config

      add_sysctl_config(){
            # Use "sysctl -a" to find current values.
            #
            file_exists="/etc/sysctl.d/sysctl.conf"
            if [ -f "$file_exists" ]; then
                # exists
                echo -n ""
            else
                sudo cp ../templates/sysctl.conf /etc/sysctl.d/sysctl.conf
                sudo sysctl -p --system
            fi
      }
      add_sysctl_config

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
                sudo update-ca-certificates --fresh
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
            # file does not exist, update either way
            sudo update-ca-certificates --fresh
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
