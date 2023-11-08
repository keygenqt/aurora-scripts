#!/bin/sh

## Check default config
if ! [ -f $SNAP_USER_COMMON/configuration.yaml ]; then
  cp $SNAP/def_configuration.yaml $SNAP_USER_COMMON/configuration.yaml
fi

## Run application
"$SNAP"/bin/aurora_cli "$@"
