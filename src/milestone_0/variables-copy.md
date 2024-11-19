# Data Types
## 变量修饰符
参数修饰符包括：`public,private,immutable,constant`
- `public`,自动生成 `Getter` 函数，表明函数在合约中可以通过 `abi` 查询
- `private`，参数无法通过 `abi` 直接查询，只能通过自定义的合约函数或 `sload(xx)` 通过 `slot` 获得数据
- `immutable`，参数必须在构造函数中初始化，并且编码在字节码中，后续无法修改
- `constant`，参数在定义时，直接初始化，并且编码在字节码中，后续无法修改
- `payable`,用于修饰地址，表明允许该地址接收 `NativeToken`
## 变量存储方式
参数在合约中的存储方式
- 合约数据存储
  - `storage(可修改),Bytecodes(constant/immutable,不可修改)
- 合约函数运行时的数据存储
  - (memory,stack,calldata)`，传参或返回数据

![](./images/evm_account.png)
### 合约数据存储
- `Bytecodes`
  - `immutable|constant` 变量在合约编译时将值存储在合约代码中，因此后续数据变量无法更改
  - 在合约使用期间，无需在内部存储中维护该常量的状态
  - 由于参数不存储在内部 `slot` ，数据都是通过字节码读取，因此在合约外部调用中，`immutable|constant` 的值只会从被调用的合约字节码中获取
```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract Constants {
  // coding convention to uppercase constant variables
  // 存储在字节码
  address public constant MY_ADDRESS =
  0x777788889999AaAAbBbbCcccddDdeeeEfFFfCcCc;
  // 存储在字节码
  uint256 public constant MY_UINT = 123;
  // 存储在字节码
  uint256 private immutable a;
  // slot 0
  uint256 public ty = 9;

  constructor() {
    a = 99;
  }

  function getslot(uint256 slot) public view returns (bytes32  value) {
    assembly {
      value := sload(slot)
    }
  }
}
```
- `Storage`
  - 存储合约状态变量，通过写交易修改
### 运行时数据存储
- memory. 函数执行过程中用于存储动态分配的数据，如临时变量、函数参数和函数返回值等
- stack. 函数执行过程中存储数据，如基本数据类型和值类型的局部变量
- calldata. 和 `memory` 类似，数据存储在内存中，但是 <kbd>calldata</kbd> 数据只读，一般用于函数的输入参数
```solidity
    function fCalldata(uint[] calldata _x) public pure returns(uint[] calldata){
        //参数为calldata数组，不能被修改
        // _x[0] = 0 //这样修改会报错
        return(_x);
    }
```
## 变量引用作用域
1. 普通状态变量 -> 普通状态变量(拷贝)
2. 普通状态变量 -> storage变量(引用)
3. 普通状态变量 -> memory变量(拷贝)
4. storage变量 -> storage变量(引用)
5. storage变量 -> memory变量(拷贝)
6. storage变量 -> 普通状态变量(引用)
7. memory变量 -> memory变量(引用)
8. memory变量 -> 普通状态变量(拷贝)
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract StateToStateContract {
  uint8[3] public static_array = [1, 2, 3]; //State 状态变量
  uint8[3] public static_array_two;
  uint256[] public dynamic_array;
  event LogUint8(uint8);
  event staticArrays(uint8[3], uint8[3]);
  event dynamicArrays(uint256[], uint256[]);

  function stateToany() public {
    //状态变量 -> 状态变量(拷贝),双方互不影响
    static_array_two = static_array;
    static_array_two[0] = 8;
    emit staticArrays(static_array, static_array_two); //[1,2,3],[8,2,3]
    //状态变量 -> storage变量(引用),引用拷贝，修改任意变量的值会影响另一个状态变量的值，更新合约状态参数
    uint256[] storage tem_dynamic_array = dynamic_array;
    tem_dynamic_array.push(10086);
    emit dynamicArrays(dynamic_array, tem_dynamic_array); //[10086],[10086]
    //状态变量 -> memory变量(拷贝)
    uint256[] memory tem_dynamic_array_two = dynamic_array;
    tem_dynamic_array_two[tem_dynamic_array_two.length - 1] = 999;
    emit dynamicArrays(dynamic_array, tem_dynamic_array_two); //[10086],[999]
  }

  function storageToany() public {
    //storage变量 -> storage变量(引用),引用拷贝，修改任意变量的值会影响另一个状态变量的值，更新合约状态参数
    uint256[] storage tem_dynamic_array = dynamic_array;
    tem_dynamic_array.push(12);
    emit dynamicArrays(dynamic_array, tem_dynamic_array); //[12]，[12]
    uint256[] storage tem_dynamic_array_two = tem_dynamic_array;
    tem_dynamic_array_two.push(13);
    emit dynamicArrays(dynamic_array, tem_dynamic_array); //[12,13],[12,13]
    emit dynamicArrays(tem_dynamic_array, tem_dynamic_array_two); //[12,13],[12,13]
    //storage变量 -> memory变量(拷贝)
    uint256[] memory tem_dynamic_array_memory = tem_dynamic_array;
    tem_dynamic_array_memory[0] = 14;
    emit dynamicArrays(tem_dynamic_array, tem_dynamic_array_memory); //[12,13],[14,13]
    // storage变量 -> 状态变量(引用)，引用拷贝，修改任意变量的值会影响另一个状态变量的值，更新合约状态参数
    dynamic_array = tem_dynamic_array;
    dynamic_array[0] = 15;
    emit dynamicArrays(dynamic_array, tem_dynamic_array); //[15,13],[15,13]
    tem_dynamic_array.push(16);
    emit dynamicArrays(dynamic_array, tem_dynamic_array); //[15,13,16],[15,13,16]
  }

  function memoryToany() public {
    // memory变量 -> 状态变量(拷贝)
    uint8[3] memory tem_static_array = static_array;
    tem_static_array[0] = 4;
    emit staticArrays(static_array, tem_static_array); //[1,2,3],[4,2,3]
    // memory变量 -> memory变量(引用)，引用拷贝，修改任意变量的值会影响另一个状态变量的值，更新合约状态参数
    uint8[3] memory tem_static_array_two = tem_static_array;
    tem_static_array_two[2] = 5;
    emit staticArrays(static_array, tem_static_array); //[1,2,3],[4,2,5]
    emit staticArrays(tem_static_array, tem_static_array_two); //[4,2,5],[4,2,5]
  }
}
```
