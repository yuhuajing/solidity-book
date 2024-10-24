# [函数选择器](https://www.rareskills.io/post/function-selector)
## selector
- 选择器和 `函数名、函数参数` 相关，和函数&参数的修饰符无关
- 计算选择器时，函数参数之间无空格
- Internal|Private函数不允许外部调用
- 使用4个字节的函数选择器降低 msg.data 的size(函数名称可以无限长，选择器就时4bytes)
- 函数选择器不会和fallback()进行匹配，只有在全部的功能函数没匹配上的时候，才会调用fallback()函数
- 因此，solidity支持同名不同参数的函数,hash值不一样
- 函数之间可以通过合约|抽象合约|接口合约直接调用
## selector外部调用
- solidity在opcode层通过`bytes4(keccak256(abi.encodePacked(functionName)))`计算函数选择器
- abi.encodePacked
- abi.encodeWithSelector
- abi.encodeWithSignature
```solidity
// SPDX-License-Identifier: MIT
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract SelectorTest {
  uint256 public x;
  event Sig(bytes4 sig);

  function foo(uint256 num) public {
    emit Sig(msg.sig); //this.foo.selector
    x += num;
  }

  function func(uint256 num) external {
    x += num;
  }

  function func(uint256 num, bool flag) external {
    if (flag) {
      x += num;
    }
  }

  function getSelectorOfFoo() external pure returns (bytes4) {
    return this.foo.selector; // 0xc2985578
  }
}

contract CallFoo {
  event Sig(bytes4 sig);

  function callFooLowLevel(SelectorTest _contract, uint256 num) external {
    //  _contract.foo(num);
    // bytes4 fooSelector = 0xc2985578;
    emit Sig(msg.sig); // this.callFooLowLevel.selector
    bytes4 fooSelector = SelectorTest.foo.selector; //bytes4(keccak256("foo(uint256)"))
    (bool ok, ) = address(_contract).call(
      abi.encodePacked(fooSelector, num)
    );
    // | (bool ok, ) = address(_contract).call(abi.encodeWithSelector(fooSelector, num));| (bool ok, ) = address(_contract).call(abi.encodeWithSignature("foo(uint256)", num));
    require(ok, "call failed");
  }
}
```
## Tools
[函数在线计算选择器](https://www.evm-function-selector.click/)

[函数选择器数据库](https://www.4byte.directory/)
