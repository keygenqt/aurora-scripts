#!/bin/bash

source $(dirname "$0")/snap_init.sh

##########################################
## Get list versions Flutter for OS Avrora
##########################################

echo "Available Flutter SDK versions:"
echo

latest=$(curl -s https://gitlab.com/omprussia/flutter/flutter/-/raw/master/packages/flutter_tools/lib/src/version.dart \
| grep 'frameworkVersion: "' \
| sed 's/[",: ]//g' \
| sed 's/frameworkVersion//g')


old=$(curl -s "https://gitlab.com/api/v4/projects/48571227/repository/branches?per_page=50&regex=flutter-aurora-\d" \
| grep -Po '"name":.*?[^\\]"' \
| sed 's/"//g' \
| sed 's/name:flutter-aurora-//g')

echo "$latest (latest)"
echo "$old"
echo
echo "You can install it by running the command: 'aurora-cli flutter --install <version>'"
