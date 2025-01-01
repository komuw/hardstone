with import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/fa6faf973d97caaea26b88eba007b61bb8228fd8.tar.gz") {};
with {
  # Using multiple channels in a shell.nix file.
  # https://devpress.csdn.net/k8s/62f4ea85c6770329307fa981.html
  # https://nixos.org/guides/nix-pills/fundamentals-of-stdenv.html#idm140737319505936
  #
  # Specific package versions can be found in;
  # - https://www.nixhub.io/
  # - https://lazamar.co.uk/nix-versions/ 
  # - https://search.nixos.org/packages

  # You can use the below if you need specific versions of packages.
  # For now, we do not.
  #
  # We need some specific versions of helm, kind, skaffold, chromium, etc.
  #
  # skaffold: vA.B
  # see: https://lazamar.co.uk/nix-versions
  # see: https://lazamar.co.uk/nix-versions/?package=skaffold&version=2.0.3&fullName=skaffold-2.0.3&keyName=skaffold&revision=79b3d4bcae8c7007c9fd51c279a8a67acfa73a2a&channel=nixpkgs-unstable#instructions
  skaffoldImport = (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/fa6faf973d97caaea26b88eba007b61bb8228fd8.tar.gz") {});
  # helm version: vA.B
  helmImport = (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/fa6faf973d97caaea26b88eba007b61bb8228fd8.tar.gz") {});
  # kind: vA.B
  kindImport = (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/fa6faf973d97caaea26b88eba007b61bb8228fd8.tar.gz") {});
};
let
in stdenv.mkDerivation {

    buildInputs = [
        pkgs.jq
        pkgs.kubectl
        pkgs.nodejs_23 # will also install npm
        pkgs.ungoogled-chromium # with dependencies on Google web services removed

        skaffoldImport.skaffold
        helmImport.kubernetes-helm-wrapped
        kindImport.kind
    ];

    shellHook = ''
        # set -e # fail if any command fails
        # do not use `set -e` which causes commands to fail.
        # because it causes `nix-shell` to also exit if a command fails when running in the eventual shell

        printf "\n running hooks for jb.nix \n"

        MY_NAME=$(whoami)

        install_mongo_shell(){
            # https://docs.mongodb.com/manual/reference/program/mongo/
            #  The version of mongodb available in nixpkgs is older than the version we need. So we'll install manually.

            is_installed=$(dpkg --get-selections | grep -v deinstall | grep mongodb)
            if [[ "$is_installed" == *"mongodb-mongosh"* ]]; then
                # already installed
                echo -n ""
            else
                # the binary is installed with name `mongosh`
                # we download an ubuntu18.04 since 21.04 isn't available from download page.
                wget -nc --output-document=/tmp/mongo_db_shell.deb https://repo.mongodb.org/apt/ubuntu/dists/jammy/mongodb-org/5.0/multiverse/binary-amd64/mongodb-mongosh_2.1.3_amd64.deb
                sudo apt install -y /tmp/mongo_db_shell.deb
            fi
        }
        # install_mongo_shell

        install_mongo_tools(){
            is_installed=$(dpkg --get-selections | grep -v deinstall | grep mongodb)
            if [[ "$is_installed" == *"mongodb-database-tools"* ]]; then
                # already installed
                echo -n ""
            else
                # Also see: https://github.com/komuw/docker-debug/blob/mongo/mongo.sh
                # The list of installed tools is: https://www.mongodb.com/docs/database-tools/
                # - mongodump     - export of the contents of a mongo db.
                # - mongorestore  - restores data from a mongodump to db.
                # - bsondump      - convert bson dump files to json.
                # - mongoimport   - imports content from an extended JSON, CSV, or TSV export file.
                # - mongoexport   - produces a JSON, CSV, export 
                # - mongostat     - provide a quick overview of the stus of a running mongo db instance.
                # - mongotop      - provide an overview of the time a mongo instance spends reading and writing data.
                # - mongofiles    - supports manipulating files stored in your MongoDB instance in GridFS objects.
                wget -nc --output-document=/tmp/mongodb_database_tools.deb "https://fastdl.mongodb.org/tools/db/mongodb-database-tools-ubuntu2204-x86_64-100.6.1.deb"
                sudo apt install -y /tmp/mongodb_database_tools.deb
            fi
        }
        # install_mongo_tools
    '';
}
