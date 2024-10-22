# 抽象合约
- 抽象通过<kbd>abstract</kbd>关键字修饰，内部包含至少一个未实现具体功能的函数方法（没有{}）。
- 未实现的函数方法需要加上 <kbd>virtual</kbd>关键字，支持后续继承合约的<kbd>override</kbd>重写功能。

## 逻辑未定函数
- 抽象合约用于实现逻辑未定的函数
- 继承抽象合约，必须实现抽象合约中未定的函数
- 继承函数时，必须继承函数的完整内容
  - 不能修改函数名称、参数类型、参数数量、函数修饰符、函数返回类型和参数数量
  - 继承的函数需要使用 override 重写
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

abstract contract InsertionSort {
    function insertionSort(uint256[] memory a)
    public
    pure
    virtual
    returns (uint256[] memory);
}

contract checkAbstract is InsertionSort {
    function insertionSort(uint256[] memory a)
    public
    pure
    virtual
    override
    returns (uint256[] memory)
    {
        for (uint256 index = 0; index < a.length / 2; index++) {
            uint256 temp = a[index];
            a[index] = a[a.length - index - 1];
            a[a.length - index - 1] = temp;
        }
        return a;
    }
}
```

