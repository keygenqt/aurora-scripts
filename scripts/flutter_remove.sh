#!/bin/bash

## Remove Flutter for Aurora OS

## For snap

if [ ! -z "$SNAP_USER_COMMON" ]; then
    HOME=$(cd "$SNAP_USER_COMMON/../../.." && echo $PWD)
fi

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
