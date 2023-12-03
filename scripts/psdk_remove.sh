#!/bin/bash

source $(dirname "$0")/snap_init.sh

#############################
## Remove PlatformSDK from PC
#############################

## Variables

FOLDER=$HOME/AuroraPlatformSDK

## Check psdk

if [ ! -d "$FOLDER" ]; then
    echo
    echo "Already deleted!"
    exit 1
fi

## Remove

sudo rm -rf $HOME/AuroraPlatformSDK/
sudo rm -rf $HOME/.mersdk.profile
sudo rm -rf $HOME/.scratchbox2

echo
echo "PlatformSDK successfully removed!"
