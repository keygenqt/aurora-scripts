#!/bin/bash

###################
## Gen changelog.md
###################

changeln -t ./.changeln.template \
    -c ./.changeln.yaml \
    -p ./ \
    changelog markdown
