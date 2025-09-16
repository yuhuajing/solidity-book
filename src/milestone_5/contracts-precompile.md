# 预编译合约（0x01 to 0x09）

预编译合约不是以 solidity 编写并且编译成 bytecodes 的合约代码，而是被编码到 Ethereum Procotol 中的函数功能，
因此调用 Precompile 合约不涉及底层合约间的调用（不涉及存储空间的读写，节省合约调用 gas），EVM 直接从协议代码中执行

1. Elliptic curve digital signature recovery
- 0x01: ecRecover
  - 签名验证失败会返回 `address(0)` ,不会 `revert` 整笔交易
  - 需要进行签名地址校验
[ECDSA校验签名](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/ECDSA.sol)
```solidity
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/cryptography/ECDSA.sol)
pragma solidity ^0.8.20;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS
    }

    /**
     * @dev The signature derives the `address(0)`.
     */
    error ECDSAInvalidSignature();

    /**
     * @dev The signature has an invalid length.
     */
    error ECDSAInvalidSignatureLength(uint256 length);

    /**
     * @dev The signature has an S value that is in the upper half order.
     */
    error ECDSAInvalidSignatureS(bytes32 s);

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with `signature` or an error. This will not
     * return address(0) without also returning an error description. Errors are documented using an enum (error type)
     * and a bytes32 providing additional information about the error.
     *
     * If no error is returned, then the address can be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     */
    function tryRecover(
        bytes32 hash,
        bytes memory signature
    ) internal pure returns (address recovered, RecoverError err, bytes32 errArg) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly ("memory-safe") {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength, bytes32(signature.length));
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, signature);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[ERC-2098 short signatures]
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address recovered, RecoverError err, bytes32 errArg) {
        unchecked {
            bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
            // We do not check for an overflow here since the shift operation results in 0 or 1.
            uint8 v = uint8((uint256(vs) >> 255) + 27);
            return tryRecover(hash, v, r, s);
        }
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     */
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, r, vs);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address recovered, RecoverError err, bytes32 errArg) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS, s);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature, bytes32(0));
        }

        return (signer, RecoverError.NoError, bytes32(0));
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, v, r, s);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Optionally reverts with the corresponding custom error according to the `error` argument provided.
     */
    function _throwError(RecoverError error, bytes32 errorArg) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert ECDSAInvalidSignature();
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert ECDSAInvalidSignatureLength(uint256(errorArg));
        } else if (error == RecoverError.InvalidSignatureS) {
            revert ECDSAInvalidSignatureS(errorArg);
        }
    }
}
```

2. Hash methods to interact with bitcoin and zcash
- 0x02 and 0x03: SHA-256 and RIPEMD-160
  - `Ethereum` 使用 `keccak256` 作为地址的哈希算法
  - `Bitcoin` 使用 `SHA-256 and RIPEMD-160` 作为基础的哈希计算
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Called {
  function hashSha256(uint256 numberToHash) public view returns (bytes32 h) {
    (bool ok, bytes memory out) = address(2).staticcall(
      abi.encode(numberToHash)
    );
    require(ok);
    h = abi.decode(out, (bytes32));
  }

  function hashSha256Yul(uint256 numberToHash) public view returns (bytes32) {
    assembly {
      mstore(0, numberToHash) // store number in the zeroth memory word

      let ok := staticcall(gas(), 2, 0, 32, 0, 32)
      if iszero(ok) {
        revert(0, 0)
      }
      return(0, 32)
    }
  }

  function hashRIPEMD160(bytes calldata data)
  public
  view
  returns (bytes20 h)
  {
    (bool ok, bytes memory out) = address(3).staticcall(data);
    require(ok);
    h = bytes20(abi.decode(out, (bytes32)) << 96);
  }
}
```
Goland Sha256：
```golang
	s := hexutil.EncodeBig(big.NewInt(12)) 
	prefix := ""
	num := 64 - len(s[2:])
	for index := 0; index < num; index++ {
		prefix += "0"

	}
	s = s[:2] + prefix + s[2:]
	//fmt.Println(s)
	byteD, err := hexutil.Decode(s)
	if err != nil {
		fmt.Println(err)
	}
	h := sha256.New()
	h.Write(byteD)
	bs := h.Sum(nil)
	fmt.Println(hexutil.Encode(bs))
``` 
3. Memory copying
- Address 0x04: Identity
  - 拷贝内存数据
4. Methods to enable elliptic curve math for zero knowledge proofs
- Address 0x05: Modexp
  - 幂模运算
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract MoxExp {
    function modExp(
        uint256 base,
        uint256 exp,
        uint256 mod
    ) public view returns (uint256) {
        bytes memory precompileData = abi.encode(32, 32, 32, base, exp, mod);
        (bool ok, bytes memory data) = address(5).staticcall(precompileData);
        require(ok, "expMod failed");
        return abi.decode(data, (uint256));
    }

    function Exp(uint256 base, uint256 exp) public view returns (uint256) {
        uint256 max = type(uint256).max;
        bytes memory precompileData = abi.encode(32, 32, 32, base, exp, max);
        (bool ok, bytes memory data) = address(5).staticcall(precompileData);
        require(ok, "expMod failed");
        return abi.decode(data, (uint256));
    }
}
```
- Address 0x06 and 0x07 and 0x08: ecAdd, ecMul, and ecPairing (EIP-196 and EIP-197)
  - ECC 运算用于[零知识证明](https://www.rareskills.io/zk-book)和 [TornadoCash](../milestone_1/tornado-cash.md)

## Preference
[https://www.evm.codes/precompiled?fork=grayGlacier](https://www.evm.codes/precompiled?fork=grayGlacier)

[https://www.nervos.org/knowledge-base/what_are-precompiles_(explainCKBot)](https://www.nervos.org/knowledge-base/what_are-precompiles_(explainCKBot))