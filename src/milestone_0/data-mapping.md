# mapping
- `Mapping` 只能定义成状态变量，不能在函数内部定义成局部变量
- `Mapping` 无法遍历，只能通过 `key` 值获取对应的 `value`
- `Mapping` 类型不能作为函数的返回值
- `mapping(key ==> value) [public|private] xxx`
  - 键值 `key` 必须是默认的类型，不能使用自定义的类型
  - `value` 可以是任意类型，包含自定义的结构体数据结构
  - `key` 值对应的 `value` 不存在的时候，会返回 `value` 的默认值，不会 `revert`
```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

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

  function updateOperatorNFT(
    address nft,
    address operator,
    uint256 id
  ) public {
    mapping(address => uint256) storage _tokensByNft = addressNFTIds[nft];
    _tokensByNft[operator] = id;
  }
}
```
