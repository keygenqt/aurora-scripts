#!/bin/bash

########################
## Add ssh key to device
########################

## For snap

if [ ! -z "$SNAP_USER_COMMON" ]; then
    HOME=$(cd "$SNAP_USER_COMMON/../../.." && echo $PWD)
fi

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

ssh-copy-id -i $HOME/.ssh/id_rsa.pub defaultuser@"$ip"
