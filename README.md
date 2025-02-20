# GhostTrader

## Makefile

```
RPC_URL ?= https://rpc.ankr.com/bsc
SCRIPT_PATH ?= script/GhostTrader.s.sol
TESTNET_RPC_URL ?= https://data-seed-prebsc-2-s3.binance.org:8545/
deploy:
	@forge script $(SCRIPT_PATH) --sig 'deploy()' --rpc-url=$(RPC_URL) --broadcast

approve:
	@forge script $(SCRIPT_PATH) --sig 'approveAll()' --rpc-url=$(RPC_URL) --broadcast

test/deploy:
	@forge script $(SCRIPT_PATH) --sig 'deploy()' --rpc-url=$(TESTNET_RPC_URL) --broadcast

test/approve:
	@forge script $(SCRIPT_PATH) --sig 'approveAll()' --rpc-url=$(TESTNET_RPC_URL) --broadcast

test/trade:
	@forge script $(SCRIPT_PATH) --sig 'testBundleTrade()' --rpc-url=$(TESTNET_RPC_URL)  --broadcast
	@forge script $(SCRIPT_PATH) --sig 'testInverseTrade()' --rpc-url=$(TESTNET_RPC_URL)  --broadcast
```

## Prerequisites


### Env
```
PRIVATE_KEY=
ADDRESS_EOA=
ADDRESS_CONTRACT=

# WBNB
TOKEN_QUOTE=

# CAKE, BEEPER...
TOKEN_BASE=
```

```
cp .env.example .env
```

Then set the `PRIVATE_KEY`, `TOKEN_QUOTE`, `TOKEN_BASE` and `ADDRESS_EOA`

### Installation

[Install foundry](https://book.getfoundry.sh/getting-started/installation#installation)

```
curl -L https://foundry.paradigm.xyz | bash
forge install https://github.com/OpenZeppelin/openzeppelin-contracts
forge install https://github.com/foundry-rs/forge-std
```

## Test

### Deploy

```
make test/deploy
```

Then set the `ADDRESS_CONTRACT` variable

### Approve

```
make test/approve
```

### Trade

```
make test/trade
```
