# [合约调用](https://www.rareskills.io/post/delegatecall)
- 外部函数可以定义接口调用，<kbd>_Name(_Address).func()</kbd>
- 外部函数支持通过合约函数选择器传参调用， `abi.encodeWithSignature | encodeWithSelector | encodePacked`
  - 调用函数选择的方式：<kbd>Call,delegateCall,staticCall</kbd>
- `public|external` 修饰的函数允许外部调用 以及 继承的合约使用
- `internal|private` 修饰的函数不支持外部调用
  - `internal` 修饰的函数允许继承使用
  - `private` 修饰的函数不允许继承使用
## 外部调用Error：
- 执行中遇到 `REVERT` 关键字
- `out-of-gas`
- 异常(`/0，out-of-bound`)
## Call
![](./images/call-pic.png)
- `Call` 的调用在底层新启一个 `EVM` 作为外部 `call` 交易的执行环境
- 在新启的外部合约的 `EVM` 执行环境中，执行被调用合约的逻辑，更新被调用合约的状态变量
- 对于被调用的合约来讲，外部 `call` 的交易处在新的 `EVM` 执行环境，交易的发起方就是发起调用的合约地址
### 返回状态
- `call` 返回 `(bool success, bytes memory data)`
  - `boolean` 表明当前调用是否成功
  - `data` 是执行函数返回的数据
  - `call` 执行失败的话，不会 `revert` 回滚交易，因此需要执行异常判断
- `call` 外部合约不存在的函数
  - 外部合约存在缺省 `fallback()` ，就执行 `fallback()` 逻辑
  - 不存在缺省函数的话，直接返回 `false`
## Solidity Contracts
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface CalledInterface {
   function increment(uint256 num) external;
}

contract Called is CalledInterface {
   uint256 public number;

   function increment(uint256 num) external {
      number += num;
   }
//  fallback() external payable { }
}

contract Caller {
   function callIncrement(CalledInterface calledAddress, uint256 num)
   external
   {
      calledAddress.increment(num);
   }

   function callIncrementSig(CalledInterface calledAddress, uint256 num)
   external
   {
      (bool flag, bytes memory result) = address(calledAddress).call(
         abi.encodeWithSignature("increment(uint256)", num)
      );
      if (!flag) {
         assembly {
            revert(add(result, 32), mload(result))
         }
      }
   }

   function callIncrementSelector(CalledInterface calledAddress, uint256 num)
   external
   {
      bytes4 mSelector = bytes4(keccak256("increment(uint256)"));
      (bool flag, bytes memory result) = address(calledAddress).call(
         abi.encodePacked(mSelector, num)
      //   abi.encodeWithSelector(mSelector, num)
      // abi.encodeWithSelector(CalledInterface.increment.selector, num)
      );
      if (!flag) {
         assembly {
            revert(add(result, 32), mload(result))
         }
      }
   }
}
```
## [staticCall](https://www.rareskills.io/post/solidity-staticcall)
1. 和Call一样，但是只能用于读取数据，无法更新slot数值
2. 天然适用于使用 [预编译合约](./contracts-precompile.md)
