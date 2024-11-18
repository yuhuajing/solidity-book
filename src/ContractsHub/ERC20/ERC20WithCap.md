## 带有mint总量的ERC20
通过重写_update函数，内部增加if判断。在合约初始化时指定合约内部总代币的数量，在每次mint新代币的同时通过if语句判断当前合约代币的总供应量是否小于当前合约的cap值。

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    error ERC20ExceededCap(uint256 increasedSupply, uint256 cap);
    uint256 private immutable _cap;
    constructor(uint256 totalcap,string memory name, string memory symbol) ERC20(name, symbol) {
        _cap=totalcap;
        _mint(msg.sender, 100 * 10 ** uint(decimals()));
    }
    //开放mint功能，任何账户都能触发mint操作，需要严密的modifier前置判断

    function cap()public view virtual returns(uint256 data){
        data= _cap;
    }

    function _update(address from, address to, uint256 amount)internal virtual override{
        if(from == address(0)){
        uint256  ts = totalSupply();
        uint256  maxCap = cap();
        if (ts + amount > maxCap){
            revert ERC20ExceededCap(ts,maxCap);
            }  
        }
        super._update(from,to,amount);
    }
}
```