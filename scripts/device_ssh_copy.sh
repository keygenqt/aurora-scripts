#!/bin/bash

source $(dirname "$0")/snap_init.sh

########################
## Add ssh key to device
########################

## Get params keys

while getopts i:p: flag; do
  case "${flag}" in
  i) ip=${OPTARG} ;;
  p) port=${OPTARG} ;;
  *)
    echo "usage: $0 [-i]" >&2
    exit 1
    ;;
  esac
done

## Check params keys

if [ -z "$ip" ] || [ -z "$port" ]; then
  echo "Specify device ip and port!"
  exit 1
fi

ssh-copy-id -p "$port" defaultuser@"$ip"
