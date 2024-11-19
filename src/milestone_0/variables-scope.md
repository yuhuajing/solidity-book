# Data Types
## 变量作用域
- 状态变量
  - 定义在合约中，但是在函数外的需要存储在合约 `slot` 的变量
- 局部变量
  - 定义在合约函数内部，仅在函数执行过程中有效的数据，变量生命周期和函数执行周期一致
- [全局变量](https://www.evm.codes/?fork=cancun#40)。
  - 链上数据，全局变量编码到 `EVM` 字节码中
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Variables {
    // State variables are stored on the blockchain.
    string public hello = "Hello";
    uint256 public num = 123;

    function interVariables() public view returns (uint256 ts) {
        // Local variables are not saved to the blockchain.
        uint256 i = 456;
        // Here are some global variables
        ts = block.timestamp; // 147 gas cost
        // assembly {
        //     ts := timestamp() // 213 gas cost
        // }
        {
            // 可以使用合约状态变量/本函数内部的局部变量/区块链上全局变量
            uint interTs = 356;
            interTs += block.timestamp;
            interTs += i;
            interTs += num;
        }
       // interTs +=9; 外部无法访问作用域内部的参数
    }
}
```
![](./images/global_variables.png)
