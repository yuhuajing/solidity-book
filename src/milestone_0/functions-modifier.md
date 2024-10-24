# 函数修饰器
modifier修饰符用于判断合约方法的执行前置条件
- 将函数内部的语句放置在modifier函数的‘-’中执行判断
- 允许继承使用
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract modofier {
  address owner; //slot 0
  modifier onlyOwner() {
    require(msg.sender == owner, "Not_Owner"); // 判断 slot0存储的值和当前发送者的地址是否一致
    _;
  }
}

contract modofierContract is
modofier // 继承父合约的状态变量,private变量继承后无法更新状态值
{
  constructor() {
    address _addr = msg.sender;
    assembly {
      sstore(owner.slot, _addr)
    }
  }

  function getValue(uint256 slot) external view returns (address addr) {
    assembly {
      addr := sload(slot)
    }
  }

  function changeOwner(address _newowner) public onlyOwner {
    owner = _newowner;
  }
}
```
