#!/bin/bash

source $(dirname "$0")/snap_init.sh

###############################################
## Get available versions Flutter for OS Aurora
###############################################

if [ ! "$DATA_ONLY" == "true" ]; then
  echo "Available Flutter SDK versions:"
  echo
fi

curl -s "https://gitlab.com/api/v4/projects/53055476/repository/tags?per_page=50" \
  | grep -Po '"name":.*?[^\\]"' \
  | sed 's/"//g' \
  | sed 's/name://g'
