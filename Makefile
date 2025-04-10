install:
	@curl -L https://foundry.paradigm.xyz | bash
	@forge install https://github.com/OpenZeppelin/openzeppelin-contracts
	@forge install https://github.com/foundry-rs/forge-std

build:
	@forge build

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
	@forge script $(SCRIPT_PATH) --sig 'testAutoSell()' --rpc-url=$(TESTNET_RPC_URL)  --broadcast

test/withdraw:
	@forge script $(SCRIPT_PATH) --sig 'withdrawETH()' --rpc-url=$(TESTNET_RPC_URL)  --broadcast
	@forge script $(SCRIPT_PATH) --sig 'withdrawErc20()' --rpc-url=$(TESTNET_RPC_URL)  --broadcast