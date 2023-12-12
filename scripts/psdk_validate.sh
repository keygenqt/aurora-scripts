#!/bin/bash

source $(dirname "$0")/snap_init.sh

#######################
## Validate RPM package
#######################

## Check psdk

if [ -z "$PSDK_DIR" ] || [ ! -d "$HOME/AuroraPlatformSDK" ]; then
    echo "Not found PSDK. Install command - 'aurora-cli psdk --install'"
    echo "See more: https://developer.auroraos.ru/doc/software_development/psdk"
    exit 1
fi

## Get params keys

while getopts p: flag; do
  case "${flag}" in
  p) path=${OPTARG} ;;
  *)
    echo "usage: $0 [-p]" >&2
    exit 1
    ;;
  esac
done

## Path to array

readarray -t files <<< $path

if [[ $path == *"*"* ]]; then
  files=($path)
fi

## Check size files

if [ ${#files[@]} == 0 ]; then
    echo "No files found";
    exit
fi

## Aurora Platform SDK requires superuser rights

if ! [ -f "/etc/sudoers.d/mer-sdk-chroot" ]; then
  sudo echo 'Sign...'
fi

## Validate array

for file in "${files[@]}"
do

  if [ -f "$file" ]; then
    echo
    echo "Validate file: '$file'"
    echo
    $PSDK_DIR/sdk-chroot sb2 -m emulate rpm-validator "$file"
  else
    if [ ${#files[@]} == 1 ]; then
        echo "No files found";
        exit
    fi
  fi
done
