#!/bin/bash

## Check psdk
if [ -z "$PSDK_DIR" ]; then
    echo "Not found PSDK_DIR. See more: https://developer.auroraos.ru/doc/software_development/psdk";
    exit 1;
fi

## Get list rmp
RPMS=$(ls $PWD | grep -i rpm | tr '\n' ';');

## List to array
IFS=';' read -r -a array <<< "$RPMS"

## Show array
echo "Files were found:";
echo
for line in "${array[@]}"
do
  echo "-> $line"
done
echo

## Next
echo "Sign successfully!"