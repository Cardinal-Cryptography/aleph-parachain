#!/bin/bash

# Prepares zombienet for usage
#
# This script is meant to be run from repository root directory

cd local-network

# Check if zombienet binary is missing
if [ ! -f zombienet-linux-x64 ]; then

    # Download zombienet binary
    wget https://github.com/paritytech/zombienet/releases/download/v1.3.39/zombienet-linux-x64

    # Make it executable
    chmod +x zombienet-linux-x64
fi

if ! command -v polkadot &> /dev/null ; then

    # Setup zombienet: prepare polkadot binary.
    # Reports false errors.
    echo 'y' | ./zombienet-linux-x64 setup polkadot || true
fi

cd ..

docker build . -t aleph-parachain-node
