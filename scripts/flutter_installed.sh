#!/bin/bash

source $(dirname "$0")/snap_init.sh

###############################################
## Get installed versions Flutter for OS Aurora
###############################################

if [ ! -d "$HOME/.local/opt" ]; then
  echo "Not found installed Flutter SDK."
  exit 1
fi

RESULT=$(ls $HOME/.local/opt/ | grep flutter- | sed 's/flutter-//g')

if [ ! "$DATA_ONLY" == "true" ]; then
  echo 'Installed Flutter SDK versions:'
  echo
fi

if [ ! -z "$RESULT" ]; then
  echo "$RESULT"
else
  if [ ! "$DATA_ONLY" == "true" ]; then
    echo "Not found installed Flutter SDK."
  fi
fi
