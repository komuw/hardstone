#!/usr/bin/env bash


printf "\n\n  download vscode"
wget -nc --directory-prefix=/tmp https://go.microsoft.com/fwlink/?LinkID=760868
printf "\n\n  install vscode"
dpkg -i /tmp/index.html\?LinkID\=760868

# on MacOs it is /Users/komuw/Library/Application\ Support/Code/User/settings.json
printf "\n\n  configure vscode user settings file"
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

printf "\n\n  install vscode extensions"
code --install-extension magicstack.MagicPython \
                         ms-python.python \
                         ms-vscode.Go \
                         sourcegraph.sourcegraph \
                         hnw.vscode-auto-open-markdown-preview \
                         Dart-Code.dart-code \
                         Dart-Code.flutter
