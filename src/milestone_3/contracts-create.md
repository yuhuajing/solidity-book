# 创建合约
合约通过关键字 [CREATE](https://www.evm.codes/?fork=cancun#f0)，[CREATE2](https://www.evm.codes/?fork=cancun#f5),[CREATE3](https://github.com/Vectorized/solady/blob/main/src/utils/CREATE3.sol) 创建
## CREATE
- 新合约地址 `address = keccak256( 0xd6 ++ 0x94 ++ deploying_address ++ nonce )[12:]`
  - `0xd6_94` 是 `RLP` 编码的前缀：`0xd6` 是 `list` 长度标记，`0x94` 表示地址是 `20` 字节 
  - `deploying_address` 是部署者地址 
  - 部署者 `nonce`，表示这是部署者第几次调用 `CREATE` 创建合约
    - 同一条链上的账户地址 `nonce` 递增，因此账户在相同链上无法部署同样的合约账户 
    - 同样地址在不同链上，能过够通过相同 `nonce` 值部署相同地址的合约
### 最简单的CREATE字节码以及初始化操作
```solidity

    // 高亮：hex 值    | 含义                    | 说明
    //----------------------------------------------------------------------------------------
    0x36            // CALLDATASIZE           | 获取 calldata 的长度，stack: [size]
    0x3d            // RETURNDATASIZE (0)     | 压入 0，stack: [0, size]
    0x3d            // RETURNDATASIZE (0)     | 再压一个 0，stack: [0, 0, size]
    0x37            // CALLDATACOPY           | memory[0:] = calldata，复制 init_code
    0x36            // CALLDATASIZE           | 再压入 size
    0x3d            // RETURNDATASIZE (0)     | 再压入 0，stack: [0, size]
    0x34            // CALLVALUE              | 压入 msg.value，stack: [value, 0, size]
    0xf0            // CREATE                 | 使用 create(value, 0, size) 部署合约
    //----------------------------------------------------------------------------------------
    0x3d            // RETURNDATASIZE (0)     | 继续：获取 return size 0（只是为了推入 0）
    0x52            // MSTORE                 | memory[0] = returnVal（部署后地址）
    0x60 0x08       // PUSH1 0x08             | 压入长度 8
    0x60 0x18       // PUSH1 0x18             | 压入 offset = 24 (即 0x18)
    0xf3            // RETURN                 | return memory[24:24+8]（就是地址）

    bytes internal constant PROXY_BYTECODE = hex"67_36_3d_3d_37_36_3d_34_f0_3d_52_60_08_60_18_f3";
```
#### 模拟执行过程
```text
1. 外部传入 完整的 init_code（creationCode），call 工厂合约
2. 工厂合约 把 init_code 拷贝进 memory[0:]
3. 工厂合约 使用 CREATE 创建合约（使用 msg.value），创建报错包含构造函数的初始化过程
4. 返回新合约地址（前 20 字节）作为 returndata
```

图示：
```text
[Deployer]
   |
   |-- CALL(工厂合约, data: init_code, value: X)
   v
[工厂合约 合约]
   |
   |-- CALLDATACOPY        ← 把 init_code 拷贝到 memory[0:]
   |-- CALLVALUE           ← 获取 msg.value
   |-- CREATE(value, memory[0:], size)
   |
   |-- 返回 newly created 合约地址
```

🧠 为什么用这个流程（优点）

✅ 最终合约地址只由 工厂合约 地址 和 nonce 决定

✅ init_code 不影响最终合约地址（可预测 + 重复部署）

✅ 利用 CREATE 的递增 nonce 实现稳定的地址生成

✅ 整个 工厂合约 是极简指令集（20 字节以内）
## New
- 新合约地址：`Contract x = new Contract{value: _value，salt: salt}(params)`
- `new` 关键字创建新的合约地址
  - `value` 表明创建合约是是否转账,构造函数需要使用 `payable` 修饰
  - `salt` 表明当前新建地址是否采用 `CREATE2` 关键字
  - `constructor parameters` 表明新建合约时传递的初始化参数
## CREATE2
> `creation_code = memory[offset:offset+size]`
>
> `address = keccak256(0xff + sender_address + salt + keccak256(init_code))[12:]`
- 通过自定义的 `salt` 和 `合约代码` 替换递增的 `nonce` 值
  - `合约代码` 一般选择合约的 [init_code 完整codes](./contracts-creationcodes.md)
    - 也就是说，传进去的 `bytecode`，其实是一个会在部署时被执行的初始化代码，它在执行完成后会：
    - 执行 `constructor`
    - 返回 `runtime code`
    - 这个 `runtime code` 就是部署后合约在链上真正存在的代码
  - 那为什么我们用的是 `type(MyContract).creationCode`？
    - ✅ 正确：`type(MyContract).creationCode` 就是合约的完整 `init code`
    - 所有构造函数逻辑
    - 所有初始化代码
    - `return` 语句：把 `runtime code` 返回给链
- 在相同链上通过相同的 `salt` 和 `合约构造函数的代码`，就可以实现同地址合约的提前使用

  | 使用对象                              | 是否正确？ | 原因                                      |
    |-----------------------------------| ----- | --------------------------------------- |
  | `type(MyContract).creationCode`   | ✅ 正确  | 包含 constructor 和返回逻辑，完整的 `init code`    |
  | `address(MyContract).runtimeCode` | ❌ 错误  | 是部署后 runtime code，不含 constructor，不可执行部署 |

## Create 和 Create2 对比

| 操作码       | 说明      | 地址可预测性 | 地址计算涉及                      |
| --------- | ------- | ------ | --------------------------- |
| `CREATE`  | 普通部署    | ❌ 不可预测 | nonce + sender              |
| `CREATE2` | 可预测部署地址 | ✅ 可预测  | `sender + salt + init_code` |

## 完整 Solidity Contracts
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// This is the older way of doing it using assembly
contract CreateNewContract {
    event Create2Created(address addr, bytes32 salt);
    event CreateCreated(address addr);

    // 1. Deploy the contract by CREATE
    function Create(address _owner, uint256 _num) external payable {
        bytes memory bytecode = getBytecode(_owner, _num);
        _create(bytecode, "");
    }

    // 2. Deploy the contract by CREATE2
    function Create2(
        address _owner,
        uint256 _num,
        bytes32 salt
    ) external payable {
        bytes memory bytecode = getBytecode(_owner, _num);
        _create(bytecode, salt);
    }

    function _create(bytes memory bytecode, bytes32 salt) internal {
        address addr;
        if (keccak256(abi.encode(salt)) == keccak256("")) {
            /*
        NOTE: How to call create
        create(v, p, n)
        create new contract with code at memory p to p + n
        and send v wei
        and return the new address
        */
            assembly {
                addr := create(
                    callvalue(), // wei sent with current call
                    // Actual code starts after skipping the first 32 bytes
                    add(bytecode, 0x20),
                    mload(bytecode) // Load the size of code contained in the first 32 bytes
                )

                if iszero(extcodesize(addr)) {
                    revert(0, 0)
                }
            }
            emit CreateCreated(addr);
        } else {
            /*
        NOTE: How to call create2
        create2(v, p, n, s)
        create new contract with code at memory p to p + n
        and send v wei
        and return the new address
        where new address = first 20 bytes of keccak256(0xff + address(this) + s + keccak256(mem[p…(p+n)))
              s = big-endian 256-bit value
        */
            assembly {
                addr := create2(
                    callvalue(), // wei sent with current call
                    // Actual code starts after skipping the first 32 bytes
                    add(bytecode, 0x20),
                    mload(bytecode), // Load the size of code contained in the first 32 bytes
                    salt // Salt from function arguments
                )

                if iszero(extcodesize(addr)) {
                    revert(0, 0)
                }
                // if no address was created, and returndata is not empty, bubble revert
                if and(iszero(addr), not(iszero(returndatasize()))) {
                    let p := mload(0x40)
                    returndatacopy(p, 0, returndatasize())
                    revert(p, returndatasize())
                }
            }
            emit Create2Created(addr, salt);
        }
    }

    // 3. Deploy the create contract by new
    function NewCreate(address _owner, uint256 _num)
        public
        payable
        returns (address)
    {
        return address(new targetContract{value: msg.value}(_owner, _num));
    }

    // 4. Deploy the create2 contract by new
    function NewCreate2(
        address _owner,
        uint256 _num,
        bytes32 salt
    ) public payable returns (address) {
        // This syntax is a newer way to invoke create2 without assembly, you just need to pass salt
        // https://docs.soliditylang.org/en/latest/control-structures.html#salted-contract-creations-create2
        return
            address(
                new targetContract{salt: salt, value: msg.value}(_owner, _num)
            );
    }

    // Get bytecode of contract to be deployed
    // NOTE: _owner and _num are arguments of the targetContract's constructor
    function getBytecode(address _owner, uint256 _num)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory bytecode = type(targetContract).creationCode;
        return abi.encodePacked(bytecode, abi.encode(_owner, _num));
    }

    // Compute the address of the contract to be deployed
    // NOTE: _salt is a random number used to create an address
    function getAddress(
        address _owner,
        uint256 _num,
        bytes32 salt
    ) external view returns (address) {
        bytes memory _bytecode = type(targetContract).creationCode;
        bytes memory bytecode = abi.encodePacked(
            _bytecode,
            abi.encode(_owner, _num)
        );
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                salt,
                keccak256(bytecode)
            )
        );

        // NOTE: cast last 20 bytes of hash to address
        return address(uint160(uint256(hash)));
    }
}

