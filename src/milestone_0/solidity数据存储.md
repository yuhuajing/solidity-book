# 数据存储
## 合约存储
在以太坊中：

智能合约的 字节码（`bytecode`）

智能合约的 状态变量（`storage` 变量）

是存储在两种完全不同的地方，它们是物理分离的。

### 🔍 什么是 bytecode？
当你部署一个智能合约时，`Solidity` 源码会被编译成 `EVM bytecode`，比如：
```solidity
function get() public view returns (uint256) {
    return storedData;
}
```
这段代码的逻辑会被编译为一组字节码（十六进制的机器指令），部署在链上，并且是不可变的。

➡️ 存放位置：该合约地址的代码区（`code area`）

### 🔍 什么是 storage 变量？
```solidity
uint256 public storedData = 42;
```
这个 `storedData` 是一个变量，它的值是可以被修改的（可写入的）。

`Solidity` 会将它存储在合约地址关联的状态存储空间中（`Storage Trie`）。

➡️ 存放位置：`State Trie` 中，以合约地址为 `key`，`slot` 为子 `key`

### ✅ 两者的主要区别：
```csharp
[Blockchain Storage]
┌────────────────────────────┐
│ 合约地址 0xABC...123       │
│                            │
│   ┌──────────────┐         │
│   │ Bytecode 区域│  ←  代码（不可变）       │
│   └──────────────┘         │
│                            │
│   ┌──────────────┐         │
│   │ Storage Trie │  ← 变量（可变）         │
│   │  slot 0: 123 │                        │
│   └──────────────┘         │
└────────────────────────────┘

```
| 类别             | 存储位置             | 是否可修改  | 访问方式                           |
| -------------- | ---------------- | ------ | ------------------------------ |
| **Bytecode**   | 合约地址的代码区         | ❌ 不可修改 | `EXTCODECOPY`, `EXTCODESIZE` 等 |
| **Storage 变量** | 状态存储（State Trie） | ✅ 可修改  | `SLOAD`, `SSTORE`              |

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
