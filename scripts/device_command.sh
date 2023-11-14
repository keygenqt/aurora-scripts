#!/bin/bash

source $(dirname "$0")/snap_init.sh

####################################
## Execute the command on the device
####################################

## Get params keys

while getopts i:p:c: flag; do
  case "${flag}" in
  i) ip=${OPTARG} ;;
  p) port=${OPTARG} ;;
  c) command=${OPTARG} ;;
  *)
    echo "usage: $0 [-i] [-c]" >&2
    exit 1
    ;;
  esac
done

## Check params keys

if [ -z "$ip" ] || [ -z "$port" ] ||  [ -z "$command" ]; then
  echo "Specify device ip, port and command!"
  exit 1
fi

ssh -p "$port" defaultuser@"$ip" "$command"
