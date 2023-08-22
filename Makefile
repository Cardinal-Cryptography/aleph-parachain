export PATH := local-network/:$(PATH)

.PHONY: help
help: # Show help for each of the Makefile recipes.
	@grep -E '^[a-zA-Z0-9 -/]+:.*#'  Makefile | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done

.PHONY: test
test: # Run all unit tests.
	cargo test

.PHONY: lint
lint: # Run all lints.
lint: clippy rustfmt

.PHONY: ci
ci: # Run all CI checks.
ci: lint test parachain-progress-test

.PHONY: clippy
clippy: # Run clippy lints.
	cargo clippy -- -D warnings

.PHONY: rustfmt
rustfmt: # Check formatting
	cargo fmt --all --check

.PHONY: parachain-progress-test
parachain-progress-test: # Run the parachain progress test.
parachain-progress-test: zombienet short-session-node-image
	zombienet-linux-x64 test --provider native tests/zombienet/parachain_progress.zndsl

.PHONY: run-local-network
run-local-network: # Run a test network of 4 relay validators and 2 parachain collators.
run-local-network: short-session-node-image zombienet
	zombienet-linux-x64 spawn --provider native local-network/config.toml

.PHONY: zombienet
zombienet: # Download all zombienet binaries.
zombienet: local-network/polkadot local-network/zombienet-linux-x64

local-network/polkadot: # Download the polkadot binary.
	wget -nc https://github.com/paritytech/polkadot/releases/download/v0.9.40/polkadot -P /tmp
	mv /tmp/polkadot local-network/
	chmod +x local-network/polkadot

local-network/zombienet-linux-x64: # Download the zombienet binary.
	wget -nc https://github.com/paritytech/zombienet/releases/download/v1.3.56/zombienet-linux-x64 -P /tmp
	mv /tmp/zombienet-linux-x64 local-network/
	chmod +x local-network/zombienet-linux-x64

.PHONY: short-session-node
short-session-node: # Rebuild the parachain node in release mode with short-session enabled (for use in local testing).
	cargo build --release -p aleph-parachain-node -F short-session

.PHONY: short-session-node-image
short-session-node-image: # Build a docker image for the parachain node in release mode with short-session enabled (for use in local testing).
short-session-node-image: short-session-node
	docker build -t aleph-parachain-node .
