# ENUM
枚举 <kbd>enum</kbd> 作为变量集合，用于定义状态
- <kbd>enum</kbd>内部的变量从 `0 index` 开始, `default: 0`
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract EnumExample {
  enum Status {
    Active,
    Inactive,
    Pending
  }
  Status public status; // default: Active

  constructor() {}

  function setStatus(Status _status) public {
    //require(uint256(_status) == 2);// 43673 gas cost
    require(status == Status.Pending); // 23817 gas cost,更节省 gas
    status = _status;
  }

  function getStatus() public view returns (Status) {
    return status;
  }
}
```
