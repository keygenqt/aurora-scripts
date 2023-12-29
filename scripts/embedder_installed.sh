#!/bin/bash

source $(dirname "$0")/snap_init.sh

##########################################
## Get installed versions Flutter Embedder
##########################################

## Get params keys

while getopts f: flag; do
  case "${flag}" in
  f) folder=${OPTARG} ;;
  *)
    echo "usage: $0 [-f]" >&2
    exit 1
    ;;
  esac
done

if [ -z "$folder" ]; then
  echo 'Specify folder!';
  exit;
fi

## Check psdk
if [ ! -d "$folder" ]; then
    echo
    echo "Platfrom SDK not found"
    exit 1
fi

CHROOT="$folder/sdks/aurora_psdk/sdk-chroot"

TAGETS=($($CHROOT sdk-assistant list 2>/dev/null | grep AuroraOS | grep -v default | sed -e 's/├─//g' | sed -e 's/└─//g'))

for target in "${TAGETS[@]}"
do
    if [[ "$target" == *"aarch64"* ]] || [[ "$target" == *"armv7hl"* ]] || [[ "$target" == *"x86_64"* ]]; then
        result=$($CHROOT sb2 -t $target -R zypper search --installed-only -s flutter 2>/dev/null | tail -1 | cut -d'|' -f4 | xargs)
        echo "$target: $result"
    fi
done
