#!/bin/bash

source $(dirname "$0")/snap_init.sh

#######################################
## Install latest Flutter for Aurora OS
#######################################

## Check psdk

if [ -z "$PSDK_DIR" ] || [ ! -d "$HOME/AuroraPlatformSDK" ]; then
  echo "Not found PSDK. Install command - 'aurora-cli psdk --install'"
  echo "See more: https://developer.auroraos.ru/doc/software_development/psdk"
  exit 1
fi

## Variables

GIT_URL="https://gitlab.com/omprussia/flutter/flutter/-/archive/master/flutter-master.tar.gz"
FOLDER="$HOME/.local/opt"
FLUTTER="$HOME/.local/opt/flutter/bin/flutter"
TARGET=$($PSDK_DIR/sdk-chroot sdk-assistant list | grep armv7hl | head -n 1 | sed -e 's/├─//g')

## Checks

if [ -d "$FOLDER/flutter" ]; then
  echo "Already installed!"
  exit 1
fi

## Check opt folder

if [ ! -d $FOLDER ]; then
  mkdir -p $FOLDER
fi

## Download

curl -s "$GIT_URL" --output $FOLDER/flutter-master.tar.gz
tar -xzf $FOLDER/flutter-master.tar.gz -C $FOLDER
rm -rf $FOLDER/flutter-master.tar.gz
mv $FOLDER/flutter-master $FOLDER/flutter
mkdir -p $FOLDER/flutter/.git

if [[ -z $(grep "flutter-aurora" $HOME/.bashrc) ]]; then
  echo "alias flutter-aurora=$HOME/.local/opt/flutter/bin/flutter" >> $HOME/.bashrc
fi

## Remove compatibility

$PSDK_DIR/sdk-chroot \
  sb2 -t "$TARGET" -m sdk-install -R zypper rm -y flutter-embedder > /dev/null 2>&1

$PSDK_DIR/sdk-chroot \
  sb2 -t "$TARGET.default" -m sdk-install -R zypper rm -y flutter-embedder > /dev/null 2>&1

## Install compatibility

$PSDK_DIR/sdk-chroot \
  sb2 -t $TARGET -m sdk-install -R zypper --no-gpg-checks in -y \
  $FOLDER/flutter/bin/cache/artifacts/aurora/arm/platform-sdk/compatibility/*.rpm > /dev/null 2>&1

$PSDK_DIR/sdk-chroot \
  sb2 -t $TARGET -m sdk-install -R zypper --no-gpg-checks in -y \
  $FOLDER/flutter/bin/cache/artifacts/aurora/arm/platform-sdk/*.rpm > /dev/null 2>&1

$PSDK_DIR/sdk-chroot \
  sdk-assistant target remove --snapshots-of -y $TARGET

## Run flutter

$FLUTTER config --enable-aurora > /dev/null 2>&1
$FLUTTER doctor

## Update

bash
