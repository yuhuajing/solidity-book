# [contract-sstore2](https://github.com/0xsequence/sstore2/blob/master/contracts/utils/Bytecode.sol)

## 🔹 使用 SSTORE2 高效存储大量数据
🧱 背景：`SSTORE<key,value>` 的高成本

在以太坊虚拟机（`EVM`）中，`SSTORE` 是用来将数据写入链上存储的指令，
采用的是键值对（`key-value`）结构，每个键值都是 `32` 字节。

但是，使用 `SSTORE` 和 `SLOAD`（读取）都非常昂贵：

写入数据（`SSTORE`）：

```css
static_gas = 0

if value == current_value
    base_dynamic_gas = 100
else if current_value == original_value
    if original_value == 0
        base_dynamic_gas = 20000
    else
        base_dynamic_gas = 2900
else
    base_dynamic_gas = 100

// On top of the cost above, 2100 is added to base_dynamic_gas if the slot is cold.
```

写入合约字节码（如通过 `CREATE` 部署合约）：
```css
minimum_word_size = (size + 31) / 32
init_code_cost = 2 * minimum_word_size
code_deposit_cost = 200 * deployed_code_size

static_gas = 32000
dynamic_gas = init_code_cost + memory_expansion_cost + deployment_code_execution_cost + code_deposit_cost
```

### 🚀 SSTORE2 是什么？
`SSTORE2` 是一种创新的链上数据存储方式，它不再使用传统的 `SSTORE` 存储键值对，而是：

将你想要保存的数据写入一个新部署合约的字节码中

这样做的优势：
- 合约字节码是不可更改的，天然具备数据完整性
- 数据只写入一次，适合大数据量写入、只读场景
- 在数据量较大的前提下，读取/写入成本远低于 `SSTORE/SLOAD`

### ✍️ 如何使用 SSTORE2？
✅ 写入数据（部署数据合约）

- 准备数据：你希望存储的数据（如图片、`JSON`、元数据等）是一个 `bytes` 数组。
- 构造初始化代码：将数据复制到内存，并把它设为新合约的运行时代码（`runtime code`）。
- 部署新合约：使用 `CREATE` 或 `CREATE2` 创建一个包含该数据的新合约。

> 🔧 技巧：我们可以使用一段特殊的 bytecode 进行部署，例如：

```kotlin
0x61_0000_80_600a_3d_39_3d_f3
```
这段代码是合约创建初始化代码（`init_Code`），它会在 `CREATE` 被调用时执行:
把从 `offset=0x0a` 开始的字节数据复制到内存，然后 `RETURN` 成为合约 `runtime bytecode`。

> Init Code 是在部署时运行的，最终会将其返回值作为合约的 runtime bytecode 写入链上

#### 🔍 字节码分解（每个指令含义）

📐 第一步：合约字节码布局

| Byte | Opcode  | 含义                             |
| ---- | ------- | ------------------------------ |
| 0x00 | 61 0041 | `PUSH2 0x0041`（=65 bytes）      |
| 0x03 | 80      | `DUP1`（复制顶层：0x0041）            |
| 0x04 | 60 0a   | `PUSH1 0x0a`                   |
| 0x06 | 3d      | `RETURNDATASIZE`（=0）           |
| 0x07 | 39      | `CODECOPY(dest, offset, size)` |
| 0x08 | 3d      | `RETURNDATASIZE`（=0）           |
| 0x09 | f3      | `RETURN(dest=0, size=65)`      |

🧠 执行流程及内存变化图解

我们以 `EVM` 内存为一个 `0-based` 的连续区域表示，使用 [offset] = value 方式可视化：

✅ 执行前：

内存和栈为空（未写入）

```scss
Stack: []
Memory: 全 0
```
1️⃣ `PUSH2 0x0041`（字节码：`61 0041`）

📦 Stack:
```kotlin
stack ← 0x0041

Top → 0x0041
```

2️⃣ DUP1（字节码：`80`）

复制栈顶元素 `0x0041`

📦 Stack:
```kotlin
Top → 0x0041
        0x0041
```
3️⃣ `PUSH1 0x0a`（字节码：`60 0a`）

压入 `0x0a`，作为 `code offset`

📦 Stack:
```kotlin
Top → 0x0a
        0x0041
        0x0041
```

4️⃣ `RETURNDATASIZE`（字节码：`3d`）

`RETURNDATASIZE` 将最近一次外部调用（例如 `call`, `staticcall`, `delegatecall` 等）
返回的数据大小压入栈顶。

调用前未执行任何外部 `call`, 因此将 `0` 压入栈
📦 Stack:
```kotlin
Top → 0x00
        0x0a
        0x0041
        0x0041
```

