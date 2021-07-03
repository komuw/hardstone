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
  dartPath  = ./dart.nix;
  toolsPath  = ./tools.nix;
  ohMyZshPath  = ./oh_my_zsh.nix;
  terminalPath  = ./terminal.nix;

  inputs = basePackages 
    ++ lib.optional (builtins.pathExists preRequistePath) (import preRequistePath {}).inputs
    ++ lib.optional (builtins.pathExists provisionPath) (import provisionPath {}).inputs
    ++ lib.optional (builtins.pathExists versionControlPath) (import versionControlPath {}).inputs
    ++ lib.optional (builtins.pathExists setupSshPath) (import setupSshPath {}).inputs
    ++ lib.optional (builtins.pathExists golangPath) (import golangPath {}).inputs
    ++ lib.optional (builtins.pathExists vscodePath) (import vscodePath {}).inputs
    ++ lib.optional (builtins.pathExists dartPath) (import dartPath {}).inputs
    ++ lib.optional (builtins.pathExists toolsPath) (import toolsPath {}).inputs
    ++ lib.optional (builtins.pathExists ohMyZshPath) (import ohMyZshPath {}).inputs
    ++ lib.optional (builtins.pathExists terminalPath) (import terminalPath {}).inputs;

  baseHooks = "printf '\n running hooks for default.nix \n'";

  shellHooks = baseHooks
    + lib.optionalString (builtins.pathExists preRequistePath) (import preRequistePath {}).hooks
    + lib.optionalString (builtins.pathExists provisionPath) (import provisionPath {}).hooks
    + lib.optionalString (builtins.pathExists versionControlPath) (import versionControlPath {}).hooks
    + lib.optionalString (builtins.pathExists setupSshPath) (import setupSshPath {}).hooks
    + lib.optionalString (builtins.pathExists golangPath) (import golangPath {}).hooks
    + lib.optionalString (builtins.pathExists vscodePath) (import vscodePath {}).hooks
    + lib.optionalString (builtins.pathExists dartPath) (import dartPath {}).hooks
    + lib.optionalString (builtins.pathExists toolsPath) (import toolsPath {}).hooks
    + lib.optionalString (builtins.pathExists ohMyZshPath) (import ohMyZshPath {}).hooks
    + lib.optionalString (builtins.pathExists terminalPath) (import terminalPath {}).hooks;

in mkShell {
  buildInputs = inputs;
  shellHook = shellHooks;
}
