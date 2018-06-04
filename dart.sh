#!/usr/bin/env bash

printf "\n\n  add Dart(dev version) apt key"
sudo sh -c 'curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_unstable.list > /etc/apt/sources.list.d/dart_unstable.list'
printf "\n\n  install dart"
sudo apt -y update && sudo apt -y install dart
