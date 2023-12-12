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
    echo "usage: $0 [-i] [-p] [-a] [-f]" >&2
    exit 1
    ;;
  esac
done

## Check params keys

if [ -z "$ip" ] || [ -z "$port" ] ||  [ -z "$application" ]; then
  echo "Specify device ip, port and application!"
  exit 1
fi

## Run app
if [[ $ip == *"AuroraOS"* ]]; then
  ssh -i $HOME/AuroraOS/vmshare/ssh/private_keys/sdk -p $port defaultuser@localhost "/usr/bin/$application"
else
  ssh -p "$port" defaultuser@"$ip" "/usr/bin/$application"
fi
