#!/bin/bash

source $(dirname "$0")/snap_init.sh

################################
## Install 4.0.2.249 PlatformSDK
################################

## Variables

URL_CHROOT="https://sdk-repo.omprussia.ru/sdk/installers/4.0.2/PlatformSDK/4.0.2.249/Aurora_OS-4.0.2.249-base-Aurora_Platform_SDK_Chroot-i486.tar.bz2"
URL_TOOLING="https://sdk-repo.omprussia.ru/sdk/installers/4.0.2/PlatformSDK/4.0.2.249/Aurora_OS-4.0.2.249-base-Aurora_SDK_Tooling-i486.tar.bz2"
URL_TARGET_armv7hl="https://sdk-repo.omprussia.ru/sdk/installers/4.0.2/PlatformSDK/4.0.2.249/Aurora_OS-4.0.2.249-base-Aurora_SDK_Target-armv7hl.tar.bz2"
URL_TARGET_i486="https://sdk-repo.omprussia.ru/sdk/installers/4.0.2/PlatformSDK/4.0.2.249/Aurora_OS-4.0.2.249-base-Aurora_SDK_Target-i486.tar.bz2"

USERNAME=$(basename $HOME)
FOLDER=$HOME/AuroraPlatformSDK
NAME=$(basename $URL_TOOLING | sed s/.tar.[a-z]*[0-9]*//g | sed s/-base-Aurora_SDK_Tooling-i486//g )

## Check psdk

if [ -d "$FOLDER" ]; then
  echo "Already installed!"
  exit 1
fi

## Clear if exist

rm -rf $HOME/.mersdk.profile
rm -rf $HOME/.scratchbox2

## Create folders

mkdir -pv $HOME/AuroraPlatformSDK/targets
mkdir -pv $HOME/AuroraPlatformSDK/toolings
mkdir -pv $HOME/AuroraPlatformSDK/tarballs
mkdir -pv $HOME/AuroraPlatformSDK/sdks/aurora_psdk

## Download

{
  curl "$URL_CHROOT" --output $FOLDER/tarballs/chroot.tar.bz2
  curl "$URL_TOOLING" --output $FOLDER/tarballs/tooling.tar.bz2
  curl "$URL_TARGET_armv7hl" --output $FOLDER/tarballs/target_armv7hl.tar.bz2
  curl "$URL_TARGET_i486" --output $FOLDER/tarballs/target_i486.tar.bz2
} || {
  echo 'Error download!'
  exit 1;
}


## Install Platform SDK

PSDK_DIR=$HOME/AuroraPlatformSDK/sdks/aurora_psdk
CHROOT_IMG=$(find $HOME/AuroraPlatformSDK/tarballs -iname "*chroot*")

sudo tar --numeric-owner -p -xjf $CHROOT_IMG --checkpoint=.1000 -C $PSDK_DIR

$PSDK_DIR/sdk-chroot sdk-assistant tooling create -y \
  $NAME \
  $HOME/AuroraPlatformSDK/tarballs/tooling.tar.bz2

$PSDK_DIR/sdk-chroot sdk-assistant target create -y \
  $NAME-i486 \
  $HOME/AuroraPlatformSDK/tarballs/target_i486.tar.bz2

$PSDK_DIR/sdk-chroot sdk-assistant target create -y \
  $NAME-armv7hl \
  $HOME/AuroraPlatformSDK/tarballs/target_armv7hl.tar.bz2

## Add data

if [[ -z $(grep "export PSDK_DIR" $HOME/.bashrc) ]]; then
  echo 'export PSDK_DIR=$HOME/AuroraPlatformSDK/sdks/aurora_psdk' >> $HOME/.bashrc
fi

if [[ -z $(grep "alias aurora_psdk" $HOME/.bashrc) ]]; then
  echo 'alias aurora_psdk=$PSDK_DIR/sdk-chroot' >> $HOME/.bashrc
fi

echo 'PS1="[AuroraPlatformSDK]$ "' > $HOME/.mersdk.profile

## Set default armv7hl

$PSDK_DIR/sdk-chroot \
  sb2-config -d \
  $NAME-armv7hl

## Clear tarballs folder with downloads

rm -rf $FOLDER/tarballs/

## Disable sudo psdk

if [ ! -f "/etc/sudoers.d/mer-sdk-chroot" ]; then
sudo cat << EOF | sudo tee -a /etc/sudoers.d/mer-sdk-chroot
$USERNAME ALL=(ALL) NOPASSWD: /home/$USERNAME/AuroraPlatformSDK/sdks/aurora_psdk/mer-sdk-chroot
Defaults!/home/$USERNAME/AuroraPlatformSDK/sdks/aurora_psdk/mer-sdk-chroot env_keep += "SSH_AGENT_PID SSH_AUTH_SOCK"
EOF
fi

if [ ! -f "/etc/sudoers.d/sdk-chroot" ]; then
sudo cat << EOF | sudo tee -a /etc/sudoers.d/sdk-chroot
$USERNAME ALL=(ALL) NOPASSWD: /home/$USERNAME/AuroraPlatformSDK/sdks/aurora_psdk/sdk-chroot
Defaults!/home/$USERNAME/AuroraPlatformSDK/sdks/aurora_psdk/sdk-chroot env_keep += "SSH_AGENT_PID SSH_AUTH_SOCK"
EOF
fi

echo
echo 'Done'
