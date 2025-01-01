with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/7d9758079f4a14b4d397b0c4186d6168885586d4.tar.gz") {});

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
        /home/$MY_NAME/.nix-profile/bin/nix-shell

    search for packages:
      1. https://search.nixos.org/packages
      2. nix search wget
      3. https://www.nixhub.io/                # This will also give you historical versions.
      4. https://lazamar.co.uk/nix-versions/   # This will also give you historical versions.
    search for options to add to `~/.config/nixpkgs`
      1. https://search.nixos.org/options
*/

let
    basePackages = [];
    baseHooks = "";

    preRequisteImport = import ./preRequiste.nix;
    provisionImport  = import ./provision.nix;
    versionControlImport  = import ./version_control.nix;
    setupSshImport  = import ./setup_ssh.nix;
    golangImport  = import ./golang.nix;
    vscodeImport  = import ./vscode.nix;
    dartImport  = import ./dart.nix;
    toolsImport  = import ./tools.nix;
    dockerImport  = import ./docker.nix;
    ohMyZshImport  = import ./oh_my_zsh.nix;
    terminalImport  = import ./terminal.nix;
    dnsImport  = import ./dns.nix;
    jbImport  = import ./jb.nix;
    cLangImport = import ./c_lang.nix;

in stdenv.mkDerivation {
    # docs: http://blog.ielliott.io/nix-docs/stdenv-mkDerivation.html

    name = "default";

    buildInputs = basePackages
      ++ preRequisteImport.buildInputs
      ++ provisionImport.buildInputs
      ++ versionControlImport.buildInputs
      ++ setupSshImport.buildInputs
      ++ golangImport.buildInputs
      ++ vscodeImport.buildInputs
      ++ dartImport.buildInputs
      ++ toolsImport.buildInputs
      ++ dockerImport.buildInputs
      ++ ohMyZshImport.buildInputs
      ++ terminalImport.buildInputs
      ++ dnsImport.buildInputs
      ++ jbImport.buildInputs
      ++ cLangImport.buildInputs;

    # shellHook is a shell script to run after entering a nix-shell.
    shellHook = baseHooks
      + preRequisteImport.shellHook
      + provisionImport.shellHook
      + versionControlImport.shellHook
      + setupSshImport.shellHook
      + golangImport.shellHook
      + vscodeImport.shellHook
      + dartImport.shellHook
      + toolsImport.shellHook
      + dockerImport.shellHook
      + ohMyZshImport.shellHook
      + terminalImport.shellHook
      + dnsImport.shellHook
      + jbImport.shellHook
      + cLangImport.shellHook;

    # buildPhase:      string?,
    # installPhase:    string?,
}
