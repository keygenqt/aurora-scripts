#!/bin/bash

source $(dirname "$0")/snap_init.sh

################################
## Run application on the device
################################

## Get params keys

while getopts i:p:a: flag; do
  case "${flag}" in
  i) ip=${OPTARG} ;;
  p) port=${OPTARG} ;;
  a) application=${OPTARG} ;;
  *)
    echo "usage: $0 [-i] [-p] [-a]" >&2
    exit 1
    ;;
  esac
done

## Check params keys

if [ -z "$ip" ] || [ -z "$port" ] ||  [ -z "$application" ]; then
  echo "Specify device ip, port and application!"
  exit 1
fi

ssh -p "$port" defaultuser@"$ip" "/usr/bin/$application"
