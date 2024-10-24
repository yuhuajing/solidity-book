# 抽象合约
- 抽象合约介于接口合约和完整合约之间，内部存在未定的函数，不能被直接部署
- 抽象通过<kbd>abstract</kbd>关键字修饰，内部包含至少一个未实现具体功能的函数方法（没有{}）
- 抽象合约是用来被继承后补全使用的<kbd>base contract</kbd>
## 逻辑未定函数
- 未实现的函数必须使用<kbd>virtual</kbd>修饰，支持后续继承合约的<kbd>override</kbd>重写
- 继承函数时，必须继承函数的全部函数、变量、数据结构、修饰器
  - 必须<kbd>override</kbd>重写函数，补全抽象合约中未定的函数
  - 不能修改函数[名称、修饰符、返回类型]、传参的[参数类型、参数数量]
## Solidity Contracts
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
