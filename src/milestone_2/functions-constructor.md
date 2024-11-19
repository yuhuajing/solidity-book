# 函数
## 构造函数
- 构造函数用于初始化合约参数
  - 允许传参，初始化状态变量
  - 支持 `payable` 修饰，允许合约部署时 `msg.value!=0`
```solidity
  constructor(parameters)[payable] {
   // to-do
  }
```
- 构造函数编码在 [initCode](../milestone_3/contracts-creationcodes.md),并不会存储上链，仅用来初始化合约参数
  - 构造函数的代码不会存储上链，但是构造函数的传参会编码到合约代码
  - 如果构造函数内部逻辑为空，那么链上可执行的合约代码和该函数无关
- 继承合约时，需要传参初始化继承的父合约的构造函数
```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract tree {
    uint256[] Ids;

    constructor(uint256 id) {
        Ids.push(id);
    }
}

contract leaf is tree {
    constructor(uint256 id) tree(id) {}
}
```
