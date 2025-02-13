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

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux"; # Or "aarch64-linux" for ARM64, etc.  Adjust as needed.
      pkgs = nixpkgs.legacyPackages.${system};

      media = import ./media.nix { pkgs = pkgs; };
      another = import ./another.nix { pkgs = pkgs; };

    in {
      devShells = {
        default = pkgs.mkShell {
          buildInputs = [
            media 
            another 
          ];

          # Optional: Add a shell prompt customization
          shellHook = ''
            printf "\n\n running hooks for flake.nix \n\n"
            MY_NAME=$(whoami)
          '';

        # Use the devShell from imports.
        media = media.devShell; 
        another = another.devShell;
        };
      };

      # # Optional: To make these packages available in your system (requires NixOS or home-manager)
      # packages.${system} = {
      #   vlc = media.vlc;
      #   chrome = pkgs.google-chrome;
      # };

      # Optional: A simple hello world program
    #   apps.${system}.hello = {
    #     type = "app";
    #     program = "${pkgs.hello}/bin/hello";
    #   };

    };
}