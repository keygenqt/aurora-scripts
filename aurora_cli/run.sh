#!/bin/bash

rm -rf .build
mkdir  .build

dart compile exe bin/main.dart -o .build/aurora_cli > /dev/null 2>&1

.build/aurora_cli "$@"
