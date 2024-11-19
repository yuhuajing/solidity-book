# Solidity参数
## 动态数据类型存储
### Struct
- 结构体内部数据直接从 `baseSlot` 依次按照类型存储
## Slot 存储读取
- `sload`读取当前 `slot` 位置的 `value`
- `sstore`更新当前 `slot` 位置的 `value`,
- `sload` 和 `sstore` 将参数全部作为 `bytes32` 处理，更节省 `gasFee`
- `.slot` 返回当前参数的 `baseSlot`
### 读取slot数据
```solidity
// SPDX-License-Identifier: MIT
pragma solidity =0.8.26;

contract slotLoc {
  uint256 private someNumber = 5; // storage slot 0
  struct Payment {
    address payee;
    uint128 payId;
    uint256 payPrice;
  }
  Payment private payment =
  Payment(
    address(0x1), // storage slot 1
    12345, // storage slot 2
    22 // storage slot 3
  );
  address private someAddress = address(0x2); // storage slot 4
  uint32[] private myDynamicArr = [3, 4, 5, 9, 7]; // storage slot 5

  function getSlot()
  public
  pure
  returns (
    uint256 numslot,
    uint256 paymentslot,
    uint256 addressslot
  )
  {
    assembly {
    // `.slot` returns the state variable (balance) location within the storage slots.
    // In our case, balance.slot = 6
      numslot := someNumber.slot
      paymentslot := payment.slot
      addressslot := someAddress.slot
    }
  }

  function getSlotValue(uint256 slot) public view returns (bytes32 value) {
    assembly {
      value := sload(slot)
    }
  }

  function sstore_x(uint256 newval) public {
    assembly {
      sstore(someNumber.slot, newval)
    }
  }
}
```

## Preference
https://www.rareskills.io/post/solidity-dynamic
