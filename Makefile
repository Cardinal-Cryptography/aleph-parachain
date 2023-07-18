watch:
	cargo watch -s 'WASM_BUILD_WORKSPACE_HINT=${PWD} CARGO_TARGET_DIR=/tmp/aleph-parachain/target/ cargo clippy -- -D warnings' -c

clippy:
	WASM_BUILD_WORKSPACE_HINT=${PWD} CARGO_TARGET_DIR=/tmp/aleph-parachain/target/ cargo clipy -- -D warnings

test:
	WASM_BUILD_WORKSPACE_HINT=${PWD} CARGO_TARGET_DIR=/tmp/aleph-parachain/target/ cargo test

release:
	WASM_BUILD_WORKSPACE_HINT=${PWD} CARGO_TARGET_DIR=/tmp/aleph-parachain/target/ cargo build --release && mkdir -p target/release && cp /tmp/alep-parachain/target/release/aleph-parachain-node target/release/

run:
	./scripts/run_local_network.sh
