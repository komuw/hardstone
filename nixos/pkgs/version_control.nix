{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/21.05.tar.gz") {} }:

{
  inputs = [];
  hooks = ''
    printf "\n\n running hooks for version_control.nix \n\n"

    MY_NAME=$(whoami)

    printf "\n\n configure gitconfig\n"
    GIT_CONFIG_FILE_CONTENTS='
    # https://blog.jiayu.co/2019/02/conditional-git-configuration/

    [includeIf "gitdir:~/personalWork/"]
        path = ~/personalWork/.gitconfig

    [includeIf "gitdir:~/mystuff/"]
        path = ~/mystuff/.gitconfig

    [alias]
    co = checkout
    ci = commit
    st = status
    br = branch
    hist = log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short
    type = cat-file -t
    dump = cat-file -p

    [diff]
    tool = meld
    [difftool "meld"]

    [merge]
    tool = meld
    conflictstyle = diff3
    [mergetool "meld"]
    keepBackup = false'

    GIT_CONFIG_FILE=/home/$MY_NAME/.gitconfig
    touch "$GIT_CONFIG_FILE"
    grep -qxF "$GIT_CONFIG_FILE_CONTENTS" "$GIT_CONFIG_FILE" || echo "$GIT_CONFIG_FILE_CONTENTS" >> "$GIT_CONFIG_FILE"

    printf "\n\n configure ~/mystuff/ gitconfig\n"
    MYSTUFF_GIT_CONFIG_FILE_CONTENTS='
    [user]
        name = $MY_NAME
        email = komuw05@gmail.com'

    MYSTUFF_GIT_CONFIG_FILE=/home/$MY_NAME/mystuff/.gitconfig
    touch "$MYSTUFF_GIT_CONFIG_FILE"
    grep -qxF "$MYSTUFF_GIT_CONFIG_FILE_CONTENTS" "$MYSTUFF_GIT_CONFIG_FILE" || echo "$MYSTUFF_GIT_CONFIG_FILE_CONTENTS" >> "$MYSTUFF_GIT_CONFIG_FILE"

    printf "\n\n configure ~/personalWork/ gitconfig\n"
    PERSONAL_WORK_GIT_CONFIG_FILE_CONTENTS='
    [user]
        name = "$PERSONAL_WORK_NAME"
        email = "$PERSONAL_WORK_EMAIL"'

    PERSONAL_WORK_GIT_CONFIG_FILE=/home/$MY_NAME/personalWork/.gitconfig
    touch "$PERSONAL_WORK_GIT_CONFIG_FILE"
    grep -qxF "$PERSONAL_WORK_GIT_CONFIG_FILE_CONTENTS" "$PERSONAL_WORK_GIT_CONFIG_FILE" || echo "$PERSONAL_WORK_GIT_CONFIG_FILE_CONTENTS" >> "$PERSONAL_WORK_GIT_CONFIG_FILE"

    printf "\n\n configure gitattributes\n"
    GIT_ATTRIBUTES_FILE_CONTENTS='
    *.c     diff=cpp
    *.h     diff=cpp
    *.c++   diff=cpp
    *.h++   diff=cpp
    *.cpp   diff=cpp
    *.hpp   diff=cpp
    *.cc    diff=cpp
    *.hh    diff=cpp
    *.cs    diff=csharp
    *.css   diff=css
    *.html  diff=html
    *.xhtml diff=html
    *.ex    diff=elixir
    *.exs   diff=elixir
    *.go    diff=golang
    *.php   diff=php
    *.pl    diff=perl
    *.py    diff=python
    *.md    diff=markdown
    *.rb    diff=ruby
    *.rake  diff=ruby
    *.rs    diff=rust'

    GIT_ATTRIBUTES_FILE=/home/$MY_NAME/mystuff/.gitattributes
    touch "$GIT_ATTRIBUTES_FILE"
    grep -qxF "$GIT_ATTRIBUTES_FILE_CONTENTS" "$GIT_ATTRIBUTES_FILE" || echo "$GIT_ATTRIBUTES_FILE_CONTENTS" >> "$GIT_ATTRIBUTES_FILE"

    printf "\n\n configure hgrc(mercurial)\n"
    MERCURIAL_CONFIG_FILE_CONTENTS='[ui]
    username = $MY_NAME <komuw05@gmail.com>'
    MERCURIAL_CONFIG_FILE=/home/$MY_NAME/.hgrc
    touch "$MERCURIAL_CONFIG_FILE"
    grep -qxF "$MERCURIAL_CONFIG_FILE_CONTENTS" "$MERCURIAL_CONFIG_FILE" || echo "$MERCURIAL_CONFIG_FILE_CONTENTS" >> "$MERCURIAL_CONFIG_FILE"

  '';
}
