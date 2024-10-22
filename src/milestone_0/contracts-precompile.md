# [预编译合约](https://www.rareskills.io/post/solidity-precompiles)（0x01 to 0x09）
1. Elliptic curve digital signature recovery
- [0x01: ecRecover](https://github.com/yuhuajing/solidityLearn/blob/main/smartContract/ECDSA/ECDSA.sol)
  - 签名验证失败会返回address(0),不会revert整笔交易
  - 需要进行签名地址校验
2. Hash methods to interact with bitcoin and zcash
- 0x02 and 0x03: SHA-256 and RIPEMD-160
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
  - ECC 运算用于零知识证明和TornadoCash
