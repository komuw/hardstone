{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/21.05.tar.gz") {} }:

{

time.timeZone = "Africa/Nairobi";

environment.systemPackages =   [
    pkgs.zsh
    pkgs.vscode
    pkgs.docker
    pkgs.terminator
    pkgs.google-chrome
    ];

virtualisation.docker.enable = true;

services.openssh.enable = true;
programs.ssh.startAgent = true;

# alternatively, set env var `export NIXPKGS_ALLOW_UNFREE=1`
allowUnfree = true;

programs.zsh.enable = true;
programs.zsh.histSize = 4000;
programs.zsh.autosuggestions.enable = true;
programs.zsh.enableCompletion = true;
programs.zsh.enableBashCompletion = true;
programs.zsh.ohMyZsh.enable = true;

users.defaultUserShell = pkgs.zsh;
}