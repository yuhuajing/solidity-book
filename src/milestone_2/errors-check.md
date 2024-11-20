# 异常捕获
`Solidity` 将异常情况分为三类：前置（`require`）、后置（`assert`）、抛出异常（`revert`）:
三种异常通过 `try-catch` 捕获处理
## require 前置判断
- `require(condition,"ErrorMsg“)`, which throws if the condition is false
  - 条件不满足时就会抛出异常，输出异常字符串(`ErrorMsg`)
  - `gas` 花销和描述异常的字符串的长度正相关
```solidity
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
```
## assert 后置判断
- `assert(condition)`, which throws if the condition is false
- 一般作为后置条件判断，但是无法抛出具体的异常信息
```solidity
        assert (balanceAfter < balanceBefore);
```
## revert
- `revert() | revert(ErrorMsg) | revert Error()`
  - 可以通过 `revert()` 直接抛出异常
  - 异常内支持添加异常信息 `revert(ErrorMsg)`
  - 允许抛出自定义的 `Error()`, 通过 `revert Error()` 抛出
```solidity
error TransferNotOwner(); // 自定义error
function transferOwner1(uint256 tokenId, address newOwner) public {
    if(_owners[tokenId] != msg.sender){
        revert TransferNotOwner();
    }
     _owners[tokenId] = newOwner;
}
```
## try catch
### Lower-level
lower-level的调用在EVM层面，直接返回 `boolean,bytes`,让用户自行捕获异常：
- 外部调用的合约函数执行出现了 `revert`
- 外部调用的合约函数执行了非法逻辑（`/0，out-of-bound`）
- 外部调用的合约函数 `out-of-gas`
### 异常捕获
`try external function calls and contract creation calls{}catch`
- `try` 用户捕获外部函数调用的异常
- 不可用于 `selector` 调用的异常捕获
- `catch` 匹配异常
  - Panic(errorCode) via assert
    - 0x00,编译器错误
    - 0x01,assert 报错
    - 0x11,数字越界错误
    - 0x12,/0
    - 0x21,转化枚举类型时：传参负数或越界
    - 0x22,访问错误编码的bytes数组
    - 0x31,空数组pop
    - 0x32,数组越界
    - 0x41,申请内存超额或数组太大
    - 0x51,访问局部变量
    - 返回数据： `bytes4(keccak256(”Panic(uint256)”))) + encode_uint256`
  - Error via require|revert
    - `require(bool) =  if(bool){revert()}`，直接 revert(),返回数据为空
    - `require(bool, string) = if(bool){revert(string)}`，返回数据是 `Error(string)` 的编码
    - `require(bool, UserCustomError()) = if(bool){revert UserCustomError()}`，报用户自定义错误，返回数据是 `bytes4(keccak256("UserCustomError()")))`
```solidity
function callContractB() external view {
  try functionFromAnotherContract() {
    //<-- Handle the success case if needed
  } catch Panic(uint256 errorCode) {
    //<-- handle Panic errors
  } catch Error(string memory reason) { //revert(string), require(false, “reason”)
    //<-- handle revert with a reason
  } catch (bytes memory lowLevelData) { //revert UserCustomError(),require(bool, UserCustomError())
    //<-- handle every other errors apart from Panic and Error with a reason
    // revert without a message
    if (lowLevelData.length == 0) {
      console.log("revert without a message occured");
    }

    // Decode the error data to check if it's the custom error
    if (bytes4(abi.encodeWithSignature("CustomError(uint256)")) ==bytes4(lowLevelData)
    ) {
      // handle custom error
      console.log("CustomError occured here");
    }
  }
}
```
## Preference
https://www.rareskills.io/post/try-catch-solidity
