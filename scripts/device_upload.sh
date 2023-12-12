#!/bin/bash

source $(dirname "$0")/snap_init.sh

#########################
## Upload files to device
#########################

## Get params keys

while getopts i:p:u: flag; do
  case "${flag}" in
  i) ip=${OPTARG} ;;
  p) port=${OPTARG} ;;
  u) upload=${OPTARG} ;;
  *)
    echo "usage: $0 [-i] [-p] [-u]" >&2
    exit 1
    ;;
  esac
done

## Check params keys

if [ -z "$ip" ] || [ -z "$port" ] ||  [ -z "$upload" ]; then
  echo "Specify device ip, port and upload!"
  exit 1
fi

## Path to array

readarray -t files <<< $upload

if [[ $upload == *"*"* ]]; then
  files=($upload)
fi

## Check size files

if [ ${#files[@]} == 0 ]; then
    echo "No files found";
    exit
fi

## Uploads

for file in "${files[@]}"
do
  if [[ $ip == *"AuroraOS"* ]]; then
    scp -i $HOME/AuroraOS/vmshare/ssh/private_keys/sdk -P "$port" "$file" "defaultuser@localhost:~/Downloads"
  else
    scp -P "$port" "$file" "defaultuser@$ip:~/Downloads"
  fi
done

echo "Upload successful from: $upload";
