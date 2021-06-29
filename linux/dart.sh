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

FLUTTER_VERSION=flutter_linux_2.2.2-stable

printf "\n\n  install dart"
sudo sh -c 'curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_unstable.list > /etc/apt/sources.list.d/dart_unstable.list'
sudo apt -y update
sudo apt -y install dart

printf "\n\n  download flutter\n"
sudo wget -nc --output-document="/usr/local/flutter.tar.xz" "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/$FLUTTER_VERSION.tar.xz"

printf "\n\n  untar flutter file\n"
sudo tar xf "/usr/local/flutter.tar.xz" -C /usr/local/

printf "\n\n add flutter profile\n"
DART_CONFIG_FILE_CONTENTS='#dart and flutter
export PATH=$PATH:/usr/local/flutter/bin
export PATH=$PATH:/usr/lib/dart/bin'
DART_CONFIG_FILE=/etc/profile
sudo touch "$DART_CONFIG_FILE"
grep -qF -- "$DART_CONFIG_FILE_CONTENTS" "$DART_CONFIG_FILE" || echo "$DART_CONFIG_FILE_CONTENTS" >> "$DART_CONFIG_FILE"

printf "\n\n  give user perms on flutter dir\n"
sudo chown -R $MY_NAME /usr/local/flutter

printf "\n\n  check flutter version\n"
export PATH=$PATH:/usr/local/flutter/bin && \
export PATH=$PATH:/usr/lib/dart/bin
flutter --version

# install_android_studio(){
#     # Do we need this when I've got Vscode?

#     printf "\n\n  download android-studio\n"
#     wget -nc --output-document=/usr/local/android-studio-ide-linux.zip https://redirector.gvt1.com/edgedl/android/studio/ide-zips/4.2.1.0/android-studio-ide-202.7351085-linux.tar.gz

#     printf "\n\n  unzip android-studio file\n"
#     unzip /usr/local/android-studio-ide-linux.zip -d /usr/local/android-studio/

#     printf "\n\n  install kvm(useful for android emulator acceleration)\n"
#     apt -y update; apt -y install qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils

#     printf "\n\n  verify kvm install\n"
#     virsh list --all

#     printf "\n\n  instructions for manual things to do:\n"
#     printf "\n 1.you can start android-studio using;
#             \n /usr/local/android-studio/bin/studio.sh

#             \n\n 2. accept android licenses using;
#             \n flutter doctor --android-licenses

#             \n\n 3. install dart/flutter plugins in android-studio;
#             \n File>Settings>Plugins

#             \n\n 4. select virtual device in android-studio;
#             \n Tools>AVD Manager>create a device
#             \n - if unsure; use pixel2 and oreo android version.
#             \n - make sure graphics is set to Software. the other options are hardware, automatic
#             \n  - save then
#             \n  - run/launch the avd
#             \n  - if you run; flutter devices then that avd should show up

#             \n\n 5. run flutter doctor
#             \n flutter doctor -v

#             \n\n 6. create app
#             \n flutter create hello

#             \n\n 7. run app
#             \n cd hello
#             \n flutter run --enable-software-rendering --skia-deterministic-rendering --trace-startup --observatory-port 8111"
# }
# install_android_studio
