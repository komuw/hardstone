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

MY_NAME=$(whoami)

PERSONAL_WORK_EMAIL=${1:-PERSONAL_WORK_EMAILNotSet}
if [ "$PERSONAL_WORK_EMAIL" == "PERSONAL_WORK_EMAILNotSet"  ]; then
    printf "\n\n PERSONAL_WORK_EMAIL should not be empty\n"
    exit
fi

PERSONAL_WORK_NAME=${2:-PERSONAL_WORK_NAMENotSet}
if [ "$PERSONAL_WORK_NAME" == "PERSONAL_WORK_NAMENotSet"  ]; then
    printf "\n\n PERSONAL_WORK_NAME should not be empty\n"
    exit
fi


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
grep -qF -- "$GIT_CONFIG_FILE_CONTENTS" "$GIT_CONFIG_FILE" || echo "$GIT_CONFIG_FILE_CONTENTS" >> "$GIT_CONFIG_FILE"


printf "\n\n configure ~/mystuff/ gitconfig\n"
MYSTUFF_GIT_CONFIG_FILE_CONTENTS='
[user]
    name = $MY_NAME
    email = komuw05@gmail.com'

MYSTUFF_GIT_CONFIG_FILE=/home/$MY_NAME/mystuff/.gitconfig
touch "$MYSTUFF_GIT_CONFIG_FILE"
grep -qF -- "$MYSTUFF_GIT_CONFIG_FILE_CONTENTS" "$MYSTUFF_GIT_CONFIG_FILE" || echo "$MYSTUFF_GIT_CONFIG_FILE_CONTENTS" >> "$MYSTUFF_GIT_CONFIG_FILE"


printf "\n\n configure ~/personalWork/ gitconfig\n"
PERSONAL_WORK_GIT_CONFIG_FILE_CONTENTS='
[user]
    name = "$PERSONAL_WORK_NAME"
    email = "$PERSONAL_WORK_EMAIL"'

PERSONAL_WORK_GIT_CONFIG_FILE=/home/$MY_NAME/personalWork/.gitconfig
touch "$PERSONAL_WORK_GIT_CONFIG_FILE"
grep -qF -- "$PERSONAL_WORK_GIT_CONFIG_FILE_CONTENTS" "$PERSONAL_WORK_GIT_CONFIG_FILE" || echo "$PERSONAL_WORK_GIT_CONFIG_FILE_CONTENTS" >> "$PERSONAL_WORK_GIT_CONFIG_FILE"

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
grep -qF -- "$GIT_ATTRIBUTES_FILE_CONTENTS" "$GIT_ATTRIBUTES_FILE" || echo "$GIT_ATTRIBUTES_FILE_CONTENTS" >> "$GIT_ATTRIBUTES_FILE"


printf "\n\n configure hgrc(mercurial)\n"
MERCURIAL_CONFIG_FILE_CONTENTS='[ui]
username = $MY_NAME <komuw05@gmail.com>'
MERCURIAL_CONFIG_FILE=/home/$MY_NAME/.hgrc
touch "$MERCURIAL_CONFIG_FILE"
grep -qF -- "$MERCURIAL_CONFIG_FILE_CONTENTS" "$MERCURIAL_CONFIG_FILE" || echo "$MERCURIAL_CONFIG_FILE_CONTENTS" >> "$MERCURIAL_CONFIG_FILE"

