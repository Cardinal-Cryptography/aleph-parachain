release:
	WASM_BUILD_WORKSPACE_HINT=${PWD} CARGO_TARGET_DIR=/tmp/alep-parachain/target/ cargo build --release && mkdir -p target/release && cp /tmp/alep-parachain/target/release/aleph-parachain-node target/release/

run:
	./scripts/run_local_network.sh
