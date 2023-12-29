#!/bin/bash

source $(dirname "$0")/snap_init.sh

################################
## Install Flutter for OS Aurora
################################

## Get params keys

while getopts v: flag; do
  case "${flag}" in
  v) version=${OPTARG} ;;
  *)
    echo "usage: $0 [-v]" >&2
    exit 1
    ;;
  esac
done

if [[ -z $version ]]; then
  echo 'Specify version!';
  exit;
fi

GIT_URL="https://gitlab.com/omprussia/flutter/flutter.git"
FOLDER="$HOME/.local/opt"
FLUTTER="$FOLDER/flutter-$version/bin/flutter"

## Checks

if [ -d "$FOLDER/flutter-$version" ]; then
  echo "Already installed!"
  exit 1
fi

## Check opt folder

if [ ! -d "$FOLDER" ]; then
  mkdir -p $FOLDER
fi

## Download

git clone --branch $version \
 --depth 1  \
 --config advice.detachedHead=false \
  "$GIT_URL" \
  "$FOLDER/flutter-$version"

## Add alias

if [[ -z $(grep "alias flutter-aurora-$version=$FOLDER/flutter-$version/bin/flutter" $HOME/.bashrc) ]]; then
  echo "alias flutter-aurora-$version=$FOLDER/flutter-$version/bin/flutter" >> $HOME/.bashrc
fi

## Run flutter

echo
$FLUTTER config --enable-aurora
echo
$FLUTTER doctor
echo
echo "The alias 'flutter-aurora-$version' has been added, you can change alias in the file $HOME/.bashrc"
echo "To build you will need Flutter Embedder, see the embedder section of the application."
