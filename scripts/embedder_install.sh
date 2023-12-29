#!/bin/bash

source $(dirname "$0")/snap_init.sh

###########################
## Install Flutter Embedder
###########################

## Get params keys

while getopts v:p: flag; do
  case "${flag}" in
  v) version=${OPTARG} ;;
  p) psdk=${OPTARG} ;;
  *)
    echo "usage: $0 [-v] [-p]" >&2
    exit 1
    ;;
  esac
done

## Check params keys

if [ -z "$version" ] || [ -z "$psdk" ]; then
  echo "Specify version embedder and Platfrom SDK path!"
  exit 1
fi

git clone --branch $version \
    --quiet \
    --depth 1  \
    --config advice.detachedHead=false \
    https://gitlab.com/omprussia/flutter/flutter-embedder.git


CHROOT="$psdk/sdks/aurora_psdk/sdk-chroot"

TAGETS=($($CHROOT sdk-assistant list 2>/dev/null | grep AuroraOS | grep -v default | sed -e 's/├─//g' | sed -e 's/└─//g'))

for target in "${TAGETS[@]}"
do
    arch=''

    if [[ "$target" == *"aarch64"* ]]; then
        arch='aarch64'
    fi
    if [[ "$target" == *"armv7hl"* ]]; then
        arch='armv7hl'
    fi
    if [[ "$target" == *"x86_64"* ]]; then
        arch='x86_64'
    fi

    if [ ! -z "$arch" ]; then
        psdk_key=''

        if [ ! -d "flutter-embedder/embedder/$arch" ]; then
            if [[ "$target" == *"-4."* ]]; then
                psdk_key='psdk_4'
            fi
            if [[ "$target" == *"-5."* ]]; then
                psdk_key='psdk_5'
            fi
        fi

        $CHROOT sb2 -t "$target" -m sdk-install -R zypper rm -y flutter-embedder 2>/dev/null
        $CHROOT sb2 -t "$target" -m sdk-install -R zypper rm -y flutter-embedder-devel 2>/dev/null

        if [ -z "$psdk_key" ]; then
            $CHROOT sb2 -t "$target" -m sdk-install -R zypper --no-gpg-checks in -y flutter-embedder/embedder/$arch/*.rpm 2>/dev/null
        else
            $CHROOT sb2 -t "$target" -m sdk-install -R zypper --no-gpg-checks in -y flutter-embedder/embedder/$psdk_key/$arch/*.rpm 2>/dev/null
        fi
    fi
done

rm -rf flutter-embedder
