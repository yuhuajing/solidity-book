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
	"time"
)

func ClaimRewardSigRequest() {
	var indexs []uint64
	indexs = append(indexs, 0, 1)
	var amounts []*big.Int
	amounts = append(amounts, big.NewInt(10000000000000000))
	ts := time.Now().Unix()
	uuid := luuid.GeneUUID()
	signId := luuid.GeneUUID()
	chainId := 13473
	prikey := config.Env("PRIVATE_KEY", "")
	sender := ""
	contract := ""
	ClaimRewardsSig(amounts, indexs, uint64(ts), uint64(uuid), uint64(signId), uint64(chainId), sender, contract, prikey)
}

func ClaimRewardsSig(amounts []*big.Int, indexs []uint64, timestamp, uuid, signId, chainId uint64, sender, contract string, privateKey string) {
	PrivateKey, _ := crypto.HexToECDSA(privateKey)
	packedstr := claimSig(amounts, indexs, timestamp, uuid, signId, chainId, common.HexToAddress(sender), common.HexToAddress(contract), PrivateKey)
	fmt.Println(fmt.Sprintf("amounts: %v indexs: %v timestamp: %d uuid: %d signid: %d chainID :%d sender: %s contract: %s", amounts, indexs, timestamp, uuid, signId, chainId, sender, contract))
	fmt.Printf("metadataSig: %s\n", packedstr)
}
func ConvertStringToIntSlice(str string) *big.Int {
	var _e big.Int
	df, _ := _e.SetString(str, 10)
	return df
}

func claimSig(amounts []*big.Int, indexs []uint64, timestamp, uuid, signId, chainId uint64, sender, contract common.Address, privateKey *ecdsa.PrivateKey) string {
	mes := solsha3.SoliditySHA3(
		[]string{"uint256[]", "uint64[]", "uint64", "uint64", "uint64", "uint64", "address", "address"},
		[]interface{}{
			amounts,
			indexs,
			timestamp,
			uuid,
			signId,
			chainId,
			sender,
			contract,
		},
	)
	hash := solsha3.SoliditySHA3WithPrefix(mes)
	signatureBytes, err := crypto.Sign(hash, privateKey)
	if err != nil {
		return ""
	}
	signatureBytes[64] += 27
	return hexutil.Encode(signatureBytes)
}
