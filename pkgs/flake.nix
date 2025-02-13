# flake.nix
{
# Usage:
#  cd $cwd
#  nix develop
# nix develop path:$(pwd) # This one does not require git.
#
# Docs:
# 1. https://gemini.google.com/share/560bf3b8ab29
# 2. https://jvns.ca/blog/2023/11/11/notes-on-nix-flakes/
# 3. https://blog.ysndr.de/posts/guides/2021-12-01-nix-shells/
#
  description = "linux setup";

  inputs = {
    # Pinned to a specific commit for reproducibility
    # Commits can be got from: https://github.com/NixOS/nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs?rev=7af93d2e5372b0a12b3eda16dbb8eaddd0fe2176";
  };

 outputs = { self, nixpkgs }: let # Add lib here!
    system = "x86_64-linux";  # Set your architecture!
    pkgs = nixpkgs.legacyPackages.${system};
    lib = nixpkgs.lib;       # Get lib from nixpkgs here!

    # Import the package definitions.
    media = import ./media.nix { inherit pkgs lib; };
    mpv = import ./mpv.nix { inherit pkgs lib; };

    myShellHook = ''
        echo "Welcome to the flake.nix development shell!"
        echo "This shell includes packages from media.nix and mpv.nix."
        export FLAKE_VAR="This is from flake.nix"
      '';

  in {
    packages.${system} = {
      default = pkgs.symlinkJoin {
        name = "all-tools";
        paths = (lib.attrValues media) ++ (lib.attrValues mpv); # Combine all packages
      };
    }; # Merge both 'media' and 'mpv' sets


    devShells.${system}.default = pkgs.mkShell {
      packages = (lib.attrValues media) ++ (lib.attrValues mpv);
      shellHook = myShellHook;
    };
  };
}