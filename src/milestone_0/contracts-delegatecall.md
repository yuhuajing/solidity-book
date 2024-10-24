# [合约调用](https://www.rareskills.io/post/delegatecall)
## delegateCall
![](./images/delegatecall-pic.png)
- `delegateCall` 在底层将外部合约的代码整个复制到当前EVM环境，与 `origin` 交易复用同一个 `EVM` 执行环境
  - `delegateCall` 执行在本合约的 `EVM` 环境 
  - `delegateCall` 拥有完整的外部调用合约的合约代码
  - `delegateCall` 按照外部合约代码去更新/读取 `EVM` 环境中的 `slot` 的状态变量
### 返回状态
- `delegateCall` 返回 `(bool success, bytes memory data)`
  - `boolean` 表明当前调用是否成功
  - `data` 是执行函数返回的数据
  - `delegateCall` 执行失败的话，不会 `revert` 回滚交易，因此需要执行异常判断
- `delegateCall` 外部合约不存在的函数
  - 外部合约存在缺省 `fallback()` ，就执行 `fallback()` 逻辑
  - 不存在缺省函数的话，直接返回 `false`
### Solidity Examples
- `delegateCall` 按照外部合约代码去更新/读取 `EVM` 环境中的 `slot` 的状态变量
- 示例合约在 `EVM` 中的逻辑为： `slot1 += slot0`
- 本合约按照上述逻辑更新自己合约内部的 `slot` 参数
```solidity
// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

contract Called {
  uint256 base = 3;
  uint256 public number; //slot 1

  function increment() public returns (uint256) {
    number += base; // slot0's value
    return number;
  }
}

contract Caller {
  uint256 base = 99; // 按照业务逻辑会读取slot0数据，参与计算。每次调用：slot1 += slot0(myNumber+=99)
  uint256 public myNumber;
  // there is a new storage variable here
  address public calledAddress = 0xd9145CCE52D386f254917e481eB44e9943F39138;

  function execute(address to, uint256 txGas)
  external
  returns (bool success)
  {
    bytes memory data = abi.encodeWithSignature("increment()");
    return _execute(to, data, txGas);
  }

  function _execute(
    address to,
    bytes memory data,
    uint256 txGas
  ) internal returns (bool success) {
    assembly {
      success := delegatecall(
        txGas,
        to,
        add(data, 0x20),
        mload(data),
        0,
        0
      )
    }
  }

  function delegateCallIncrement(
    address delegatedCalled //28187 gas cost
  ) public returns (uint256) {
    (bool success, bytes memory resdata) = delegatedCalled.delegatecall(
      abi.encodeWithSignature("increment()") //0xd09de08a
    );
    if (!success) {
      assembly {
        revert(add(resdata, 32), mload(resdata))
      }
    } else {
      // 解码call|delegateCall的返回值
      return abi.decode(resdata, (uint256));
    }
  }
}
```
