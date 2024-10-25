# 函数
## 构造函数
构造函数在合约编译部署时初始化合约：
- 允许传参，初始化状态变量
- 支持 `payable` 修饰，允许合约部署时 `msg.value!=0`
>  constructor(parameters)payable { 
> // do someThing 
> }
- 构造函数代码编码在 [initCode](./contracts-creationcodes.md) 进行判断
  - 构造函数中输入的参数是否合法
  - 构造函数修饰符： `payable`
    - 使用 `payable` 修饰，表示合约在部署时允许接收 `NativeToken`
    - 没有 `payable` 修饰符，表明不支持接收 `NativeToken`
    - 因此，不使用 `payable` 修饰的 `InitCode` 要长一些，进行 `NativeToken` 的判断
  - 构造函数的传参编码到合约代码
- 继承合约时，直接传参，初始化合约构造函数
## 函数修饰符
>function <function name> (<parameter types>) {internal|external|public|private} [pure|view|payable|virtual|override|Modifier] [returns (<return types>)]
- internal：合约内部使用，不能通过 `abi` 直接调用，允许继承
- external：外部访问，可以通过 `abi` 直接调用，也可以在本合约内通过<kbd>this.func</kbd>调用，允许继承
- public：合约内部和外部使用的函数，可以通过 `abi` 直接调用，允许继承
- private:只供合约内部使用，不允许通过 `abi` 直接调用，无法继承使用。
- pure: 只读，函数只能读取局部变量
- view:只读，函数可以读取状态变量、局部变量、全局参数
- payable: payable修饰符表明函数支持接收 `NativeToken(msg.value!=0)`
- virtual: 虚函数，表明函数允许重载修改内部逻辑。多用于接口合约。
- override: 重载函数，重新定义函数内部逻辑，但是函数 `selector` 必须保持一致(函数名称、函数参数类型和数量)
- Modifier: 修饰器，内部定义条件判断,允许继承
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
