#!/bin/bash

source $(dirname "$0")/snap_init.sh

################################################
## Sign RPM packages directly from the directory
################################################

## Check psdk

if [ -z "$PSDK_DIR" ] || [ ! -d "$HOME/AuroraPlatformSDK" ]; then
    echo "Not found PSDK. Install command - 'aurora-cli psdk --install'"
    echo "See more: https://developer.auroraos.ru/doc/software_development/psdk"
    exit 1
fi

## Get params keys

while getopts k:c: flag; do
  case "${flag}" in
  k) key=${OPTARG} ;;
  c) cert=${OPTARG} ;;
  *)
    echo "usage: $0 [-k] [-c]" >&2
    exit 1
    ;;
  esac
done

## Check params keys

if [ -z "$key" ] || ! [ -f "$key" ] || [ -z "$cert" ] || ! [ -f "$cert" ]; then
  echo "Specify paths to existing files!"
  exit 1
fi

## Get list rmp

RPMS=$(ls "$PWD" | grep -i .rpm | tr '\n' ';');

## List to array

IFS=';' read -r -a array <<< "$RPMS"

if [ -z "$array" ]; then
  echo "Not found RPM packeges. Go to the folder where there are rpm packages."
  exit 0
fi

## Aurora Platform SDK requires superuser rights

if ! [ -f "/etc/sudoers.d/mer-sdk-chroot" ]; then
  sudo echo
else
  echo
fi

## Sign array

for file in "${array[@]}"
do
  ## Remove sign if exist
  $PSDK_DIR/sdk-chroot rpmsign-external delete "$PWD/$file" > /dev/null 2>&1

  ## Sign
  RESULT=$($PSDK_DIR/sdk-chroot rpmsign-external sign --key "$key" --cert "$cert" "$PWD/$file" 2>&1)

  ## Check result
  if [[ $RESULT == *"Signed"* ]]; then
    echo "Signed: $file"
  else
    echo "Could not sign: $file"
  fi
done
