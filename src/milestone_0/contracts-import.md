## import 导入合约包
import 导包在声明版本号后，在合约代码前
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Address} from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/utils/Address.sol";

contract StateToStateContract {
    using Address for address;
    function isSC(address _addr)public view returns (bool){
       //  return Address.isContract(_addr);
        return _addr.isContract();
    }
}
```
import导包的三种方式：
1. 导入本地文件
>import {Yeye} from './Yeye.sol';
2. 从网页导入
> import {Address} from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/utils/Address.sol";
3. 通过npm 本地包导入
> import {addrCheck}from "@openzeppelin-contracts/4a9cc8b4918ef3736229a5cc5a310bdc17bf759f/contracts/utils/Address.sol";