5️⃣ `CODECOPY`（字节码：`39`）
```kotlin
CODECOPY(dest, offset, size)

栈出栈顺序：
    size   ← 0x0041
    offset ← 0x0a
    dest   ← 0x00
```

此时： 从代码 `offset 0x0a = 10 bytes` 开始，复制 `0x41` 字节（`65 bytes`）
写入内存 `0x00` 开始的区域

📊 内存变化（代码段假设）

在字节码中，从 `offset 0x0a` 开始是我们要写入的 `data`（以示例简化）：
```text
[0x0a] = 00 aa bb cc dd ee ...
```

其中,`data` 开头的 `0x00` 是 `STOP` 指令，用于防止外部直接调用执行这段字节码。

写入后，内存 `0x00` 处是 data：
```makefile
Memory:
0x00: 00 aa bb cc dd ee ff ...
```
📦 Stack after CODECOPY:

只剩 `size` （`DUP1` 的副本）
```css
Top → 0x0041
```

6️⃣ RETURNDATASIZE → 0

调用前未执行任何外部 `call`, 因此将 `0` 压入栈

📦 Stack:
```css
Top → 0x00
        0x0041
```

7️⃣ `RETURN`（`f3`）

从内存 `0x00` 开始返回 `65` 字节。

### 0xsequence合约最简代码
合约代码实现将全部的 `codes` 写入/读取 

其中：
- `size` 类型 `uint32`, 占据 `4 bytes`
- 使用 `0x6000      PUSH1 00` 代替 `RETURNDATASIZE`
```solidity
  function creationCodeFor(bytes memory _code) internal pure returns (bytes memory) {
    /*
      0x00    0x63         0x63XXXXXX  PUSH4 _code.length  size
      0x01    0x80         0x80        DUP1                size size
      0x02    0x60         0x600e      PUSH1 14            14 size size
      0x03    0x60         0x6000      PUSH1 00            0 14 size size
      0x04    0x39         0x39        CODECOPY            size
      0x05    0x60         0x6000      PUSH1 00            0 size
      0x06    0xf3         0xf3        RETURN
      <CODE>
    */

    return abi.encodePacked(
      hex"63",
      uint32(_code.length),
      hex"80_60_0E_60_00_39_60_00_F3",
      _code
    );
  }

    function write(bytes memory _data) internal returns (address pointer) {
        // Append 00 to _data so contract can't be called
        // Build init code
        bytes memory code = creationCodeFor(
            abi.encodePacked(
                hex'00', // STOP 防止调用codes
                _data
            )
        );

        // Deploy contract using create
        assembly { pointer := create(0, add(code, 32), mload(code)) }

        // Address MUST be non-zero
        if (pointer == address(0)) revert WriteError();
    }
```

### 📥 读取数据（从合约字节码中读取）

获取存储数据的合约地址（部署时返回）

使用 `EXTCODECOPY` 从合约字节码中读取数据

从第一个字节偏移 `1`（跳过 `STOP` 指令）开始读取

### 🧠 总结
| 比较项     | SSTORE         | SSTORE2                      |
| ------- | -------------- | ---------------------------- |
| 存储方式    | 键值对（slot）      | 写入合约字节码                      |
| 写入成本    | 22,100 gas/32B | 200 gas/B（写数据越多越省）           |
| 是否可变    | 可变（覆盖）         | 不可变（合约代码不能更改）                |
| 是否可读取   | 使用 `SLOAD`     | 使用 `EXTCODECOPY` 读取 bytecode |
| 是否适合大数据 | ❌              | ✅ 非常适合一次写入，频繁读取              |

## SSTORE2Map/SSTORE3
`SSTORE2` 使用 `CREATE/CREATE2` 创建目标合约

[SSTORE3](https://github.com/Philogy/sstore3/blob/main/src/SSTORE3_L.sol)  和 `SSTORE2Map` 结合 [CREATE3](./contracts-create3.md),使用 `salt` 值作为 `key`，用于产生确定的 `Proxy`，
然后 `Proxy` 基于 `SSTORE2` 中的合约 `codes` 部署目标合约
```solidity
  function write(string memory _key, bytes memory _data) internal returns (address pointer) {
    return write(keccak256(bytes(_key)), _data);
  }
```

```text
+-------------------------+
|    SSTORE2Map Contract     |
|-------------------------|
| - call SSTORE2Map'write  (salt,init_code) |
|-------------------------|
| - Deploy Proxy via      |
|   CREATE2(salt, bytecode) |
|                         |
| - Call Proxy with       |
|   init_code + value     |
+-------------------------+
           |
           v
+-------------------------+
|      Proxy Contract     |
|-------------------------|
| - Receives init_code    |
| - Executes CREATE       |
|   with that init_code   |
| - Returns new address   |
+-------------------------+
           |
           v
+-------------------------+
|   Final Deployed Contract |
+-------------------------+
```