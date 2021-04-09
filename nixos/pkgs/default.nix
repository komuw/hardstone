with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/4795e7f3a9cebe277bb4b5920caa8f0a2c313eb0.tar.gz") {});

/*
  Alternative are:
   (a) { pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/20.09.tar.gz") {} }:
   (b) { pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/4795e7f3a9cebe277bb4b5920caa8f0a2c313eb0.tar.gz") {} }:
   (c) with (import <nixpkgs> {});

*/

/*
    docs:
    1. https://nixos.org/manual/nix/stable/#chap-writing-nix-expressions
    2. https://nixos.org/guides/declarative-and-reproducible-developer-environments.html#declarative-reproducible-envs
    3. https://nixos.org/guides/towards-reproducibility-pinning-nixpkgs.html
    4. https://ghedam.at/15978/an-introduction-to-nix-shell

    usage:
    - from this directory, run;
        THE_USER=$(whoami)
        /nix/var/nix/profiles/per-user/$THE_USER/profile/bin/nix-shell
*/


let
  basePackages = [ ];
  
  htopPath = ./htop.nix;
  vlcPath = ./htop.nix;

  inputs = basePackages 
    ++ lib.optional (builtins.pathExists htopPath) (import htopPath {}).inputs
    ++ lib.optional (builtins.pathExists vlcPath) (import vlcPath {}).inputs;

  baseHooks = "echo 'hello from default.nix;'";

  shellHooks = baseHooks
    + lib.optionalString (builtins.pathExists htopPath) (import htopPath {}).hooks
    + lib.optionalString (builtins.pathExists vlcPath) (import vlcPath {}).hooks;

in mkShell {
  buildInputs = inputs;
  shellHook = shellHooks;
}
