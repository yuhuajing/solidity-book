## 销毁代币
ERC20内部提供的internal _burn 函数只能在合约和继承的合约函数中调用。
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 100 * 10 ** uint(decimals()));
    }
    //开放mint功能，任何账户都能触发mint操作，需要严密的modifier前置判断
    function mint(address account, uint256 amount) public {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        //调用internal的_mint实现mint功能
        _mint(account, amount);
       // _update(address(0), account, amount);
    }

//调用internal的_burn 实现代币销毁
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}
```