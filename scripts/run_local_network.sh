#!/bin/bash

# Runs local network with
# - 4 validator relay chain (rococo)
# - 2 collator aleph parachain
#
# Meant to be run from repository root directory

source scripts/zombienet_setup.sh

zombienet-linux-x64 spawn --provider native local-network/config.toml
