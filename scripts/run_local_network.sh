#!/bin/bash

source scripts/zombienet_setup.sh

zombienet-linux-x64 spawn --provider native local-network/config.toml
