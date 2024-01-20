#!/bin/bash

#########################
## Build snap application
#########################

# Remove
sudo snap remove aurora-cli

# Build clean
snapcraft clean

# Build snap
snapcraft -v

# Install
sudo snap install aurora-cli_1.3.2_amd64.snap --devmode --dangerous

# Upload
# snapcraft upload --release=candidate <snap>
# snapcraft upload --release=stable <snap>