contract targetContract {
    address public owner;
    uint256 public num;

    constructor(address _owner, uint256 _num) payable {
        owner = _owner;
        num = _num;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
```

## 通过Nonce+Sender计算合约地址
使用 RLP 规则模拟 普通 `CREATE` 部署的地址计算，其中： 
- `rlpOffset` 是 `RLP` 编码中 `CREATE` 地址的固定前缀 
- `sender` 是部署者地址 
- `rlpNonce` 是递增 `nonce`

| Nonce     | RLP Encoded As    |   |             |
| --------- | ----------------- | - | ----------- |
| 0         | `0x80`            |   |             |
| 1–127     | 单字节直接编码（如 `0x01`） |   |             |
| 128–255   | \`0x81            |   | <1 byte>\`  |
| 256–65535 | \`0x82            |   | <2 bytes>\` |
| ...       | ...               |   |             |

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract FindSC {
  function computeCreateAddress(address sender, uint256 nonce)
  external
  pure
  returns (address)
  {
    bytes memory rlpNonce;
    bytes memory rlpOffset;

    if (nonce == 0x00) {
      rlpNonce = abi.encodePacked(uint8(0x80));
      rlpOffset = abi.encodePacked(uint8(0xd6), uint8(0x94));
    } else if (nonce <= 0x7f) {
      rlpNonce = abi.encodePacked(uint8(nonce));
      rlpOffset = abi.encodePacked(uint8(0xd6), uint8(0x94));
    } else if (nonce <= 0xff) {
      rlpNonce = abi.encodePacked(uint8(0x81), uint8(nonce));
      rlpOffset = abi.encodePacked(uint8(0xd7), uint8(0x94));
    } else if (nonce <= 0xffff) {
      rlpNonce = abi.encodePacked(uint8(0x82), bytes2(uint16(nonce)));
      rlpOffset = abi.encodePacked(uint8(0xd8), uint8(0x94));
    } else if (nonce <= 0xffffff) {
      rlpNonce = abi.encodePacked(uint8(0x83), bytes3(uint24(nonce)));
      rlpOffset = abi.encodePacked(uint8(0xd9), uint8(0x94));
    } else {
      rlpNonce = abi.encodePacked(uint8(0x84), bytes4(uint32(nonce)));
      rlpOffset = abi.encodePacked(uint8(0xda), uint8(0x94));
    }
    return
      address(
      uint160(
        uint256(
          keccak256(abi.encodePacked(rlpOffset, sender, rlpNonce))
        )
      )
    );
  }
}
```
