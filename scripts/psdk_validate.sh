#!/bin/bash

source $(dirname "$0")/snap_init.sh

#######################
## Validate RPM package
#######################

## Check psdk

if [ -z "$PSDK_DIR" ] || [ ! -d "$PSDK_DIR" ]; then
    echo "Not found environment PSDK_DIR. Install command - 'aurora-cli psdk --install'"
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

    FILENAME=$(basename -- "$file" | sed 's/.rpm//g' | sed 's/.RPM//g' )
    TARGET=$($PSDK_DIR/sdk-chroot sdk-assistant list | grep "${FILENAME##*.}" | head -n 1 | sed 's/└*─//g' | sed 's/├//g')

    echo
    $PSDK_DIR/sdk-chroot sb2 -t $TARGET -m emulate rpm-validator "$file"
  else
    if [ ${#files[@]} == 1 ]; then
        echo "No files found";
        exit
    fi
  fi
done
