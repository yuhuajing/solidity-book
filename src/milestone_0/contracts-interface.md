# 接口
- 接口只能定义函数骨架 
- 接口通过<kbd>interface</kbd>关键字修饰

## 接口函数
- 接口合约内部不能定义状态变量
- 继承接口必须实现内部的全部函数 
- 接口合约内部不能包含构造函数 
- 接口不能继承除接口外的其他合约 
- 接口内部的函数必须使用external修饰
- 接口函数不需要virtual修饰，因为继承接口需要实现接口内的全部函数
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

interface IERC721 {
    event Getbal(address indexed owner);

    function balanceOf(address owner) external returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);
}

contract myToken is IERC721 {
    mapping(address => uint256) balances;

    function deposit() public payable {
        balances[msg.sender] += 1000;
    }

    function balanceOf(address owner) external returns (uint256) {
        emit Getbal(owner);
        return balances[owner];
    }

    function ownerOf(uint256 tokenId) external view returns (address owner) {}

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}

contract interactBAYC {
    // 利用BAYC地址创建接口合约变量（ETH主网）
    IERC721 BAYC = IERC721(0xAc40c9C8dADE7B9CF37aEBb49Ab49485eBD3510d);

    // 通过接口调用BAYC的balanceOf()查询持仓量
    function balanceOfBAYC(address owner) external returns (uint256 balance) {
        return BAYC.balanceOf(owner);
    }
}
```


