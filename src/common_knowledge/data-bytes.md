# bytes
- `bytes` 比较特殊，是数组，但是不用加[]声明
- 字节数组 `bytes` 分为定长数值类型和不定长引用类型
  - 定长数值数组（`bytes1~bytes32`）能通过 `index` 获取数据
  - 不定长数组 `bytes ...`
```solidity
    // 固定长度的字节数组
    bytes32 public _byte32 = "MiniSolidity"; 
    bytes1 public _byte = _byte32[0]; //0x4d
```
