with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/74bf39d3f5c72b0cfecdb7f14301ee71ead129ee.tar.gz") {});

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

          the_file="/var/lib/apt/periodic/update-success-stamp"
          if [ -f "$the_file" ]; then
              # exists
              echo -n ""
          else
              the_file="/var/lib/apt/lists"
          fi

          local aptDate="$(stat -c %Y $the_file)"             # seconds
          local nowDate="$(date +'%s')"                              # seconds
          local diffSinceUpdate=$((nowDate - aptDate))               # seconds
          local daysSinceUpdate="$((diffSinceUpdate/(60*60*24)))"    # days
          local updateInterval="$((21 * 24 * 60 * 60))" # 21 days

          if [ "$diffSinceUpdate" -gt "$updateInterval" ]; then
              sudo apt -y update
              sudo apt-get -y dist-upgrade # security updates
          else
              printf "\n\n No need to run 'apt update', it was last ran $daysSinceUpdate days ago. \n\n"
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
