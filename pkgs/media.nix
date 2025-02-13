{ pkgs }:
let
  vlc = pkgs.vlc;
  ffmpeg = pkgs.ffmpeg;
  mpv = pkgs.mpv;

in {
  default = [
      vlc 
      ffmpeg 
      mpv 
    ]; 

  devShell = pkgs.mkShell {
    buildInputs = [
        vlc
        ffmpeg
        mpv
    ];
    shellHook = ''
      printf "\n\n running hooks for media.nix \n\n"
      MY_NAME=$(whoami)
    '';
  };
}