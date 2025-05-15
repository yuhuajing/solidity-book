# Create3
关键字 [CREATE3](https://github.com/0xsequence/create3/blob/master/contracts/Create3.sol) 不是 `EVM` 原生操作码，
而是 一种高阶设计模式（通常通过库如 [Solady](https://github.com/Vectorized/solady/blob/main/src/utils/CREATE3.sol) 实现），
它是在 `CREATE + CREATE2` 之上构建的，目的是避免地址碰撞并更强确定性。

## 🔸CREATE3 是什么？
`CREATE3`是一种部署模式 / 合约工厂模式，
用可预测、稳定的地址部署合约（去除 init_code带来的影响）

## 🔧 CREATE3 工作方式（简化）
分两步：

- 通过 `CREATE2` 部署一个中间代理（`proxy`）合约，其地址是固定的（由 `salt` 和 `deployer` 决定）
  - 和 `init_code` 无关，使用一个确定的值
- 这个 `proxy` 合约作为最小的 `CREATE` 实现，用于部署目标合约

  | 特性                 | CREATE2                 | CREATE3                   |
  | ------------------ | ----------------------- | ------------------------- |
  | 可预测性               | ✅ 可预测（但受 init\_code 影响） | ✅ 更强（仅依赖 salt）            |
  | 地址复用性              | ❌ 相同 salt + code 会失败    | ✅ 每次部署都是新地址（nonce 变化）     |
  | init\_code 变更影响地址？ | 是的                      | 否，地址不变                    |
  | 多次部署同一 salt？       | ❌ 不可（地址冲突）              | ✅ 可（proxy nonce + CREATE） |

## 地址推导
`CREATE3` 模式 中的地址推导机制，其中涉及：

- 一个 `proxy` 合约（由 `CREATE2` 部署，地址可预测） 
- 最终的目标合约（由 `proxy` 用 `CREATE` 部署）

### 🧩 第一部分：计算 proxy 的地址（CREATE2） 
`proxy_address = keccak256(0xff ++ deployer ++ salt ++ keccak256(init_code))[12:]`

其中 `Proxy` 合约作为 `CREATE` 合约的最小代理实现：
```solidity
  bytes internal constant PROXY_CHILD_BYTECODE = hex"67_36_3d_3d_37_36_3d_34_f0_3d_52_60_08_60_18_f3";

  //                        KECCAK256_PROXY_CHILD_BYTECODE = keccak256(PROXY_CHILD_BYTECODE);
  bytes32 internal constant KECCAK256_PROXY_CHILD_BYTECODE = 0x21c35dbe1b344a2488cf3321d6ce542f8e9f305544ff09e4993a62319a497c1f;
```
计算/部署 `Proxy` 地址

```text
[Deployer 合约]
     |
     |-- CREATE2 部署 Proxy 合约（固定 bytecode）
     v
[Proxy 合约（中转器）]

```
```solidity
 address proxy = address(
      uint160(
        uint256(
          keccak256(
            abi.encodePacked(
              hex'ff',
              address(this),
              _salt,
              KECCAK256_PROXY_CHILD_BYTECODE
            )
          )
        )
      )
    );
    //deploy proxy
    address proxy; assembly { proxy := create2(0, add(creationCode, 32), mload(creationCode), _salt)}
```

这里与 `init_code` 完全无关！

| 项目             | 是否影响地址？  | 原因                                          |
| -------------- | -------- | ------------------------------------------- |
| `factory` 地址   | ✅        | 影响 proxy 地址（通过 CREATE2）                     |
| `salt`         | ✅        | 影响 proxy 地址                                 |
| `proxy` 的部署代码  | ✅（但通常固定） | 影响 proxy 地址                                 |
| 🔥 `init_code` | ❌        | 不影响最终地址（它由 proxy 用 CREATE 部署，不看 init\_code） |



### 🧩 第二部分：从 proxy 地址推导目标合约地址（CREATE）
```text
[Deployer]
   |
   |-- CALL(proxy, data: init_code, value: X)
   v
[Proxy 合约]
   |
   |-- CALLDATACOPY        ← 把 init_code 拷贝到 memory[0:]
   |-- CALLVALUE           ← 获取 msg.value
   |-- CREATE(value, memory[0:], size)
   |
   |-- 返回 newly created 合约地址

```
```solidity
 // Call proxy with final init code
  (bool success,) = proxy.call{ value: _value }(_creationCode);
  if (!success || codeSize(addr) == 0) revert ErrorCreatingContract();
```
- `proxy.call(...)` 是执行实际的目标合约部署 
- `proxy` 内部通常会执行 `create(...)`（标准 `CREATE`），把 `_creationCode` 执行并部署为 `runtime code `
- `codeSize(addr)` 再次检查部署是否成功

### 🧠 CREATE3 的设计核心
```text
[Deployer]
   |
   |---> 部署 Proxy at deterministic address (via CREATE2)
          |
          |---> Proxy uses CREATE(init_code)
                  |
                  |---> 部署目标合约 at deterministic CREATE address

```
这一设计将 CREATE2 和 CREATE 分离：

| 动作           | 用途           | 技术方式      |
| ------------ | ------------ | --------- |
| 部署 proxy     | 为部署目标合约创建中继器 | `CREATE2` |
| proxy 部署目标合约 | 真正部署用户逻辑     | `CREATE`  |


### ✅ CREATE3 模式的本质优势
```text
+-------------------------+
|   Deployer Contract     |
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
通过这种 `CREATE2 + proxy + CREATE` 的链式部署方式：
- 用户只需知道 `salt` → 能预测最终合约地址 
  - addr = addressOf(_salt) 总是 唯一且可预测
  - addr 不依赖 init code 的内容
#### 即使目标合约 `init_code` 不同，地址也能稳定（与 `CREATE2` 不同）
假设我们用相同的 salt：
```solidity
salt = keccak256("user1");
```
第一次你部署的是 `SimpleStorage(uint256)`
第二次你部署的是 `ERC20(string,string)`

结果：

`proxy` 的地址是一样的（由 `factory + salt + proxy_code` 决定）

`proxy nonce = 1`（第一次创建）

所以最终目标合约地址是一样的（即使代码完全不同）

只要销毁 `proxy` 合约（或用不同 `salt`），就能重新部署。
- `salt` 可重用（每次部署都新建 `proxy`，`proxy` `nonce` 不冲突）

#### ✅ CREATE3 的带来的能力
- 地址高度可预测 
- 与构造参数、初始化逻辑无关 
- 允许链上用户事先知道部署地址 → 链上注册、链上 DNS、授权管理 等场景非常适合

### 🧠 背景：CREATE3 中的 salt 复用
```solidity
proxy = keccak256(0xFF, deployer, salt, keccak256(proxy_bytecode))
```

如果想重新用同一个 `salt` 来部署新合约，必须清除上一次部署时用的 `proxy`,因为 `CREATE2` 不能在已有合约地址上重新部署

#### ✅ 方法一：让 proxy 自毁（添加自毁逻辑）
```solidity
function kill() external {
    selfdestruct(payable(msg.sender));
}
```

#### ✅ 方法二：让 proxy 自动 selfdestruct（推荐）
```solidity
CREATE
SELFDESTRUCT
```
这样 `proxy` 完成部署目标合约后会立即销毁，释放地址
```text
[Deployer]
   |
   |---> CREATE2(proxy, salt)
           |
           |---> Proxy uses CREATE -> deployed_contract
           |---> Proxy executes selfdestruct() <--🧹 清除

```

示例合约
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SelfDestructProxy {
    fallback() external payable {
        assembly {
            // 获取 calldata size 和地址 0 位置的内存
            let size := calldatasize()
            calldatacopy(0x0, 0x0, size)    // 把 init_code 拷贝到内存0x0开始

            // 调用 create 部署目标合约，传递所有的ETH
            let addr := create(callvalue(), 0x0, size)

            // 如果 create 失败则 revert
            if iszero(addr) {
                revert(0, 0)
            }

            // 自毁 proxy，释放地址
            selfdestruct(caller())
        }
    }
}

```

#### `Dencun` 升级后（EIP-6846 & EIP-4750 等相关提案）：

- `selfdestruct` 不会立即清理状态数据，也不释放合约地址。 
- 合约代码会被清空（变为空），但合约存储状态依然保留（变为"孤儿"状态）。 
- 合约地址依然被认为已使用，不能重复部署。

| 旧版本 EVM             | Dencun 升级后 EVM             |
| ------------------- | -------------------------- |
| `selfdestruct` 释放地址 | `selfdestruct` 仅清空代码，不释放地址 |
| 可以用同一个 salt 复用地址    | 不可用同一个 salt 复用地址           |
| 多次部署同一 salt 实现升级    | 需要换新 salt 或改用其他升级方案        |
