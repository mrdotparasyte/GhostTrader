// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract GhostTrader is Ownable {
    struct Config {
        uint8 minOrders;
        uint8 maxOrders;
    }
    Config config;
    ISwapRouter swapRouter;
    mapping(address => bool) admins;

    event Received(address sender, uint256 amount);

    modifier onlyOwnerOrAdmin() {
        _;
        require(
            msg.sender == owner() || admins[msg.sender] == true,
            "Only the owner or admin can execute this."
        );
    }

    constructor(
        address _router,
        address _owner,
        address[] memory _admins
    ) Ownable(_owner) {
        swapRouter = ISwapRouter(_router);
        config = Config({minOrders: 1, maxOrders: 3});
        for (uint8 i = 0; i < _admins.length; i++) {
            admins[_admins[i]] = true;
        }
    }

    function autoSell(
        ExactInputSingleParams[] memory orders
    ) external onlyOwnerOrAdmin {
        require(
            orders.length > 0 && orders.length <= type(uint8).max,
            "Invalid length"
        );
        uint256 totalAmountOut = 0;
        for (uint8 i = 0; i < orders.length; i++) {
            totalAmountOut += swapRouter.exactInputSingle(orders[i]);
        }
        ExactInputSingleParams memory order = orders[0];
        uint sellingLen = random(config.minOrders, config.maxOrders);
        ExactInputSingleParams[]
            memory sellingOrders = new ExactInputSingleParams[](sellingLen);
        uint256 remainAmount = totalAmountOut;
        for (uint8 i = 0; i < sellingOrders.length; i++) {
            uint256 amountIn = i == sellingLen - 1
                ? remainAmount
                : random(remainAmount / 10, remainAmount);
            remainAmount -= amountIn;
            sellingOrders[i] = ExactInputSingleParams({
                tokenIn: order.tokenOut,
                tokenOut: order.tokenIn,
                fee: order.fee,
                recipient: order.recipient,
                deadline: order.deadline,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
        }
        bundleTrade(sellingOrders);
    }

    function bundleTrade(
        ExactInputSingleParams[] memory orders
    ) public onlyOwnerOrAdmin {
        require(
            orders.length > 0 && orders.length <= type(uint8).max,
            "Invalid length"
        );
        for (uint8 i = 0; i < orders.length; i++) {
            swapRouter.exactInputSingle(orders[i]);
        }
    }

    function inverseTrade(
        ExactInputSingleParams memory order
    ) external onlyOwnerOrAdmin {
        uint256 amountOut = swapRouter.exactInputSingle(order);
        swapRouter.exactInputSingle(
            ExactInputSingleParams({
                tokenIn: order.tokenOut,
                tokenOut: order.tokenIn,
                fee: order.fee,
                recipient: order.recipient,
                deadline: order.deadline,
                amountIn: amountOut,
                amountOutMinimum: (order.amountIn / 1000) * 950,
                sqrtPriceLimitX96: 0
            })
        );
    }

    function addAdmin(address admin) external onlyOwnerOrAdmin {
        admins[admin] = true;
    }

    function removeAdmin(address admin) external onlyOwnerOrAdmin {
        admins[admin] = false;
    }

    function updateConfig(Config memory newConfig) external onlyOwnerOrAdmin {
        config = newConfig;
    }

    function approve(
        address token,
        address spender,
        uint256 value
    ) public onlyOwner returns (bool) {
        return IERC20(token).approve(spender, value);
    }

    function withdrawETH(address recipient) public onlyOwner {
        payable(recipient).transfer(address(this).balance);
    }

    function withdrawERC20(address token, address recipient) public onlyOwner {
        IERC20 erc20 = IERC20(token);
        erc20.transfer(recipient, erc20.balanceOf(address(this)));
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    fallback() external payable {
        emit Received(msg.sender, msg.value);
    }

    function random(
        uint minNumber,
        uint maxNumber
    ) public view returns (uint amount) {
        amount =
            uint(
                keccak256(
                    abi.encodePacked(block.timestamp, msg.sender, block.number)
                )
            ) %
            (maxNumber - minNumber);
        amount = amount + minNumber;
        return amount;
    }
}

struct ExactInputSingleParams {
    address tokenIn;
    address tokenOut;
    uint24 fee;
    address recipient;
    uint256 deadline;
    uint256 amountIn;
    uint256 amountOutMinimum;
    uint160 sqrtPriceLimitX96;
}

interface ISwapRouter {
    function exactInputSingle(
        ExactInputSingleParams calldata params
    ) external payable returns (uint256 amountOut);
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
}
