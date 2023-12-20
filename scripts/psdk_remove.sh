#!/bin/bash

source $(dirname "$0")/snap_init.sh

#############################
## Remove PlatformSDK from PC
#############################

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

## Check params keys

if [ -z "$folder" ]; then
  echo "Specify folder PSDK!"
  exit 1
fi

## Check psdk

if [ ! -d "$folder" ]; then
    echo
    echo "Platform SDK ($folder) not found!"
    exit 1
fi

## Remove
sudo rm -rf "$folder"

echo
echo "Platform SDK successfully removed!"
