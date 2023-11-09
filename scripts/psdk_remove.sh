#!/bin/bash

## Remove PlatformSDK from PC

## For snap

if [ ! -z "$SNAP_USER_COMMON" ]; then
    HOME=$(cd "$SNAP_USER_COMMON/../../.." && echo $PWD)
fi

## Variables

FOLDER=$HOME/AuroraPlatformSDK

## Check psdk

if [ ! -e "$FOLDER" ]; then
    echo "Already deleted!"
    exit 1
fi

## Remove

sudo rm -rf $HOME/AuroraPlatformSDK/
sudo rm -rf $HOME/.mersdk.profile
sudo rm -rf $HOME/.scratchbox2

bash

echo
echo "PlatformSDK successfully removed!"
