{ pkgs }:
let
  kdiff3 = pkgs.kdiff3;
  meld = pkgs.meld;

in {
  default = [
      kdiff3 
      meld 
    ]; 

  devShell = pkgs.mkShell {
    buildInputs = [
        kdiff3
        meld
    ];
    shellHook = ''
      printf "\n\n running hooks for another.nix \n\n"
      MY_NAME=$(whoami)
    '';
  };
}