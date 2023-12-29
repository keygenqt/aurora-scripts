#!/bin/bash

source $(dirname "$0")/snap_init.sh

######################################
## Get installed versions Platform SDK
######################################

PSDKS=($(find $HOME -maxdepth 3 -type d -name aurora_psdk))

if [ ! "$DATA_ONLY" == "true" ]; then
    if [ -n "$versions" ]; then
        echo "Not found installed Platform SDK."
    else
        echo 'Installed Platform SDK versions:'
        echo
    fi
fi

declare -a versions 

for psdk in "${PSDKS[@]}"
do
    if [ ! "$DATA_ONLY" == "true" ]; then
        versions+=("$(cat $psdk/etc/os-release | grep VERSION= | sed 's/VERSION="//g' | sed -z 's/"//g')")
    else
        versions+=("$(echo $psdk | sed -z 's/\/sdks\/aurora_psdk//g')")
    fi
done

if [ -n "$versions" ]; then
    printf '%s\n' "${versions[@]}"
fi
