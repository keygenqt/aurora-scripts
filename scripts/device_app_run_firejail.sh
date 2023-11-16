#!/bin/bash

source $(dirname "$0")/snap_init.sh

#############################################
## Run application on the device in container
#############################################

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

## Run app in container

ssh -p "$port" defaultuser@"$ip" "invoker --type=qt5 $application"
