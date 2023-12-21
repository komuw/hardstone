with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/30d79186dd081d226f1f3f2465c4f7f8acd5ce9c.tar.gz") {});

let

in stdenv.mkDerivation {
    name = "golang";

    # set/unset `NIX_HARDENING_ENABLE` env var; https://stackoverflow.com/a/27719330/2768067
    # We need to unset this because `delve` debugger is failing to debug with some error.
    #     ```
    #     runtime/cgo
    #     warning _FORTIFY_SOURCE requires compiling with optimization (-O)
    #         |    ^~~~~~~
    #     cc1: all warnings being treated as errors
    #     exit status 2
    #     ```
    # see issue: https://github.com/NixOS/nixpkgs/issues/18995
    #            https://github.com/ziglang/zig/wiki/Development-with-nix
    # also see PR: https://github.com/NixOS/nixpkgs/pull/28029/files on how it is set
    # and its default value
    hardeningDisable = [ "all" ];

    buildInputs = [
        # We do not use the one from nixpkgs since they usually take a lot of
        # time before updating to the latest Go version.
        # pkgs.go
      ];

    shellHook = ''
        # set -e # fail if any command fails
        # do not use `set -e` which causes commands to fail.
        # because it causes `nix-shell` to also exit if a command fails when running in the eventual shell

      printf "\n running hooks for golang.nix \n"

      MY_NAME=$(whoami)

      install_latest_golang(){
          golang_bin_file="/usr/local/go/bin/go"
          if [ -f "$golang_bin_file" ]; then
              # bin file exists
              echo -n ""
          else
              GOLANG_VERSION=go1.21.3.linux-amd64
              sudo rm -rf "/usr/local/$GOLANG_VERSION.tar.gz"
              sudo rm -rf /usr/local/go
              sudo wget -nc --output-document="/usr/local/$GOLANG_VERSION.tar.gz" "https://go.dev/dl/$GOLANG_VERSION.tar.gz"
              sudo tar -xzf "/usr/local/$GOLANG_VERSION.tar.gz" -C /usr/local/
              sudo ln --force --symbolic /usr/local/go/bin/go /usr/local/bin/go
          fi
      }
      install_latest_golang

      install_go_pkgs(){
          curlie_bin_file="/home/$MY_NAME/go/bin/curlie"
          if [ -f "$curlie_bin_file" ]; then
              # modules exists
              echo -n ""
          else
              go version
              go install github.com/rogpeppe/gohack@latest
              go install honnef.co/go/tools/cmd/staticcheck@latest
              go install github.com/go-delve/delve/cmd/dlv@latest
              go install golang.org/x/tools/gopls@latest
              go install golang.org/x/tools/cmd/godex@latest
              go install github.com/traefik/yaegi/cmd/yaegi@latest # yaegi repl. usage: rlwrap yaegi
              go install github.com/maruel/panicparse/v2/cmd/pp@latest
              go install github.com/securego/gosec/cmd/gosec@latest
              go install github.com/google/pprof@latest
              go install github.com/rs/curlie@latest
              go install github.com/tsenart/vegeta@latest
              go install mvdan.cc/gofumpt@latest
              go install golang.org/x/exp/cmd/gorelease@latest
              go install golang.org/dl/gotip@latest
              go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
              go install golang.org/x/tools/cmd/goimports@latest
              go install filippo.io/mkcert@latest
              go install github.com/quasilyte/go-ruleguard/cmd/ruleguard@latest
              go install golang.org/x/debug/cmd/viewcore@latest
              go install github.com/mfridman/tparse@latest
              go install github.com/vearutop/stuckroutines@latest
              go install github.com/loov/view-annotated-file@latest
              go install golang.org/x/vuln/cmd/govulncheck@latest
              go install golang.org/x/perf/cmd/benchstat@latest
              go install golang.org/x/tools/cmd/godoc@latest
              go install golang.org/x/tools/go/analysis/passes/shadow/cmd/shadow@latest
              go install go101.org/gotv@latest

              # my stuff
              go install github.com/komuw/ote@latest

              # the following are required by vscode for Go.
              go install github.com/uudashr/gopkgs/v2/cmd/gopkgs@latest
              go install github.com/ramya-rao-a/go-outline@latest
              go install github.com/cweill/gotests/gotests@latest
              go install github.com/fatih/gomodifytags@latest
              go install github.com/josharian/impl@latest
              go install github.com/haya14busa/goplay/cmd/goplay@latest
          fi
      }
      install_go_pkgs

      install_go_tip(){
          gotip_sdk_file="/home/$MY_NAME/sdk/gotip/bin/go"
          if [ -f "$gotip_sdk_file" ]; then
              # gotip sdk exists
              echo -n ""
          else
              /home/$MY_NAME/go/bin/gotip download
          fi
      }
      install_go_tip

      change_owner(){
          chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/go
          chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/.cache/
      }
      change_owner

      export NIX_HARDENING_ENABLE=""

    '';

    # set/unset `NIX_HARDENING_ENABLE` env var; https://stackoverflow.com/a/27719330/2768067
    # We need to unset this because `delve` debugger is failing to debug with some error.
    #     ```
    #     runtime/cgo
    #     warning _FORTIFY_SOURCE requires compiling with optimization (-O)
    #         |    ^~~~~~~
    #     cc1: all warnings being treated as errors
    #     exit status 2
    #     ```
    # see issue: https://github.com/NixOS/nixpkgs/issues/18995
    # also see PR: https://github.com/NixOS/nixpkgs/pull/28029/files on how it is set
    # and its default value
    NIX_HARDENING_ENABLE="";
}
