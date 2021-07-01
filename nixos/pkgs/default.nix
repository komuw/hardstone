with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/21.05.tar.gz") {});

/*
  Alternative are:
   (a) { pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/21.05.tar.gz") {} }:
   (b) { pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/4795e7f3a9cebe277bb4b5920caa8f0a2c313eb0.tar.gz") {} }:
   (c) with (import <nixpkgs> {});

*/

/*
    docs:
    1. https://nixos.org/manual/nix/stable/#chap-writing-nix-expressions
    2. https://nixos.org/guides/declarative-and-reproducible-developer-environments.html#declarative-reproducible-envs
    3. https://nixos.org/guides/towards-reproducibility-pinning-nixpkgs.html
    4. https://ghedam.at/15978/an-introduction-to-nix-shell
    5. https://nix.dev/tutorials/declarative-and-reproducible-developer-environments.html

    usage:
    - from this directory, run;
        MY_NAME=$(whoami)
        /nix/var/nix/profiles/per-user/$MY_NAME/profile/bin/nix-shell

    search for packages:
      1. https://search.nixos.org/
      2. nix search wget
*/


let
  basePackages = [ ];
  
  preRequistePath  = ./preRequiste.nix;
  provisionPath  = ./provision.nix;
  versionControlPath  = ./version_control.nix;
  setupSshPath  = ./setup_ssh.nix;
  golangPath  = ./golang.nix;
  vscodePath  = ./vscode.nix;

  inputs = basePackages 
    ++ lib.optional (builtins.pathExists preRequistePath) (import preRequistePath {}).inputs
    ++ lib.optional (builtins.pathExists provisionPath) (import provisionPath {}).inputs
    ++ lib.optional (builtins.pathExists versionControlPath) (import versionControlPath {}).inputs
    ++ lib.optional (builtins.pathExists setupSshPath) (import setupSshPath {}).inputs
    ++ lib.optional (builtins.pathExists golangPath) (import golangPath {}).inputs
    ++ lib.optional (builtins.pathExists vscodePath) (import vscodePath {}).inputs;

  baseHooks = "printf '\n\n running hooks for default.nix \n\n'";

  shellHooks = baseHooks
    + lib.optionalString (builtins.pathExists preRequistePath) (import preRequistePath {}).hooks
    + lib.optionalString (builtins.pathExists provisionPath) (import provisionPath {}).hooks
    + lib.optionalString (builtins.pathExists versionControlPath) (import versionControlPath {}).hooks
    + lib.optionalString (builtins.pathExists setupSshPath) (import setupSshPath {}).hooks
    + lib.optionalString (builtins.pathExists golangPath) (import golangPath {}).hooks
    + lib.optionalString (builtins.pathExists vscodePath) (import vscodePath {}).hooks;

in mkShell {
  buildInputs = inputs;
  shellHook = shellHooks;
}


# TODO: remove when done
#
# /bin/bash preRequiste.sh                         - DONE.
# /bin/bash user.sh "$USER_PASSWORD"               - DONE
# /bin/bash provision.sh                           - DONE
# /bin/bash version_control.sh "$PERSONAL_WORK_EMAIL" "$PERSONAL_WORK_NAME"  - DONE
# /bin/bash setup_ssh.sh "$SSH_KEY_PHRASE_PERSONAL" "$SSH_KEY_PHRASE_PERSONAL_WORK" "$PERSONAL_WORK_EMAIL" - DONE
# /bin/bash golang.sh - DONE
# /bin/bash vscode.sh - DONE
# /bin/bash dart.sh
# /bin/bash media.sh
# /bin/bash tools.sh
# /bin/bash ohmyz.sh
# /bin/bash java.sh
# /bin/bash clean_up.sh
