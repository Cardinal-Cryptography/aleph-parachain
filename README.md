# Aleph Parachain

The Aleph Parachain collator and associated testing and deployment code.

## Common tasks

Various common tasks are scripted as `make` commands. Run `make help` to see a list.

### Run local test network

You can run a simple local network using `make run-local-network`.

This script uses zombienet to run the network, the configuration file can be found
at `local-network/config.toml`.

### Checks

You can `make test` to run all unit tests, `make lint` to run all lints or `make ci` to
run all checks that the CI would run, including integration tests.