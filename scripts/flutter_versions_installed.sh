#!/bin/bash

source $(dirname "$0")/snap_init.sh

###############################################
## Get installed versions Flutter for OS Aurora
###############################################

if [ ! -d "$HOME/.local/opt" ]; then
  echo "Not found Flutter SDK!"
  exit 1
fi

echo "Installed versions of Flutter SDK:"
echo

RESULT=$(ls $HOME/.local/opt/ | grep flutter | sed 's/flutter-//g')

if [ -z "$RESULT" ]; then
  echo 'Not found'
fi

ls $HOME/.local/opt/ | grep flutter | sed 's/flutter-//g'
