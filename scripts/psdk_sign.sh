#!/bin/bash

source $(dirname "$0")/snap_init.sh

################################################
## Sign RPM packages directly from the directory
################################################

## Check psdk

if [ -z "$PSDK_DIR" ] || [ ! -d "$PSDK_DIR" ]; then
    echo "Not found environment PSDK_DIR. Install command - 'aurora-cli psdk --install'"
    echo "See more: https://developer.auroraos.ru/doc/software_development/psdk"
    exit 1
fi

## Get params keys

while getopts k:c:p: flag; do
  case "${flag}" in
  k) key=${OPTARG} ;;
  c) cert=${OPTARG} ;;
  p) path=${OPTARG} ;;
  *)
    echo "usage: $0 [-k] [-c]" >&2
    exit 1
    ;;
  esac
done

## Check params keys

if [ -z "$key" ] || ! [ -f "$key" ] || [ -z "$cert" ] || ! [ -f "$cert" ]; then
  echo "Specify paths to existing key and cert files!"
  exit 1
fi

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
  sudo echo 'Accessed...'
fi

## Sign array

for file in "${files[@]}"
do
  ## Remove sign if exist
  $PSDK_DIR/sdk-chroot rpmsign-external delete "$file" > /dev/null 2>&1

  ## Sign
  RESULT=$($PSDK_DIR/sdk-chroot rpmsign-external sign --key "$key" --cert "$cert" "$file" 2>&1)

  ## Check result
  if [[ $RESULT == *"Signed"* ]]; then
    echo "Signed: $file"
  else
    echo "Could not sign: $file"
  fi
done
