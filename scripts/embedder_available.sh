#!/bin/bash

source $(dirname "$0")/snap_init.sh

##########################################
## Get available versions Flutter Embedder
##########################################

if [ ! "$DATA_ONLY" == "true" ]; then
  echo "Available tags Flutter Embedder:"
  echo

  tags=($(curl -s "https://gitlab.com/api/v4/projects/53351457/repository/tags?per_page=50" \
    | grep -Po '"name":.*?[^\\]"' \
    | sed 's/"//g' \
    | sed 's/name://g'))

  for tag in "${tags[@]}"
  do
    IFS='-' read -r flutter embedder <<< "$tag"
    echo "($flutter) $embedder"
  done

else
  curl -s "https://gitlab.com/api/v4/projects/53351457/repository/tags?per_page=50" \
    | grep -Po '"name":.*?[^\\]"' \
    | sed 's/"//g' \
    | sed 's/name://g'
fi
