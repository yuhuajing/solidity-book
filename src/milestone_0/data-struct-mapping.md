# mapping
- mapping(key ==> value) public map0;
- key 必须是默认的类型，不能使用自定义的类型
- value 可以是任意类型，包含自定义的结构体数据结构
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Mapping {
    // Mapping from address to uint
    mapping(address => uint256) public myMap;
    // Mapping from nft address and user address to his nft id
    mapping(address => mapping(address => uint256)) public addressNFTIds;

    struct myStruct {
        address NFT;
        address Operator;
    }
    // Mapping from nft address and user address to his approvor

    mapping(address => myStruct) public addressApprovedInfo;

    function updateMapping(
        address nft,
        address operator,
        uint256 id
    ) public {
        myMap[msg.sender] = id;
        addressNFTIds[nft][msg.sender] = id;
        addressApprovedInfo[msg.sender] = myStruct(nft, operator);
    }
}
```
