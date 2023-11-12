#!/bin/bash

####################################
## Execute the command on the device
####################################

## Get params keys

while getopts i:c: flag; do
  case "${flag}" in
  i) ip=${OPTARG} ;;
  c) command=${OPTARG} ;;
  *)
    echo "usage: $0 [-i] [-c]" >&2
    exit 1
    ;;
  esac
done

## Check params keys

if [ -z "$ip" ] ||  [ -z "$command" ]; then
  echo "Specify ip device and command!"
  exit 1
fi

ssh defaultuser@"$ip" "$command"
