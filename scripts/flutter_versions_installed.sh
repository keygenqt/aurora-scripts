#!/bin/bash

source $(dirname "$0")/snap_init.sh

###############################################
## Get installed versions Flutter for OS Aurora
###############################################

echo "Installed versions of Flutter SDK:"
echo

RESULT=$(ls $HOME/.local/opt/ | grep flutter | sed 's/flutter-//g')

if [ -z "$RESULT" ]; then
  echo 'Not found'
fi

ls $HOME/.local/opt/ | grep flutter | sed 's/flutter-//g'
