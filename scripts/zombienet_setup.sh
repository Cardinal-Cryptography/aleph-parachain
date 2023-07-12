#!/bin/bash

# Prepares zombienet for usage
#
# This script is meant to be run from repository root directory

cd local-network

# Download zombienet binary and make it executable
zombienet_binary=zombienet-linux-x64
echo "zombienet_binary" $zombienet_binary
wget -nc https://github.com/paritytech/zombienet/releases/download/v1.3.39/$zombienet_binary
chmod +x $zombienet_binary

# Setup zombienet: prepare polkadot binary.
polkadot_binary=polkadot
echo "polkadot_binary" $polkadot_binary
wget -nc https://github.com/paritytech/polkadot/releases/download/v0.9.40/$polkadot_binary
chmod +x $polkadot_binary

cd ..

# docker build . -t aleph-parachain-node
