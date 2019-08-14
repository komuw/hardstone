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

printf "\n\n install Amazon Corretto openJDK\n"
# java 11 is an LTS
apt -y update
apt -y purge default-jre default-jdk
wget -nc --directory-prefix=/tmp https://d3pxv6yz143wms.cloudfront.net/11.0.4.11.1/java-11-amazon-corretto-jdk_11.0.4.11-1_amd64.deb
dpkg -i /tmp/java-11-amazon-corretto-jdk_11.0.4.11-1_amd64.deb

printf "\n\n install intellij idea\n"
snap install intellij-idea-community --classic 

printf "\n\n install gradle\n"
wget -nc --directory-prefix=/tmp https://services.gradle.org/distributions/gradle-5.5-bin.zip
unzip /tmp/gradle-5.5-bin.zip -d /usr/local
