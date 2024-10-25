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

interface ERC20 {
  function transferFrom(
    address from,
    address to,
    uint256 amount
  ) external returns (bool);
}

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

  // 11053 gas cost
  function safeTransferNativeToken(
    address to,
    uint256 amount,
    uint256 txGas
  ) external {
    bool success;
    /// @solidity memory-safe-assembly
    assembly {
    // Transfer the ETH and store if it succeeded or not.
    //success := call(gas(), to, amount, 0, 0, 0, 0)
      success := call(txGas, to, amount, 0, 0, 0, 0)
    }
    require(success, "ETH_TRANSFER_FAILED");
  }

  function safeTransfer(
    ERC20 token,
    address to,
    uint256 amount
  ) internal {
    bool success;

    /// @solidity memory-safe-assembly
    assembly {
    // Get a pointer to some free memory.
      let freeMemoryPointer := mload(0x40)

    // Write the abi-encoded calldata into memory, beginning with the function selector.
      mstore(
        freeMemoryPointer,
        0xa9059cbb00000000000000000000000000000000000000000000000000000000
      )
      mstore(
        add(freeMemoryPointer, 4),
        and(to, 0xffffffffffffffffffffffffffffffffffffffff)
      ) // Append and mask the "to" argument.
      mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

      success := and(
      // Set success to whether the call reverted, if not we check it either
      // returned exactly 1 (can't just be non-zero data), or had no return data.
        or(
          and(eq(mload(0), 1), gt(returndatasize(), 31)),
          iszero(returndatasize())
        ),
      // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
      // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
      // Counterintuitively, this call must be positioned second to the or() call in the
      // surrounding and() call or else returndatasize() will be zero during the computation.
        call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
      )
    }

    require(success, "TRANSFER_FAILED");
  }
}
```
## [staticCall](https://www.rareskills.io/post/solidity-staticcall)
1. 和Call一样，但是只能用于读取数据，无法更新slot数值
2. 天然适用于使用 [预编译合约](./contracts-precompile.md)
