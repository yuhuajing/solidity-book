# unicode
solidity(^0.7)的版本支持有效地 UTF-8 字符
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Unicode {
    string public constant natie = unicode"酱香拿铁";
    string public constant hell = unicode"Hello 😃";
}
```
