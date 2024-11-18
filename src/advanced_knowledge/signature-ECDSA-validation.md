# 校验签名：
ECDSA(Elliptic Curve Digital Signature Algorithm) 用来对特定的数据进行密码学上的计算，运行数据的签名者(signer)签名封装数据，签名公钥（verifyer）可以校验解封数据
- 签名树被篡改的话，公钥无法解封出正确的数据
- 签名公钥和私钥不配对的话，数据无法解封

/* Signature Verification
How to Sign and Verify
## Signing
1. Create message to sign
2. Hash the message
3. Sign the hash (off chain, keep your private key secret)

## Verify
1. Recreate hash from the original message
2. Recover signer from signature and hash
3. Compare recovered signer to claimed signer
*/
4. 
## preference
[ECDSA-trtorial](https://www.rareskills.io/post/ecdsa-tutorial)

[openzeppelin-ecdsa](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/ECDSA.sol)

[contracts](../ContractsHub/ecdsa_signature)

[cryptobook](https://cryptobook.nakov.com/digital-signatures/ecdsa-sign-verify-examples)
