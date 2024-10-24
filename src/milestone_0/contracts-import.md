# import
- `import` 导包在声明版本号后，在合约代码前 `import {contractName} from '...'`
- 导入合约后，相当于引入了完整的合约文件
- 导入库函数后，合约内部不能定义重复的库函数
## import 导包
1. 导入本地文件
>import {Address} from './Address.sol';
2. 从网页导入
> import {Address} from "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/refs/heads/master/contracts/utils/Address.sol";
3. 通过npm 本地包导入
> import {Address} from "@openzeppelin/contracts/utils/Address.sol";
## 包内函数
- 直接使用：通过合约名直接调用引入的合约函数
- 继承使用：除library外的合约，继承后可以直接使用包内的函数、状态变量
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
import {IERC20} from "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/refs/heads/master/contracts/token/ERC20/IERC20.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

contract sendValue {
    function tokenAllowance(
        address token,
        address owner,
        address spender
    ) public view returns (uint256) {
        return IERC20(token).allowance(owner, spender); //Interface contracts
    }

    function transferValue(address beneficiary, uint256 value) public payable {
        Address.sendValue(payable(beneficiary), value); //Library contracts
    }

    function allowance(address owner, address spender)
    external
    view
    returns (uint256)
    {}
}
```
