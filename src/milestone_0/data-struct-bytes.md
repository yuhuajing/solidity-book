# bytes
- 在声明时指定数组的长度，bytes比较特殊，是数组，但是不用加[]声明
- bytes xxx; //动态数组
- 字节数组`bytes`分为定长数值类型和不定长引用类型。定长数值数组（bytes1~bytes32）能通过index获取数据
- <kbd>MiniSolidity</kbd>以字节的方式存储，32个字节64位，转为16进制为<kbd>0x4d696e69536f6c69646974790000000000000000000000000000000000000000</kbd>
- <kbd>_byte</kbd>存储第一个字节<kbd>0x4d</kbd>
```solidity
    // 固定长度的字节数组
    bytes32 public _byte32 = "MiniSolidity"; 
    bytes1 public _byte = _byte32[0]; 
```
