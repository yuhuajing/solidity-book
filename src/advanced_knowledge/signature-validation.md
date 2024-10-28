# 通过合约校验签名：
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/* Signature Verification

How to Sign and Verify
# Signing
1. Create message to sign
2. Hash the message
3. Sign the hash (off chain, keep your private key secret)

# Verify
1. Recreate hash from the original message
2. Recover signer from signature and hash
3. Compare recovered signer to claimed signer
*/

contract VerifySignature {
    /* 1. Unlock MetaMask account
    ethereum.enable()
    */

    /* 2. Get message hash to sign
    getMessageHash(
        0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C,
        123,
        "coffee and donuts",
        1
    )

    hash = "0xcf36ac4f97dc10d91fc2cbb20d718e94a8cbfe0f82eaedc6a4aa38946fb797cd"
    */
    function getMessageHash(
        address _to,
        uint256 _amount,
        string memory _message,
        uint256 _nonce
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_to, _amount, _message, _nonce));
    }

    /* 3. Sign message hash
    # using browser
    account = "copy paste account of signer here"
    ethereum.request({ method: "personal_sign", params: [account, hash]}).then(console.log)

    # using web3
    web3.personal.sign(hash, web3.eth.defaultAccount, console.log)

    Signature will be different for different accounts
    0x993dab3dd91f5c6dc28e17439be475478f5635c92a56e17e82349d3fb2f166196f466c0b4e0c146f285204f0dcb13e5ae67bc33f4b888ec32dfe0a063e8f3f781b
    */
    function getEthSignedMessageHash(bytes32 _messageHash)
        public
        pure
        returns (bytes32)
    {
        /*
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        return keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
        );
    }

    /* 4. Verify signature
    signer = 0xB273216C05A8c0D4F0a4Dd0d7Bae1D2EfFE636dd
    to = 0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C
    amount = 123
    message = "coffee and donuts"
    nonce = 1
    signature =
        0x993dab3dd91f5c6dc28e17439be475478f5635c92a56e17e82349d3fb2f166196f466c0b4e0c146f285204f0dcb13e5ae67bc33f4b888ec32dfe0a063e8f3f781b
    */
    function verify(
        address _signer,
        address _to,
        uint256 _amount,
        string memory _message,
        uint256 _nonce,
        bytes memory signature
    ) public pure returns (bool) {
        bytes32 messageHash = getMessageHash(_to, _amount, _message, _nonce);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == _signer;
    }

    function recoverSigner(
        bytes32 _ethSignedMessageHash,
        bytes memory _signature
    ) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        public
        pure
        returns (bytes32 r, bytes32 s, uint8 v)
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }
}
```
Golang签名数据：
```go
package sig

import (
	"crypto/ecdsa"
	"fmt"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/common/hexutil"
	"github.com/ethereum/go-ethereum/crypto"
	solsha3 "github.com/miguelmota/go-solidity-sha3"
	"main/config"
	"main/luuid"
	"math/big"
	"strings"
	"time"
)

func IMX1155SigRequest() {
	types :=
	chainId :=
	uuid := luuid.GeneUUID()
	signId := luuid.GeneUUID()
	prikey := config.Env("PRIVATE_KEY", "")
	sender := ""
	contract := ""
	ts := time.Now().Unix()
	var ids []uint64
	var values []uint64
	for i := 0; i < 45; i++ {
		ids = append(ids, uint64(i))
	}

	for i := 0; i < 45; i++ {
		values = append(values, 1000)
	}

	IMXRaffleSig(uint64(types), uint64(chainId), uint64(ts), uint64(uuid), uint64(signId), ids, values, sender, contract, prikey)
}

func IMXRaffleSig(types, chainId, timestamp, uuid, signId uint64, ids, values []uint64, sender, contract string, privateKey string) {
	PrivateKey, _ := crypto.HexToECDSA(privateKey)
	packedstr := recPrizeSig(types, chainId, timestamp, uuid, signId, ConvertToIntSlice(ids), ConvertToIntSlice(values), common.HexToAddress(sender), common.HexToAddress(contract), PrivateKey)
	str := strings.Trim(strings.Trim(fmt.Sprint(ids), "[]"), " ")
	// 使用逗号分隔字符串并打印结果
	nids := strings.Replace(str, " ", ",", -1)
	str = strings.Trim(strings.Trim(fmt.Sprint(values), "[]"), " ")
	// 使用逗号分隔字符串并打印结果
	nvalues := strings.Replace(str, " ", ",", -1)
	fmt.Println(fmt.Sprintf("types: %d  chainID :%d timestamp: %d uuid: %d signid: %d ids: %s values: %s sender: %s contract: %s", types, chainId, timestamp, uuid, signId, nids, nvalues, sender, contract))
	fmt.Printf("metadataSig: %s\n", packedstr)
}

func ConvertToIntSlice(nums []uint64) []*big.Int {
	result := make([]*big.Int, len(nums))
	for i, num := range nums {
		result[i] = big.NewInt(int64(num))
	}
	return result
}

func recPrizeSig(types, chainId, timestamp, uuid, signId uint64, ids, values []*big.Int, sender, contract common.Address, privateKey *ecdsa.PrivateKey) string {
	mes := solsha3.SoliditySHA3(
		[]string{"uint32", "uint32", "uint64", "uint64", "uint64", "address", "address", "uint256[]", "uint256[]"},
		[]interface{}{
			types,
			chainId,
			timestamp,
			uuid,
			signId,
			sender,
			contract,
			ids,
			values,
		},
	)
	hash := solsha3.SoliditySHA3WithPrefix(mes)
	fmt.Println(hexutil.Encode(hash))
	signatureBytes, err := crypto.Sign(hash, privateKey)
	if err != nil {
		return ""
	}
	signatureBytes[64] += 27
	return hexutil.Encode(signatureBytes)
}
```
Js生成签名
```javascript
// https://docs.ethers.org/v6/cookbook/signing/
import {ethers} from"ethers";

const main = async () => {
    const provider = new ethers.JsonRpcProvider(`https://cloudflare-eth.com`);
    const signer = new ethers.Wallet("xxx",provider)
    console.log(`私钥钱包地址:${signer.address}`)
    const message = "Hello, World!";
    // const rawSig = await signer.signMessage(message);
    
    // 等效于Solidity中的keccak256(abi.encodePacked(account, tokenId))
    const msgHash = ethers.solidityPackedKeccak256(
        ['string'],
        [message])
    const messageHashBytes = ethers.getBytes(msgHash)
    const rawSig = await signer.signMessage(messageHashBytes);
    // console.log(rawSig);
}
main()
```
