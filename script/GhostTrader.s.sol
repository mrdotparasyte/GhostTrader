// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/GhostTrader.sol";
import {Script, console2} from "forge-std/Script.sol";

contract GhostTraderScript is Script {
    uint256 pk;
    address eoaAddress;
    address pancakeRouter = 0x1b81D678ffb9C0263b24A97847620C99d213eB14;
    address ghostTrader;
    address testToken = 0x8d008B313C1d6C7fE2982F62d32Da7507cF43551;
    address wbnb = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

    function setUp() public {
        pk = vm.envUint("PRIVATE_KEY");
        eoaAddress = vm.envAddress("ADDRESS_EOA");
        ghostTrader = vm.envAddress("ADDRESS_CONTRACT");
        testToken = vm.envAddress("TOKEN_BASE");
        wbnb = vm.envAddress("TOKEN_QUOTE");
    }

    function deploy() public {
        vm.startBroadcast(pk);
        GhostTrader trader = new GhostTrader(pancakeRouter);
        console2.log("GhostTrader deployed at:", address(trader));
        vm.stopBroadcast();
    }

    function approveAll() public {
        vm.startBroadcast(pk);
        GhostTrader trader = GhostTrader(ghostTrader);
        trader.approve(wbnb, pancakeRouter, type(uint256).max);
        trader.approve(testToken, pancakeRouter, type(uint256).max);
        vm.stopBroadcast();
    }

    // !!! withdraw to EOA
    function withdrawWBNB() public {
        vm.startBroadcast(pk);
        // GhostTrader trader = GhostTrader(ghostTrader);
        // trader.withdrawERC20(wbnb, eoaAddress);
        vm.stopBroadcast();
    }

    // bundle trade with multiple v3 pools
    function testMultiPoolsTrade() public {
        vm.startBroadcast(pk);

        GhostTrader trader = GhostTrader(ghostTrader);
        ExactInputSingleParams[] memory orders = new ExactInputSingleParams[](
            1
        );
        // v3 pool with 1% fee
        orders[0] = ExactInputSingleParams({
            tokenIn: wbnb,
            tokenOut: testToken,
            fee: 10000,
            recipient: ghostTrader,
            deadline: block.timestamp + 3600,
            amountIn: 1e15,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });
        // v3 pool with 0.01% fee
        orders[1] = ExactInputSingleParams({
            tokenIn: wbnb,
            tokenOut: testToken,
            fee: 100,
            recipient: ghostTrader,
            deadline: block.timestamp + 3600,
            amountIn: 1e15,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });

        trader.bundleTrade(orders);
        vm.stopBroadcast();
    }

    // bundle trade
    function testBundleTrade() public {
        vm.startBroadcast(pk);

        GhostTrader trader = GhostTrader(ghostTrader);
        ExactInputSingleParams[] memory orders = new ExactInputSingleParams[](
            1
        );
        orders[0] = ExactInputSingleParams({
            tokenIn: wbnb,
            tokenOut: testToken,
            fee: 10000,
            recipient: ghostTrader,
            deadline: block.timestamp + 3600,
            amountIn: 1e15,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });

        trader.bundleTrade(orders);
        vm.stopBroadcast();
    }

    // inverse trade
    function testInverseTrade() public {
        vm.startBroadcast(pk);

        GhostTrader trader = GhostTrader(ghostTrader);
        ExactInputSingleParams[] memory orders = new ExactInputSingleParams[](
            1
        );
        orders[0] = ExactInputSingleParams({
            tokenIn: wbnb,
            tokenOut: testToken,
            fee: 10000,
            recipient: ghostTrader,
            deadline: block.timestamp + 3600,
            amountIn: 1e15,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });
        trader.inverseTrade(orders[0]);
        vm.stopBroadcast();
    }
}
