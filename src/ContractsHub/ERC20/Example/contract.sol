// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import "@openzeppelin/contracts/utils/Address.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract testWallet {
    function authorizeTransfer(
        address contractaddress,
        address spender,
        uint256 amount
    ) public {
        IERC20 token = IERC20(contractaddress);
        bool success = token.approve(spender, amount);
        require(success, "Approval failed");
    }

    function transferTokens(
        address contractaddress,
        address recipient,
        uint256 amount
    ) public {
        IERC20 token = IERC20(contractaddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance >= amount, "Insufficient balance");

        bool success = token.transfer(recipient, amount);
        require(success, "Transfer failed");
    }

    fallback() external payable {}

    receive() external payable {}
}
