#!/bin/bash

source $(dirname "$0")/snap_init.sh

###############################
## Remove Flutter for Aurora OS
###############################

## Variables

FOLDER=$HOME/.local/opt/flutter

## Check psdk

if [ ! -d "$FOLDER" ]; then
    echo
    echo "Already deleted!"
    exit 1
fi

## Remove

rm -rf $FOLDER

bash

echo
echo "Flutter for Aurora OS successfully removed!"
