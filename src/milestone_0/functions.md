# 函数
## 构造函数
- 合约字节码由三部分组成：`<init code> <runtime code> <constructor parameters>`
  - 构造函数代码编码在 init code进行判断
    - 合约部署时是否支持接收NativeToken
    - 构造函数中输入的参数是否合法
  - 构造函数的参数编码到字节码最后
    - 初始化合约参数，后续不能修改
  - 构造函数修饰符： payable
    - 使用payable修饰，表示合约在部署时允许接收NativeToken
    - 没有payable修饰符，表明不支持接收NativeToken
    - 因此，不适用payable修饰的InitCode要长一些，进行NativeToken的判断
  - Immutable修饰的参数必须在构造函数中初始化
- 继承合约时，也需要初始化合约的构造函数
## 合约函数的继承
- 按照继承顺序，继承父合约的全部状态变量
- 按照继承顺序，继承父合约的全部修饰器
- 按照继承顺序，继承父合约的全部函数
- 后继承的函数会重写之前继承的函数，因此不能菱形继承（函数互相重写依赖）
- 父合约中private修饰的状态变量无法更新
- 父合约中private修饰的函数量无法调用
## 函数修饰符
>function <function name> (<parameter types>) {internal|external|public|private} [pure|view|payable|virtual|override|Modifier] [returns (<return types>)]
### 函数修饰符
- internal：合约内部使用，不能通过abi直接调用，允许继承
- external：外部访问，可以通过abi直接调用，也可以在本合约内通过<kbd>this.func</kbd>调用，允许继承
- public：合约内部和外部使用的函数，可以通过abi直接调用，允许继承
- private:只供合约内部使用，不允许通过abi直接调用，无法继承使用。
- pure: 只读，函数只能读取局部变量
- view:只读，函数可以读取状态变量、局部变量、全局参数
- payable: payable修饰符表明函数支持接收NativeToken(msg.value!=0)
- virtual: 虚函数，表明函数允许重载修改内部逻辑。多用于接口合约。
- override: 重载函数，重新定义函数内部逻辑，但是函数selector必须保持一致(函数名称、函数参数类型和数量)
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
