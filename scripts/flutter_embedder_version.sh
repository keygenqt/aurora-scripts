#!/bin/bash

source $(dirname "$0")/snap_init.sh

#######################
## Get embedder version
#######################

## Check psdk

if [ -z "$PSDK_DIR" ] || [ ! -d "$HOME/AuroraPlatformSDK" ]; then
  echo "Not found PSDK. Install command - 'aurora-cli psdk --install'"
  echo "See more: https://developer.auroraos.ru/doc/software_development/psdk"
  exit 1
fi

TARGET=$($PSDK_DIR/sdk-chroot sdk-assistant list | grep armv7hl | head -n 1 | sed -e 's/├─//g')

RESULT=$($PSDK_DIR/sdk-chroot sb2 -t $TARGET -R zypper search -s flutter | grep '|\|+')

if [ -z "$RESULT" ]; then
  echo 'Not found embedder'
fi

$PSDK_DIR/sdk-chroot \
  sb2 -t $TARGET -R zypper search -s flutter | grep '|\|+'
