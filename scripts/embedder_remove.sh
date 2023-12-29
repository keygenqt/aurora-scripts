#!/bin/bash

source $(dirname "$0")/snap_init.sh

##########################
## Remove Flutter Embedder
##########################

## Get params keys

while getopts p: flag; do
  case "${flag}" in
  p) psdk=${OPTARG} ;;
  *)
    echo "usage: $0 [-p]" >&2
    exit 1
    ;;
  esac
done

## Check params keys

if [ -z "$psdk" ]; then
  echo "Specify Platfrom SDK path!"
  exit 1
fi

CHROOT="$psdk/sdks/aurora_psdk/sdk-chroot"

TAGETS=($($CHROOT sdk-assistant list 2>/dev/null | grep AuroraOS | grep -v default | sed -e 's/├─//g' | sed -e 's/└─//g'))

for target in "${TAGETS[@]}"
do
    $CHROOT sb2 -t "$target" -m sdk-install -R zypper rm -y flutter-embedder 2>/dev/null
    $CHROOT sb2 -t "$target" -m sdk-install -R zypper rm -y flutter-embedder-devel 2>/dev/null
done
