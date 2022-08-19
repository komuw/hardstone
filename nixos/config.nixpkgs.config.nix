{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/7d92cc4294b27227eebf0be3ea230809d1ead890.tar.gz") {} }:

{
# The time zone used when displaying times and dates. 
# See https://en.wikipedia.org/wiki/List_of_tz_database_time_zones for a comprehensive list of possible values for this setting. 
# If null, the timezone will default to UTC and can be set imperatively using timedatectl.
time.timeZone = "Africa/Nairobi";

# A list of permissible login shells for user accounts. No need to mention /bin/sh here, it is placed into this list implicitly.
environment.shells = [pkgs.zsh pkgs.bash];

# A set of environment variables used in the global environment. These variables will be set on shell initialisation (e.g. in /etc/profile). 
environment.variables = {
  SOME_ENV_VAR = "itsValue";
};

# An attribute set that maps aliases (the top level attribute names in this option) to command strings or directly to build outputs.
environment.shellAliases = {
  ll = "ls -l";
};

# The set of packages that appear in /run/current-system/sw. These packages are automatically available to all users, and are automatically updated every time you rebuild the system configuration.
environment.systemPackages =   [
    pkgs.zsh
    pkgs.vscode
    pkgs.docker
    pkgs.oh-my-zsh
    pkgs.terminator
    pkgs.google-chrome
    ];

# Set of default packages that aren't strictly neccessary for a running system, entries can be removed for a more minimal NixOS installation.
# Note: If pkgs.nano is removed from this list, make sure another editor is installed and the EDITOR environment variable is set to it. 
environment.defaultPackages = ["nano-5.7"];

# This option enables docker, a daemon that manages linux containers.
# Users in the "docker" group can interact with the daemon (e.g. to start or stop containers) using the docker command line tool.
virtualisation.docker.enable = true;
# When enabled dockerd is started on boot.
virtualisation.docker.enableOnBoot = true;

# Whether to start the OpenSSH agent when you log in. 
# The OpenSSH agent remembers private keys for you so that you don't have to type in passphrases every time you make an SSH connection. Use ssh-add to add a key to the agent.
programs.ssh.startAgent = true;

# alternatively, set env var `export NIXPKGS_ALLOW_UNFREE=1`
allowUnfree = true;

# Whether to configure zsh as an interactive shell. 
# To enable zsh for a particular user, use the users.users.<name?>.shell option for that user. To enable zsh system-wide use the users.defaultUserShell option.
programs.zsh.enable = true;

programs.zsh.histSize = 4000;
programs.zsh.autosuggestions.enable = true;
programs.zsh.enableCompletion = true;
programs.zsh.enableBashCompletion = true;

# Enable oh-my-zsh.
programs.zsh.ohMyZsh.enable = true;
# Package to install for `oh-my-zsh` usage.
programs.zsh.ohMyZsh.package = "pkgs.oh-my-zsh";

# This option defines the default shell assigned to user accounts. 
users.defaultUserShell = pkgs.zsh;
}