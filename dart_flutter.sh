#!/usr/bin/env bash

FLUTTER_VERSION=flutter_linux_v0.3.2-beta

printf "\n\n  download flutter"
sudo wget -nc --directory-prefix=/usr/local "https://storage.googleapis.com/flutter_infra/releases/beta/linux/$FLUTTER_VERSION.tar.xz"

printf "\n\n  untar flutter file"
sudo tar xf "/usr/local/$FLUTTER_VERSION.tar.xz" -C /usr/local/


printf "\n\n add flutter profile"
DART_CONFIG_FILE_CONTENTS='#dart and flutter
export PATH=$PATH:/usr/local/flutter/bin
export PATH=$PATH:/usr/lib/dart/bin'
DART_CONFIG_FILE=etc/profile
touch "$DART_CONFIG_FILE"
grep -qF -- "$DART_CONFIG_FILE_CONTENTS" "$DART_CONFIG_FILE" || echo "$DART_CONFIG_FILE_CONTENTS" >> "$DART_CONFIG_FILE"

printf "\n\n  source profile"
source /etc/profile

printf "\n\n  give {{ansible_ssh_user}} perms on flutter dir"
chown -R komuw /usr/local/flutter

printf "\n\n  check flutter version"
flutter --version

printf "\n\n  download android-studio"
sudo wget -nc --directory-prefix=/usr/local https://dl.google.com/dl/android/studio/ide-zips/3.1.2.0/android-studio-ide-173.4720617-linux.zip

printf "\n\n  unzip android-studio file"
sudo unzip /usr/local/android-studio-ide-173.4720617-linux.zip -d /usr/local/android-studio/

printf "\n\n  install kvm(useful for android emulator acceleration)"
sudo apt -y update; sudo apt -y install qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils

printf "\n\n  verify kvm install"
virsh list --all

printf "\n\n  instructions for manual things to do:"
printf "\n 1.you can start android-studio using;
        \n /usr/local/android-studio/bin/studio.sh

        \n\n 2. accept android licenses using;
        \n flutter doctor --android-licenses

        \n\n 3. install dart/flutter plugins in android-studio;
        \n File>Settings>Plugins

        \n\n 4. select virtual device in android-studio;
        \n Tools>AVD Manager>create a device
        \n - if unsure; use pixel2 and oreo android version.
        \n - make sure graphics is set to Software. the other options are hardware, automatic
        \n  - save then
        \n  - run/launch the avd
        \n  - if you run; flutter devices then that avd should show up

        \n\n 5. run flutter doctor
        \n flutter doctor -v

        \n\n 6. create app
        \n flutter create hello

        \n\n 7. run app
        \n cd hello
        \n flutter run --enable-software-rendering --skia-deterministic-rendering --trace-startup --observatory-port 8111"
