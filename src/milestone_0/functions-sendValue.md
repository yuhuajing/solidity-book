# 转账
## [函数转账](https://yuhuajing.github.io/ethernaut-book/01-Fallback/Fallback.html)
- `receive() external payable {}`,函数用于接收NativeToken(EOA直接转账)
- `fallback()external payable{}` ,函数缺省情况(包括转账后没有receive()方法)
- <kbd>send</kbd>执行转账
  - 传递2300的gas
  - 转账返回 boolean
  - 转账失败不会 revert 交易,因此，需要判断转账结果
- <kbd>transfer</kbd>
  - 传递2300的gas
  - 转账失败的话，整笔交易回滚
- <kbd>call</kbd>的转账
  - 默认会发送 [63/64](https://www.rareskills.io/post/eip-150-and-the-63-64-rule-for-gas) gas
  - 返回bool 和data
  - bool表示转账是否成功
  - data返回执行调用的结果
  - 交易失败的话不会回滚。
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract receiver {
  constructor() {}

  event ReceiveReceived(address Sender, uint256 Value);
  event FallbackReceived(address Sender, uint256 Value);

  receive() external payable {
    emit ReceiveReceived(msg.sender, msg.value);
  }

  fallback() external payable {
    emit FallbackReceived(msg.sender, msg.value);
  }
}

contract payer {
  constructor() payable {}

  function sendValue(address payable recipient, uint256 amount) external {
    bool success = recipient.send(amount); //ReceiveReceived
    if (!success) {
      revert("Send Trans Failure");
    }
  }

  function transferValue(address payable recipient, uint256 amount) external {
    recipient.transfer(amount); //ReceiveReceived
  }

  function callSendValue(
    address payable recipient,
    uint256 amount,
    bytes memory _data
  ) external {
    (bool success, ) = recipient.call{value: amount}(_data); //ReceiveReceived
    if (!success) {
      revert("call_send_value_failure");
    }
  }
}
```
