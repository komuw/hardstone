with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/81a80c69f716a5b782f2ab65e9eb38b7557ffb01.tar.gz") {});

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
          # https://askubuntu.com/a/904259/376092
          # (a) -mtime -7   : finds files that have a change time in the last 7 days
          # (b) -maxdepth 0 : ensures find won't go into the contents of the directory.
          # (c) -H          : dereferences /var/lib/apt/lists if it's a soft link
          if [[ "$(find -H /var/lib/apt/lists -maxdepth 0 -mtime -7)" ]]; then
              sudo apt -y update
          else
              echo -n ""
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
