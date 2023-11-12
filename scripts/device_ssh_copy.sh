#!/bin/bash

########################
## Add ssh key to device
########################

## Get params keys

while getopts i: flag; do
  case "${flag}" in
  i) ip=${OPTARG} ;;
  *)
    echo "usage: $0 [-i]" >&2
    exit 1
    ;;
  esac
done

## Check params keys

if [ -z "$ip" ]; then
  echo "Specify ip device!"
  exit 1
fi

ssh-copy-id defaultuser@"$ip"
