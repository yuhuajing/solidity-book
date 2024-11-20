# 继承合约
继承合约时，也需要初始化合约的构造函数
## 合约函数的继承
- 按照继承顺序，继承父合约的全部状态变量
  - `immutable` 变量需要在 构造函数中声明
  - `constant` 变量直接继承使用
  - 按照继承顺序，继承父合约的全部修饰器
![](./images/slot-inherite.png)
```solidity
// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

contract parent {
    uint256 public immutable base;
    uint256 public constant DAY = 1 days;
    uint256 public num;

    constructor(uint256 _base) {
        base = _base;
    }

    modifier isOdd(uint256 number) {
        require(number % 2 == 0);
        _;
    }

    function checkNumber(uint256 number) external isOdd(number) {
        //do someThing
    }
}

contract a is parent {
    constructor(uint256 _base) parent(_base) {
        base = _base;
    }

    function doAnotherCheck(uint256 number) external isOdd(number) {
        // num in slot0
        // immutable|constant 直接编码到合约codes,不占slot
        num += number;
    }
}
```
- 按照继承顺序，继承父合约的全部函数
  - `override` 可以重写函数
  - `super` 调用父合约的函数，补充增加函数的限制条件
- 后继承的函数会重写之前继承的函数，因此不能菱形继承（函数互相重写依赖）
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/* Graph of inheritance
    A
   / \
  B   C
   \ 
    D,

*/

contract A {
  function foo() public pure virtual returns (string memory) {
    return "A";
  }
}

// Contracts inherit other contracts by using the keyword 'is'.
contract B is A {
  // Override A.foo()
  function foo() public pure virtual override returns (string memory) {
    return "B";
  }
}

contract C is A {
  // Override A.foo()
  function foo() public pure virtual override returns (string memory) {
    return "C";
  }
}

// Contracts can inherit from multiple parent contracts.
// When a function is called that is defined multiple times in
// different contracts, parent contracts are searched from
// right to left, and in depth-first manner.

contract D is B, C {
  // D.foo() returns "C"
  // since C is the right most parent contract with function foo()
  function foo() public pure override(B, C) returns (string memory) {
    return super.foo();// C ->foo() ==>return C
  }
}
```
- 父合约中 `private` 修饰的状态变量无法直接读取或更新，但可以使用 `sload|sstore` 直接操作 `slot`
- 父合约中 `private` 修饰的函数无法调用
```solidity
// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

contract parent {
    uint256 public immutable base;
    uint256 public num; //slot0
    uint256 private prinum; //slot1
    uint256 public num2; // slot2

    constructor(uint256 _base) {
        base = _base;
    }

    modifier isOdd(uint256 number) {
        require(number % 2 == 0);
        _;
    }

    function checkNumber(uint256 number) external isOdd(number) {
        //do someThing
    }
}

contract a is parent {
    constructor(uint256 _base) parent(_base) {
        base = _base;
    }

    function getSlotValue(uint256 slot) public view returns (bytes32 value) {
        assembly {
            value := sload(slot)
        }
    }

    function sstore_x(uint256 slot, uint256 newval) public {
        assembly {
            sstore(slot, newval)
        }
    }
}
```
