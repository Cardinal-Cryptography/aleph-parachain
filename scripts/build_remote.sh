#!/bin/bash

cargo clean

mkdir -p target/release

cargo remote -c release/aleph-parachain-node -- build --release
