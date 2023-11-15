#!/bin/bash

source $(dirname "$0")/snap_init.sh

#########################
## Install rpm to device
#########################

## Get params keys

while getopts i:p:r:s: flag; do
  case "${flag}" in
  i) ip=${OPTARG} ;;
  p) port=${OPTARG} ;;
  r) rpm=${OPTARG} ;;
  s) su=${OPTARG} ;;
  *)
    echo "usage: $0 [-i] [-p] [-r] [-s]" >&2
    exit 1
    ;;
  esac
done

## Check params keys

if [ -z "$ip" ] || [ -z "$port" ] || [ -z "$rpm" ] || [ -z "$su" ]; then
  echo "Specify device ip, port, password and rpm file!"
  exit 1
fi

if ! [ -f "$rpm" ]; then
  echo "File not found"
  exit 1
fi

if [[ $upload == *"rpm" ]]; then
  echo "File not rpm"
  exit 1
fi

filename=$(basename $rpm)

## Upload rpm file for install

scp -P "$port" "$rpm" "defaultuser@$ip:~/Downloads"

## Try install

result=$(ssh -p "$port" "defaultuser@$ip" "echo $su | devel-su pkcon -y install-local ~/Downloads/$filename" &> /dev/null || echo "error")

## Remove rpm file

ssh -p "$port" "defaultuser@$ip" "rm ~/Downloads/$filename" > /dev/null 2>&1

## Output

if [[ $result == *"error"* ]]; then
  echo "Installation failed!";
  exit 1
else
  echo "Install successful!";
fi
