# bytes/string
## bytes
- `bytes` 是不用加 `[]` 声明的动态数组
- `hex` 修饰 `bytes` 数据
- `bytes.concat()` 直接拼接 `bytes` 数据
- 字节数组 `bytes` 分为定长数值类型和不定长引用类型
  - 定长数值数组（`bytes1~bytes32`）能通过 `index` 获取数据
  - 不定长数组 `bytes ...` 是动态类型，传参时需要 `memory|calldata` 修饰，作为参数返回时需要 `memory` 修饰
## string
- `string` 是 `UTF-8 ` 编码的 `bytes` 类型
  - `string` 和 `bytes` 数据可以互相转换 `string()， bytes()`
  - `string` 传参 `ASCII` 字符,此时每个字符占据1位，可以通过 `index` 直接读取值
  - `string` 传参 `Unicode` 字符,此时每个字符占据多位，不能通过 `index` 直接读取值
- 在 `solidity 0.8.12+` ，`string.concat()` 直接拼接多个 `string` 字符串
```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract BytesStringData {
  string private constant NATIE = unicode"👋酱香拿铁";
  string private constant HELL = unicode"Hello 😃";
  string private constant UTF8CODE = "Hello World";
  bytes private hexData = hex"68656C6C6F776F726C64";

  function characterOfString(string memory input, uint256 index)
  external
  pure
  returns (string memory)
  {
    bytes memory char = new bytes(1);
    char[0] = bytes(input)[index];
    return string(char);
  }

  function characterOfStringLength(string memory input)
  external
  pure
  returns (uint256)
  {
    return bytes(input).length;
  }

  function concatMulString() external view returns (string memory) {
    return string.concat(string(hexData), NATIE, UTF8CODE);
  }

  function concatMulBytes() external view returns (bytes memory) {
    return bytes.concat(hexData, bytes(NATIE));
  }
}
```

## Preference
https://www.rareskills.io/learn-solidity/strings
