# Solidity参数
## 动态数据类型存储
### Arrays数据存储
#### 定长数组
- 定长数组作为固定大小的参数
- 数据存储按照静态类型依次 `slot` 存储
- 定长数组不和其他参数共享 `slot`
```solidity
// SPDX-License-Identifier: MIT
pragma solidity =0.8.26;

contract MyFixedUint256Array {
    uint256 num; // storage slot 0

    uint64[3] myArr = [
        4, // storage slot 1
        9, // storage slot 1
        2 // storage slot 1
    ];
    uint64 next = 5; //storage slot 2
    uint128[3] bigArr = [
        4, // storage slot 3
        9, // storage slot 3
        2 // storage slot 4
    ];
    uint64 bnext = 5; //storage slot 5

    function getValue(uint256 index) public view returns (uint256 value) {
        // CALL HELPER FUNCTION TO GET SLOT
        assembly {
            // Loads the value stored in the slot
            value := sload(index)
        }
    }
}
```
#### 不定长数组--arrays[]
- 不定长数据在合约编译时无法确认数据 `size`，所以在 `baseSlot` 存储当前参数的 `size`
- 不定长数组具体数据的起始位置和 `baseSlot` 相关：`keccak256（baseSlot）`
- 不定长数组的数据依次从起始位置开始入栈存储
- 不定长数组的数据按照数值类型补位存储，`slot` 进行高位补足存储数组参数
- 数值长度超出 `256bit` 后，顺延至下一个 `slot` 存储 `（index += 1）`
```solidity
// SPDX-License-Identifier: MIT
pragma solidity =0.8.26;

contract MyDynArray {
  uint256 private someNumber; // storage slot 0
  address private someAddress; // storage slot 1
  uint32[] private myDynamicArr = [3, 4, 5, 9, 7]; // storage slot 2

  function getSlot(uint256 _index) public pure returns (uint256 slot) {
    uint256 baseSlot;
    assembly {
    // `.slot` returns the state variable (balance) location within the storage slots.
    // In our case, balance.slot = 6
      baseSlot := myDynamicArr.slot
    }
    slot = uint256(keccak256(abi.encode(baseSlot))) + _index;
  }

  function getSlotValue(uint256 slot) public view returns (bytes32 value) {
    assembly {
      value := sload(slot)
    }
  }
}
```
![](./images/dynamic_array_32.png)
- 数据类型变成 `uint64[] private myDynamicArr = [3, 4, 5, 9, 7]; // storage slot 2`:
  - 一个 `slot` 最多存储 `4` 个数组参数
  - 因此，起始位置 `index=0` 的 `slot` 能够存储 `3,4,5,9` 四个参数
  - 剩余参数顺眼至下一个 `slot`
  - 因此，起始位置 `index=1` 的 `slot` 存储 `7`
#### 多维不定长数组
- array[][]... `uint64[][] private nestedDynamicArray = [[2, 9, 6, 3, 2], [7, 4, 8, 10, 2]]; `
- `baseSlot` 存储当前数组大小,示例大小为 `2`
- 进一步确认内部嵌套的数组大小，存储内部数组大小的 `slot_array_size` 和 数组 `index` 相关：`slot_array_size = keccak256（baseSlot）+ index`
- 嵌套数组内部的数据 `slot_array_data_loc` 和 `slot_array_size` 以及内部 `internal_index` 相关：`slot_array_data_loc = keccak256（slot_array_size）+ internal_index`
- 嵌套数组内部的数据存储按照单维存储规则
```solidity
// SPDX-License-Identifier: MIT
pragma solidity =0.8.26;

contract MyNestedArray {
  uint256 private someNumber; // storage slot 0

  // Initialize nested array
  uint64[][] private nestedDynamicArray = [[2, 9, 6, 3, 2], [7, 4, 8, 10, 2]]; // storage slot 1

  function getArrSizeLoc_BaseSlot_Index(uint256 index)
  public
  pure
  returns (uint256 slot)
  {
    uint256 baseSlot;
    for (uint256 i; i <= index; i++) {
      if (i == 0) {
        assembly {
        // `.slot` returns the state variable (balance) location within the storage slots.
        // In our case, balance.slot = 6
          baseSlot := nestedDynamicArray.slot
        }
      }
      slot = uint256(keccak256(abi.encode(baseSlot))) + index;
    }
  }

  function getArrDataLoc_SlotLoc_InternalIndex(uint256 locslot, uint256 index)
  public
  pure
  returns (uint256 slot)
  {
    slot = uint256(keccak256(abi.encode(locslot))) + index;
  }

  function getSlot(
    uint256 baseSlot,
    uint256 _index1,
    uint256 _index2
  ) public pure returns (bytes32 _finalSlot) {
    // keccak256(baseSlot) + _index1
    uint256 _initialSlot = uint256(keccak256(abi.encode(baseSlot))) +
          _index1;

    // keccak256(_initialSlot) + _index2
    _finalSlot = bytes32(
      uint256(keccak256(abi.encode(_initialSlot))) + _index2
    );
  }

  function getSlotValue(uint256 _slot) public view returns (uint256 value) {
    assembly {
      value := sload(_slot)
    }
  }

  function addArray() external {
    nestedDynamicArray.push([22, 6, 99, 14]);
  }
}
```
数据：[[2, 9, 6, 3, 2], [7, 4, 8, 10, 2]]，Array[array1,array2]
#### 动态数据类型存储
| 说明                       | slot                                                                                        | Value                                                               |
|--------------------------|---------------------------------------------------------------------------------------------|---------------------------------------------------------------------|
| baseSlot                 | 1                                                                                           | 2                                                                   |
| array1<br/>存储size的slot,s1     | keccack(1)+0=<br/>80084422859880547211683076133703299733277748156566366325829078699459944778998  | 5                                                                   |
| array2<br/>存储size的slot,s2     | keccack(1)+1=<br/>80084422859880547211683076133703299733277748156566366325829078699459944778999  | 5                                                                   |
| array1<br/>存储index0的数据slot,d1 | keccack(s1)+0=<br/>82253526175936117417672031222849803842933200219522072251142807856800200228130 | 0x0000000000000003000000000000000600000000000000090000000000000002  |
| array1<br/>存储index1的数据slot,d2 | keccack(s1)+1=<br/>82253526175936117417672031222849803842933200219522072251142807856800200228131 | 0x0000000000000000000000000000000000000000000000000000000000000002  |
| array2<br/>存储index0的数据slot,d3 | keccack(s2)+0=<br/>106053296617608346790393806727882046642653284128270527600775845709961105489201 |0x000000000000000a000000000000000800000000000000040000000000000007|
| array2<br/>存储index1的数据slot,d4 | keccack(s2)+1=<br/>106053296617608346790393806727882046642653284128270527600775845709961105489202 |0x0000000000000000000000000000000000000000000000000000000000000002|
