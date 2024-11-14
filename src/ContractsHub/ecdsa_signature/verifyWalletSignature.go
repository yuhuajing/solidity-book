package sig

import (
	"crypto/ecdsa"
	"fmt"
	"github.com/ethereum/go-ethereum/accounts"
	"github.com/ethereum/go-ethereum/common/hexutil"
	"github.com/ethereum/go-ethereum/crypto"
	"main/config"
	"unsafe"
)

func ExampleRequest() {
	str := ""
	prikey := config.Env("PRIVATE_KEY", "")
	PrivateKey, _ := crypto.HexToECDSA(prikey)

	publicKey := PrivateKey.Public()
	publicKeyECDSA, _ := publicKey.(*ecdsa.PublicKey)
	pubByte := crypto.FromECDSAPub(publicKeyECDSA)
	hashbyte, sigbyte, packedstr := exampleSig(str, PrivateKey)
	fmt.Println(VerifySignature(pubByte, hashbyte, sigbyte[:len(sigbyte)-1]))
	fmt.Println(hexutil.Encode(hashbyte))
	fmt.Printf("metadataSig: %s\n", packedstr)
}
func UnsafeBytes(s string) []byte {
	return unsafe.Slice(unsafe.StringData(s), len(s))
}
func exampleSig(message string, privateKey *ecdsa.PrivateKey) ([]byte, []byte, string) {
	hash := accounts.TextHash(UnsafeBytes(message))
	signatureBytes, err := crypto.Sign(hash, privateKey)
	if err != nil {
		return nil, nil, ""
	}
	signatureBytes[64] += 27
	return hash, signatureBytes, hexutil.Encode(signatureBytes)
}
