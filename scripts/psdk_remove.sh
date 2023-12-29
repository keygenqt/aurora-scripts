#!/bin/bash

source $(dirname "$0")/snap_init.sh

######################
## Remove Platform SDK
######################

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

if [[ -z $folder ]]; then
  echo 'Specify folder!';
  exit;
fi

## Check psdk

if [ ! -d "$folder" ]; then
    echo
    echo "Platfrom SDK not found"
    exit 1
fi

## Remove
sudo rm -rf $folder

## Clear .bashrc
sed -i "/$(echo "$folder" | sed 's/\//\\\//g' | sed 's/\./\\./g')/d" "$HOME/.bashrc"

echo
echo "Platform SDK successfully removed!"
