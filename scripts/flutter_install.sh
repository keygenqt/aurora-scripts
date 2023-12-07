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

## Get params keys

while getopts v: flag; do
  case "${flag}" in
  v) version=${OPTARG} ;;
  *)
    echo "usage: $0 [-v]" >&2
    exit 1
    ;;
  esac
done

if [[ -z $version ]]; then
  echo 'Specify flutter version!';
  exit;
fi

## Get versions

latest=$(curl -s https://gitlab.com/omprussia/flutter/flutter/-/raw/master/packages/flutter_tools/lib/src/version.dart \
| grep 'frameworkVersion: "' \
| sed 's/[",: ]//g' \
| sed 's/frameworkVersion//g')


olds=($(curl -s "https://gitlab.com/api/v4/projects/48571227/repository/branches?per_page=50&regex=flutter-aurora-\d" \
| grep -Po '"name":.*?[^\\]"' \
| sed 's/"//g' \
| sed 's/name:flutter-aurora-//g'))

## Get URL

if [[ "$version" == "$latest" ]]; then
  BRANCH="master"
else
  for i in "${olds[@]}"
  do
      if [ "$version" == "$i" ] ; then
          BRANCH="flutter-aurora-$version"
          break;
      fi
  done
fi

if [[ -z $BRANCH ]]; then
  echo "Version not found! To get versions run the command: 'aurora-cli flutter --versions'";
  exit;
fi

GIT_URL="https://gitlab.com/omprussia/flutter/flutter.git"
FOLDER="$HOME/.local/opt"
FLUTTER="$FOLDER/flutter-$version/bin/flutter"
TARGET=$($PSDK_DIR/sdk-chroot sdk-assistant list | grep armv7hl | head -n 1 | sed -e 's/├─//g')

## Checks

if [ -d "$FOLDER/flutter-$version" ]; then
  echo "Already installed!"
  exit 1
fi

## Check opt folder

if [ ! -d "$FOLDER" ]; then
  mkdir -p $FOLDER
fi

## Download

git clone $GIT_URL "$FOLDER/flutter-$version"
cd "$FOLDER/flutter-$version" && git checkout $BRANCH

## Add alias

if [[ -z $(grep "alias flutter-aurora-$version=/home/keygenqt/.local/opt/flutter-$version/bin/flutter" $HOME/.bashrc) ]]; then
  echo "alias flutter-aurora-$version=$HOME/.local/opt/flutter-$version/bin/flutter" >> $HOME/.bashrc
fi

## Remove compatibility

$PSDK_DIR/sdk-chroot \
  sb2 -t "$TARGET" -m sdk-install -R zypper rm -y flutter-embedder > /dev/null 2>&1

$PSDK_DIR/sdk-chroot \
  sb2 -t "$TARGET.default" -m sdk-install -R zypper rm -y flutter-embedder > /dev/null 2>&1

## Install compatibility

$PSDK_DIR/sdk-chroot \
  sb2 -t $TARGET -m sdk-install -R zypper --no-gpg-checks in -y \
  $FOLDER/flutter-$version/bin/cache/artifacts/aurora/arm/platform-sdk/compatibility/*.rpm > /dev/null 2>&1

$PSDK_DIR/sdk-chroot \
  sb2 -t $TARGET -m sdk-install -R zypper --no-gpg-checks in -y \
  $FOLDER/flutter-$version/bin/cache/artifacts/aurora/arm/platform-sdk/*.rpm > /dev/null 2>&1

$PSDK_DIR/sdk-chroot \
  sdk-assistant target remove --snapshots-of -y $TARGET

echo

$PSDK_DIR/sdk-chroot \
  sb2 -t $TARGET -R zypper search -s flutter | grep '|\|+'

## Run flutter

echo
$FLUTTER config --enable-aurora
echo

$FLUTTER --version

echo
echo "The alias 'flutter-aurora-$version' has been added, you can remove the version from it for convenience in the file $HOME/.bashrc"
echo

echo 'Done'
