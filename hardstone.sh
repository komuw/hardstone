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


# https://github.com/anordal/shellharden/blob/master/how_to_do_things_safely_in_bash.md
# http://wiki.bash-hackers.org/syntax/pe#use_a_default_value

SSH_KEY_PHRASE=${1:-sshKeyPhraseNotSet}
if [ "$SSH_KEY_PHRASE" == "sshKeyPhraseNotSet"  ]; then
    printf "\n\n SSH_KEY_PHRASE should not be empty\n"
    exit
fi


printf "\n\n starting setup/provisioning....\n"
apt-get -y update
apt-get -y install gcc \
                    build-essential \
                    libssl-dev \
                    libffi-dev \
                    python-dev \
                    software-properties-common \
                    curl \
                    wget
curl https://bootstrap.pypa.io/get-pip.py | python - 'pip==9.0.3' # see:: https://github.com/pypa/pip/issues/5240
pip install --ignore-installed -U pip
apt-get -y update

# When using the bash command to execute the scripts below;
# the script are executed as other processes, so variables and functions in the other scripts will not be accessible in the hardstone.sh script
# https://stackoverflow.com/questions/8352851/how-to-call-shell-script-from-another-shell-script

printf "\n\n CALLING provision.sh::\n\n"
/bin/bash provision.sh "$SSH_KEY_PHRASE"
printf "\n\n provision.sh done::\n"

printf "\n\n CALLING editors.sh::\n\n"
/bin/bash editors.sh
printf "\n\n editors.sh done::\n"

printf "\n\n CALLING golang.sh::\n\n"
/bin/bash golang.sh
printf "\n\n golang.sh done::\n"

printf "\n\n CALLING dart.sh::\n\n"
/bin/bash dart.sh
printf "\n\n dart.sh done::\n"

printf "\n\n CALLING work_stuff.sh::\n\n"
/bin/bash work_stuff.sh
printf "\n\n work_stuff.sh done::\n"

printf "\n\n CALLING xonsh.sh::\n\n"
/bin/bash xonsh.sh
printf "\n\n xonsh.sh done::\n"

printf "\n\n WHOLE SYSTEM SUCCESFULLY SETUP.\n"
