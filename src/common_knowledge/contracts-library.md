# 库合约
- 库合约使用<kbd>library</kbd>关键字修饰
- 库合约作为完整函数的封包使用
- 库合约不能接收token 
- 库合约不能被继承或继承别的合约 
- 库合约不能存在状态变量
- 库合约不能定义构造函数 
- 库合约的使用分为两种： 
  - 通过 `Using library_name for type`,此时 `type` 类型的变量就可以调用库合约内部函数
  - 直接通过 `library_name` 调用函数
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

library Address {
   struct st {
      string name;
      uint256 value;
   }

   function isContract(address account) internal view returns (bool) {
      uint256 size;
      assembly {
         size := extcodesize(account)
      }
      return size > 0;
   }
}

contract StateToStateContract {
   using Address for address;

   function isSC(address _addr) public view returns (bool) {
      return Address.isContract(_addr); //_addr.isContract();
   }
}
```
