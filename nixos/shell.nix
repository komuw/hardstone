
https://nixos.org/guides/declarative-and-reproducible-developer-environments.html#declarative-reproducible-envs
pkgs.mkShell {
  buildInputs = [
    pkgs.which
    pkgs.htop
    pkgs.zlib
  ];
}