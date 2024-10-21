## Flash Loans

Both Uniswap V2 and V3 implement flash loans: unlimited and uncollateralized loans that must be repaid in the same transaction. Pools give users arbitrary amounts of tokens that they request, but, by the end of the call, the amounts must be repaid, with a small fee on top.

The fact that flash loans must be repaid in the same transaction means that flash loans cannot be taken by regular users: as a user, you cannot program custom logic in transactions. Flash loans can only be taken and repaid by smart contracts.

Flash loans are a powerful financial instrument in DeFi. While it's often used to exploit vulnerabilities in DeFi protocols (by inflating pool balances and abusing flawed state management), it's many good applications (e.g. leveraged positions management on lending protocols)–this is why DeFi applications that store liquidity provide permissionless flash loans.

### Implementing Flash Loans

In Uniswap V2 flash loans were part of the swapping functionality: it was possible to borrow tokens during a swap, but you had to return them or an equal amount of the other pool token, in the same transaction. In V3, flash loans are separated from swapping–it's simply a function that gives the caller a number of tokens they requested, calls a callback on the caller, and ensures a flash loan was repaid:

```solidity
function flash(
    uint256 amount0,
    uint256 amount1,
    bytes calldata data
) public {
    uint256 balance0Before = IERC20(token0).balanceOf(address(this));
    uint256 balance1Before = IERC20(token1).balanceOf(address(this));

    if (amount0 > 0) IERC20(token0).transfer(msg.sender, amount0);
    if (amount1 > 0) IERC20(token1).transfer(msg.sender, amount1);

    IUniswapV3FlashCallback(msg.sender).uniswapV3FlashCallback(data);

    require(IERC20(token0).balanceOf(address(this)) >= balance0Before);
    require(IERC20(token1).balanceOf(address(this)) >= balance1Before);

    emit Flash(msg.sender, amount0, amount1);
}
```

The function sends tokens to the caller and then calls `uniswapV3FlashCallback` on it–this is where the caller is expected to repay the loan. Then the function ensures that its balances haven't decreased. Notice that custom data is allowed to be passed to the callback.

Here's an example of the callback implementation:

```solidity
function uniswapV3FlashCallback(bytes calldata data) public {
    (uint256 amount0, uint256 amount1) = abi.decode(
        data,
        (uint256, uint256)
    );

    if (amount0 > 0) token0.transfer(msg.sender, amount0);
    if (amount1 > 0) token1.transfer(msg.sender, amount1);
}
```

In this implementation, we're simply sending tokens back to the pool (I used this callback in `flash` function tests).  In reality, it can use the loaned amounts to perform some operations on other DeFi protocols. But it always must repay the loan in this callback.

And that's it!