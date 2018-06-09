#!/usr/bin/env bash
if test "$BASH" = "" || "$BASH" -uc "a=();true \"\${a[@]}\"" 2>/dev/null; then
    # Bash 4.4, Zsh
    set -euo pipefail
else
    # Bash 4.3 and older chokes on empty arrays with set -u.
    set -eo pipefail
fi
shopt -s nullglob globstar
export DEBIAN_FRONTEND=noninteractive


printf "\n\n  download vscode\n"
wget -nc --directory-prefix=/tmp "https://go.microsoft.com/fwlink/?LinkID=760868"
printf "\n\n  install vscode\n"
dpkg -i /tmp/index.html\?LinkID\=760868

# on MacOs it is /Users/komuw/Library/Application\ Support/Code/User/settings.json
printf "\n\n  configure vscode user settings file\n"
VSCODE_CONFIG_FILE_CONTENTS='{
    "window.zoomLevel": -2,
    "window.menuBarVisibility": "default",
    "files.exclude": {
        "**/.git": true,
        "**/.svn": true,
        "**/.hg": true,
        "**/CVS": true,
        "**/.DS_Store": true,
        "**/*.pyc": true
    },
    "editor.formatOnSave": true,
    "editor.minimap.enabled": false,
    "editor.quickSuggestions": {
        "other": true,
        "comments": true,
        "strings": true
    },
    "go.useCodeSnippetsOnFunctionSuggest": true,
    "go.autocompleteUnimportedPackages": true,
    "go.useLanguageServer": true,
    "python.linting.pylintArgs": [
        "--load-plugins",
        "pylint_django",
        "--enable=E",
        "--disable=W,R,C"
    ],
    "python.formatting.autopep8Args": [
        "--experimental",
        "--in-place",
        "-r",
        "-aaaaaaaaaa"
    ],
    "python.autoComplete.addBrackets": true,
    "python.venvFolders": [
        "envs",
        ".pyenv",
        ".direnv",
        ".virtualenvs",
        ".venv"
    ],
    "dart.allowAnalytics": false,
    "dart.debugExternalLibraries": true,
    "dart.debugSdkLibraries": true
}'
VSCODE_CONFIG_FILE=~/.config/Code/User/settings.json
touch "$VSCODE_CONFIG_FILE"
grep -qF -- "$VSCODE_CONFIG_FILE_CONTENTS" "$VSCODE_CONFIG_FILE" || echo "$VSCODE_CONFIG_FILE_CONTENTS" >> "$VSCODE_CONFIG_FILE"

printf "\n\n  install vscode extensions\n"
code --install-extension magicstack.MagicPython \
                         ms-python.python \
                         ms-vscode.Go \
                         sourcegraph.sourcegraph \
                         hnw.vscode-auto-open-markdown-preview \
                         Dart-Code.dart-code \
                         Dart-Code.flutter
