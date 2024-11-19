# [staticCall](https://www.rareskills.io/post/solidity-staticcall)
1. `staticcall{gas: gasAmount}(abiEncodedArguments);`
2. 底层 `call` 外部合约函数读取数据
   1. 函数必须被 `view|pure` 修饰，表明只读
3. 天然适用于 [预编译合约](contracts-precompile.md)
4. `staticcall` 无法更新状态变量:
   1. 更新合约内部的状态变量
   2. emit event 触发链上事件
   3. 创建其他合约
   4. self destruct 销毁合约（将code数据从状态树中移除）
   5. 转账，更新账户余额
   6. 调用其他未标记 pure/view的函数
   7. 使用内联编码更改状态数据库
## Solidity Examples
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IERC20 {
    function balanceOf(address) external view returns (uint256);
}

contract Token is IERC20 {
    mapping(address => uint256) balance;

    function mint(address addr, uint256 qty) external {
        balance[addr] += qty;
    }

    function balanceOf(address addr) external view returns (uint256) {
        return balance[addr];
    }
}

contract ERC20User {
    // 5837 gas cost
    function myBalance(IERC20 token, address addr)
        public
        view
        returns (uint256 balance)
    {
        balance = token.balanceOf(addr);
    }

    // 6294 gas cost
    function myBalanceLowLevelEquivalent(IERC20 token, address addr)
        public
        view
        returns (uint256 balance)
    {
        (bool ok, bytes memory result) = address(token).staticcall(
            abi.encodeWithSignature("balanceOf(address)", addr)
        );
        require(ok);

        balance = abi.decode(result, (uint256));
    }
}
```
## Security Issues
### Denial of Service
`staticCall` 支持指定gas[63/64](https://www.rareskills.io/post/eip-150-and-the-63-64-rule-for-gas)执行只读的调用，但是对方函数逻辑不明，存在恶意消耗`gas`的安全隐患
### Read only Re-entrancy
只读函数会受到其他函数的[影响](https://yuhuajing.github.io/ethernaut-book/21-Shop/Shop.html)
