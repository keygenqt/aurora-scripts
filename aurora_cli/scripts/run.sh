#!/bin/bash

################################################
## Build and run dart application with arguments
################################################

cd aurora_cli

# Check config
if [ ! -f "configuration.yaml" ]; then
    cp ../configuration.yaml configuration.yaml
fi

# Clear
rm -rf .build
mkdir  .build

# Build
dart pub get > /dev/null 2>&1
dart compile exe bin/main.dart -o .build/aurora_cli > /dev/null 2>&1

# Run
.build/aurora_cli "$@"
