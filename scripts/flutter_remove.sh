#!/bin/bash

source $(dirname "$0")/snap_init.sh

###############################
## Remove Flutter for Aurora OS
###############################

## Get params keys

while getopts v: flag; do
  case "${flag}" in
  v) version=${OPTARG} ;;
  *)
    echo "usage: $0 [-v]" >&2
    exit 1
    ;;
  esac
done

## Variables

FOLDER="$HOME/.local/opt/flutter-$version"

## Check psdk

if [ ! -d "$FOLDER" ]; then
    echo
    echo "Flutter $version not found!"
    exit 1
fi

## Remove

rm -rf $FOLDER

echo
echo "Flutter for Aurora OS successfully removed!"
