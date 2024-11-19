# 函数
## 函数修饰符
`function <function name> (<parameter types>) {internal|external|public|private} [pure|view|payable|virtual|override|Modifier] [returns (<return types>)]`
- internal：未公开的函数，只能在合约内部使用，不能通过 `abi` 直接/外部调用，允许在继承的子合约中使用
- external：公开的函数，可以通过 `abi` 直接调用，也可以在本合约内通过 <kbd>this.func</kbd> 调用，允许在继承的子合约中使用
- public：公开的函数，可以通过 `abi` 直接调用，允许在继承的子合约中使用
- private: 未公开的函数，只能在合约内部使用，不允许通过 `abi` 直接调用，不允许在继承的子合约中使用
- pure: 只读，函数只能读取局部变量
- view: 只读，函数可以读取状态变量、局部变量、全局变量
- payable: `payable` 修饰符表明函数支持接收 `NativeToken(msg.value!=0)`
- virtual: 虚函数，表明函数允许重载修改内部逻辑, 多用于接口合约
- override: 重载函数，重新定义函数内部逻辑，但是函数 `selector` 必须保持一致(函数名称、函数参数类型和数量)
- Modifier: 修饰器，内部定义条件判断, 允许在继承的子合约中使用
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract parentOne {
    uint256 public oneValue;

    function OneInternal() internal virtual {
        oneValue += 1;
    }

    function OneExternal() external virtual {
        oneValue += 2;
    }

    function OnePublic() public virtual {
        oneValue += 3;
    }

    function OnePrivate() private {
        oneValue += 4;
    }
}

contract functionsChecker is parentOne {
    function addOne() external {
        OneInternal();
    }

    // function addTwo() external {
    //     this.OneExternal();
    // }

    function addThree() external {
        super.OnePublic(); // super调用最近继承者合约的内部函数, +3
    }

    // function addFive() external {
    //     OnePublic(); //调用本合约的函数，+ 5
    // }

    function OnePublic() public virtual override {
        //重写函数，修改函数逻辑
        oneValue += 5;
    }

    //receive() external payable {}
}
```
