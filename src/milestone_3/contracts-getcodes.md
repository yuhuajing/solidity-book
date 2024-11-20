# [contract-codes](https://www.rareskills.io/post/solidity-code-length)
判断是否是合约地址的三种方式
- `msg.sender==tx.origin`
- `EXTCODESIZE` 读取 `code.length` 
- `EXTCODEHASH` 读取 `code.hash`
## msg.sender==tx.origin
- `tx.origin` 是当前交易的签名地址
- `msg.sender` 是当前 `EVM` 执行环境中的交易发送地址
- 对于 `EOA` 直接发起的的合约交易，合约内部：`msg.sender==tx.origin`
- 合约之间外部调用重启 `EVM` 执行环境的外部调用：`msg.sender!=tx.origin`
![](./images/tx-origin-sender.png)
## EXTCODESIZE
- `codeSize = 0`, 不表示该地址一定是 `EOA` 地址
  - 有可能是预定义的 `create2` 地址，未来会部署成为合约
  - 对方在 `constructor()` 中调用 `call` 交易，此时合约未存储上链，`codeSize = 0`
- [selfdestruct](./contracts-destroy.md)在 `dencun` 升级后并不会清除合约状态和代码，因此 codeSize != 0
## Solidity Examples
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TestAddressSize {
    event codeSize(uint256);

    function constructorCodeSize() external {
        uint256 codes;
        address sender = msg.sender;
        assembly {
            codes := extcodesize(sender)
        }
        emit codeSize(codes);
    }

    // 765 gas
    function codesize(address target) public view returns (bool isContract) {
        if (target.code.length == 0) {
            isContract = false;
        } else {
            isContract = true;
        }
    }

    // 779 gas
    function codesizeAssm(address target) public view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(target)
        }
        return size != 0;
    }
}

contract onlyConstructor {
    constructor() {
        address addr = 0x10E2fC1dE57DDC788489122151a6c45254D3ba59;
        (bool success, ) = addr.call(
            abi.encodeWithSignature("constructorCodeSize()")
        );
        if (!success) {
            revert();
        }
    }
    // [
    // 	{
    // 		"from": "0x10E2fC1dE57DDC788489122151a6c45254D3ba59",
    // 		"topic": "0x35bbf8dac6652434e49dd256e75001562f8cabc9ab024b4ed3f7826b3ab5a81f",
    // 		"event": "codeSize",
    // 		"args": {
    // 			"0": "0"
    // 		}
    // 	}
    // ]
}

contract afterSelfDestruct {
    function deposit() external payable {}

    // 销毁后并不会影响合约的使用
    // 销毁保留合约的状态的代码
    // 销毁仅仅是强制将合约余额转出
    function kill() external {
        selfdestruct(payable(msg.sender));
    }
}
```
## EXTCODEHASH
- 返回 `keccak256(codes)`
- 如果地址 `balance == 0 && codeSize == 0`, 返回 `bytes32(0)`
- 如果地址 `balance != 0 && codeSize == 0`, 返回 `keccak256(""")=0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470`
- 如果地址 `codeSize != 0`, 返回 `keccak256(codes)`
- 全部 [预编译](../Milestone3/contracts-precompile.md)合约预存 `1wei`,因此会返回空值的 `hash`
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TestAddressSize {
    event codeHash(bytes32);

    function constructorCodeHash() external {
        bytes32 codehashs;
        address sender = msg.sender;
        assembly {
            codehashs := extcodehash(sender)
        }
        emit codeHash(codehashs);
    }

    //  gas
    function codehash(address target) public view returns (bytes32 hash) {
        hash = target.codehash;
    }

    //  gas
    function codesizeAssm(address target) public view returns (bytes32 hash) {
        assembly {
            hash := extcodehash(target)
        }
    }
}

contract onlyConstructor {
    //0x0000000000000000000000000000000000000000000000000000000000000000
    constructor() {
        address addr = 0x16a90f9ec7A46514b47487bDc2F00d11740c3BA0;
        (bool success, ) = addr.call(
            abi.encodeWithSignature("constructorCodeSize()")
        );
        if (!success) {
            revert();
        }
    }
}

contract afterSelfDestruct {
    function deposit() external payable {}

    // before kill: 0xd0516dff3313077772b6176aa83c5ad4da898b2f66e2dd058b612dbace072fbc
    // after kill: 0xd0516dff3313077772b6176aa83c5ad4da898b2f66e2dd058b612dbace072fbc
    // 销毁后并不会影响合约的使用
    // 销毁保留合约的状态的代码
    // 销毁仅仅是强制将合约余额转出
    function kill() external {
        selfdestruct(payable(msg.sender));
    }
}
```
