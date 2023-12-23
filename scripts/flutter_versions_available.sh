#!/bin/bash

source $(dirname "$0")/snap_init.sh

##########################################
## Get list versions Flutter for OS Avrora
##########################################

## Get params keys

while getopts d: flag; do
  case "${flag}" in
  d) detail=${OPTARG} ;;
  *)
    echo "usage: $0 [-d]" >&2
    exit 1
    ;;
  esac
done

if [ ! -z "$detail" ] && [ "$detail" == "true" ]; then
    echo "Available Flutter SDK versions:"
    echo
fi

latest=$(curl -s https://gitlab.com/omprussia/flutter/flutter/-/raw/master/packages/flutter_tools/lib/src/version.dart \
| grep 'frameworkVersion: "' \
| sed 's/[",: ]//g' \
| sed 's/frameworkVersion//g')


old=$(curl -s "https://gitlab.com/api/v4/projects/48571227/repository/branches?per_page=50&regex=flutter-aurora-\d" \
| grep -Po '"name":.*?[^\\]"' \
| sed 's/"//g' \
| sed 's/name:flutter-aurora-//g')

if [ ! -z "$detail" ] && [ "$detail" == "true" ]; then
    echo "$latest (latest)"
    echo "$old"
else
    echo "$latest"
    echo "$old"
fi
