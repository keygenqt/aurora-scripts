#!/bin/bash

source $(dirname "$0")/snap_init.sh

#######################
## Install Platform SDK
#######################

## Get params keys

while getopts n:c:t:l: flag; do
  case "${flag}" in
  n) name=${OPTARG} ;;
  c) chroot=${OPTARG} ;;
  t) tooling=${OPTARG} ;;
  l) listTargets=${OPTARG} ;;
  *)
    echo "usage: $0 [-c] [-t] [-l]" >&2
    exit 1
    ;;
  esac
done

## Check params keys

if [ -z "$name" ] || [ -z "$chroot" ] || [ -z "$tooling" ]; then
  echo "Specify name, links chroot and tooling!"
  exit 1
fi

## Variables

USERNAME=$(basename "$HOME")
VERSION=${name##* }
FOLDER_NAME="Aurora_${name// /_}"
FOLDER_PATH="$HOME/$FOLDER_NAME"

URL_CHROOT="$chroot"
URL_TOOLING="$tooling"
IFS=';' read -ra URL_TARGETS <<< "$listTargets"

## Check psdk

if [ -d "$FOLDER_PATH" ]; then
  echo "$name already installed: $FOLDER_PATH"
  exit 1
fi

## Create folders

mkdir -pv "$FOLDER_PATH/toolings"
mkdir -pv "$FOLDER_PATH/tarballs"
mkdir -pv "$FOLDER_PATH/targets"
mkdir -pv "$FOLDER_PATH/sdks/aurora_psdk"

## Download
{
  curl "$URL_CHROOT" --output "$FOLDER_PATH/tarballs/$(basename "$URL_CHROOT")"
  curl "$URL_TOOLING" --output "$FOLDER_PATH/tarballs/$(basename "$URL_TOOLING")"

  for url in "${URL_TARGETS[@]}"
  do
    curl "$url" --output "$FOLDER_PATH/tarballs/$(basename "$url")"
  done

} || {
  echo 'Error download!'
  exit 1;
}

## Install Platform SDK

PSDK_DIR="$FOLDER_PATH/sdks/aurora_psdk"
CHROOT_IMG=$(find "$FOLDER_PATH/tarballs" -iname "*chroot*")
TOOLING_IMG=$(find "$FOLDER_PATH/tarballs" -iname "*tooling*")

sudo tar --numeric-owner -p -xjf "$CHROOT_IMG" --checkpoint=.1000 -C "$PSDK_DIR"

"$PSDK_DIR/sdk-chroot" sdk-assistant tooling create -y \
  "AuroraOS-$VERSION-base" \
  "$TOOLING_IMG"

for url in "${URL_TARGETS[@]}"
do
  ext=${url##*-}
  cpu=${ext%%.*}

  "$PSDK_DIR/sdk-chroot" sdk-assistant target create -y \
    "AuroraOS-$VERSION-base-$cpu" \
    "$FOLDER_PATH/tarballs/$(basename "$url")"
done

## Update bashrc

if ! grep "export PSDK_DIR=" "$HOME/.bashrc" > /dev/null; then
  echo "export PSDK_DIR=$FOLDER_PATH/sdks/aurora_psdk" >> "$HOME/.bashrc"
fi

alias="aurora_psdk"

if ! grep "alias aurora_psdk=" "$HOME/.bashrc" > /dev/null; then
  echo "alias $alias=$FOLDER_PATH/sdks/aurora_psdk/sdk-chroot" >> "$HOME/.bashrc"
else
  alias="aurora_psdk_$VERSION"
  if ! grep "alias $alias=" "$HOME/.bashrc" > /dev/null; then
    echo "alias $alias=$FOLDER_PATH/sdks/aurora_psdk/sdk-chroot" >> "$HOME/.bashrc"
  fi
fi

if [[ "$VERSION" == *"5."* ]]; then
  if ! grep "[AuroraPlatformSDK]" "$HOME/.bashrc" > /dev/null; then
    # shellcheck disable=SC2016
    echo 'if [[ $AURORA_SDK ]]; then PS1="[AuroraPlatformSDK]$ "; fi' >> "$HOME/.bashrc"
  fi
else
  rm -rf "$HOME"/.mersdk.profile
  echo 'PS1="[AuroraPlatformSDK]$ "' > "$HOME/.mersdk.profile"
fi

## Clear tarballs folder with downloads

rm -rf "$FOLDER"/tarballs/

## Disable sudo psdk

if ! grep "$FOLDER_PATH" "/etc/sudoers.d/mer-sdk-chroot" > /dev/null; then
sudo cat << EOF | sudo tee -a /etc/sudoers.d/mer-sdk-chroot
$USERNAME ALL=(ALL) NOPASSWD: $FOLDER_PATH/sdks/aurora_psdk/mer-sdk-chroot
Defaults!$FOLDER_PATH/sdks/aurora_psdk/mer-sdk-chroot env_keep += "SSH_AGENT_PID SSH_AUTH_SOCK"

EOF
fi

if ! grep "$FOLDER_PATH" "/etc/sudoers.d/sdk-chroot" > /dev/null; then
sudo cat << EOF | sudo tee -a /etc/sudoers.d/sdk-chroot
$USERNAME ALL=(ALL) NOPASSWD: $FOLDER_PATH/sdks/aurora_psdk/sdk-chroot
Defaults!$FOLDER_PATH/sdks/aurora_psdk/sdk-chroot env_keep += "SSH_AGENT_PID SSH_AUTH_SOCK"

EOF
fi

echo
echo "Done. Run command: $alias sdk-assistant list"
