#!/bin/bash

#########################
## Build dart application
#########################

cd aurora_cli || exit

# Check config
if [ ! -f "configuration.yaml" ]; then
    cp ../configuration.yaml configuration.yaml
fi

# Clear
rm -rf .build
mkdir  .build

# Build app
dart pub get
dart compile exe bin/main.dart -o .build/aurora_cli
