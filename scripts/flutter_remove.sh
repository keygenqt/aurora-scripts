#!/bin/bash

source $(dirname "$0")/snap_init.sh

###############################
## Remove Flutter for OS Aurora
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

if [[ -z $version ]]; then
  echo 'Specify version!';
  exit;
fi

FOLDER="$HOME/.local/opt/flutter-$version"

## Check psdk

if [ ! -d "$FOLDER" ]; then
    echo
    echo "Flutter $version not found!"
    exit 1
fi

## Remove
rm -rf $FOLDER

## Clear .bashrc
sed -i "/$(echo "$FOLDER" | sed 's/\//\\\//g' | sed 's/\./\\./g')/d" "$HOME/.bashrc"

echo
echo "Flutter for Aurora OS successfully removed!"
