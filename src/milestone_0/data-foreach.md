# 合约逻辑
## 控制流
- `if(statement){}else{}`
- `for(statement){}`
  - `for` 循环长度不定的元素时，一定要控制范围，防止 `out-of-gas`
- `while(statement){}`
  - `while` 循环执行直到不满足条件，同样在 `statement` 中要控制循环范围
- `do{}while(statement)`
  - 先执行逻辑，在执行判断
  - 执行直到不满足条件，同样在 `statement` 中要控制循环范围
- 循环过程关键字
  - `continue`：跳出当前循环，立即进入下一个循环
  - `break`：终止当前循环
- `try()catch{}`
   - [异常捕获](../milestone_2/errors-check.md)
- 三元操作符
  - a>b?a:b
```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract Logic {
  bool ifFlag = true;
  uint32[] raffleIds;
  uint256 executeNumber;

  function IfLogic() external view returns (bool) {
    if (ifFlag) {
      return (true);
    } else {
      return (false);
    }
  }

  function quicksort(uint256[] memory a)
  public
  pure
  returns (uint256[] memory)
  {
    uint256 len = a.length;
    for (uint256 i = 1; i < len; i++) {
      uint256 key = a[i];
      uint256 j = i;
      while (j >= 1 && key < a[j - 1]) {
        a[j] = a[j - 1];
        j--;
      }
      a[j] = key;
    }
    return a;
  }

  // Don't write loops that are unbounded as this can hit the gas limit, causing your transaction to fail.
  function forExecuteRaffle(uint256 count) external {
    uint256 length = raffleIds.length;
    uint256 ncount = executeNumber + count >= length
      ? length
      : executeNumber + count;
    uint256 temp = executeNumber;
    executeNumber = ncount;
    for (uint256 i = temp; i < ncount; i++) {
      // do something
    }
  }

  // Don't write loops that are unbounded as this can hit the gas limit, causing your transaction to fail.
  function whileExecuteRaffle(uint256 count) external {
    uint256 length = raffleIds.length;
    uint256 ncount = executeNumber + count >= length
      ? length
      : executeNumber + count;
    uint256 temp = executeNumber;
    executeNumber = ncount;
    while (temp < ncount) {
      // do something
    }
  }

  // do something first, then do statement check.
  function dowhileCheck(uint256 _number) public pure returns (uint256) {
    do {
      _number += 1;
    } while (_number < 15);
    return _number; //_number+1
  }
}
```
