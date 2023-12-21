#!/bin/bash

source $(dirname "$0")/snap_init.sh

################################
## Reinstall embedder by version
################################

## Check psdk

if [ -z "$PSDK_DIR" ] || [ ! -d "$PSDK_DIR" ]; then
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

FOLDER="$HOME/.local/opt/flutter-$version"
TARGET=$($PSDK_DIR/sdk-chroot sdk-assistant list | grep armv7hl | head -n 1 | sed -e 's/├─//g')

## Checks

if [ ! -d "$FOLDER" ]; then
  echo "Not found $FOLDER!"
  exit 1
fi

## Remove compatibility

$PSDK_DIR/sdk-chroot \
  sb2 -t "$TARGET" -m sdk-install -R zypper rm -y flutter-embedder > /dev/null 2>&1

$PSDK_DIR/sdk-chroot \
  sb2 -t "$TARGET.default" -m sdk-install -R zypper rm -y flutter-embedder > /dev/null 2>&1

## Install compatibility

$PSDK_DIR/sdk-chroot \
  sb2 -t $TARGET -m sdk-install -R zypper --no-gpg-checks in -y \
  $FOLDER/bin/cache/artifacts/aurora/arm/platform-sdk/compatibility/*.rpm > /dev/null 2>&1

$PSDK_DIR/sdk-chroot \
  sb2 -t $TARGET -m sdk-install -R zypper --no-gpg-checks in -y \
  $FOLDER/bin/cache/artifacts/aurora/arm/platform-sdk/*.rpm

$PSDK_DIR/sdk-chroot \
  sdk-assistant target remove --snapshots-of -y $TARGET > /dev/null 2>&1

echo

$PSDK_DIR/sdk-chroot \
  sb2 -t $TARGET -R zypper search -s flutter | grep '|\|+'

echo
echo 'Done'
