package merkletree

import (
	"fmt"
	smt "github.com/FantasyJony/openzeppelin-merkle-tree-go/standard_merkle_tree"
	"github.com/ethereum/go-ethereum/common/hexutil"
	"golang.org/x/crypto/sha3"
)

func getKeccak(encodedata []byte) [32]byte {
	hash := sha3.NewLegacyKeccak256()
	hash.Write(encodedata)
	var result [32]byte
	copy(result[:], hash.Sum(nil))
	return result
}

func MerkleOnlyOneArgOZ() {
	leaf1 := []interface{}{
		smt.SolAddress("0x1111111111111111111111111111111111111111"),
		//smt.SolNumber("5000000000000000000"),
	}

	leaf2 := []interface{}{
		smt.SolAddress("0x1111111111111111111111111111111111111111"),
		//smt.SolNumber("2500000000000000000"),
	}

	leaf3 := []interface{}{
		smt.SolAddress("0x1111111111111111111111111111111111111111"),
		//smt.SolNumber("5000000000000000000"),
	}

	leaf4 := []interface{}{
		smt.SolAddress("0x1111111111111111111111111111111111111111"),
		//smt.SolNumber("2500000000000000000"),
	}
	leaf5 := []interface{}{
		smt.SolAddress("0x1111111111111111111111111111111111111111"),
		//smt.SolNumber("2500000000000000000"),
	}

	leaves := [][]interface{}{
		leaf1,
		leaf2,
		leaf3,
		leaf4,
		leaf5,
	}

	tree, err := smt.Of(
		leaves,
		[]string{
			smt.SOL_ADDRESS,
			//smt.SOL_UINT256,
		})

	if err != nil {
		fmt.Println("Of ERR", err)
	}

	root := hexutil.Encode(tree.GetRoot())
	fmt.Println("Merkle Root: ", root)

	proof, err := tree.GetProof(leaf1)
	strProof := make([]string, len(proof))
	if err != nil {
		fmt.Println("GetProof ERR", err)
	}
	for _, v := range proof {
		strProof = append(strProof, hexutil.Encode(v))
	}
	fmt.Println("02 proof: ", strProof)
}

func MerkleWithMultiArgOZ() {
	leaf1 := []interface{}{
		smt.SolAddress("0x1111111111111111111111111111111111111111"),
		smt.SolNumber("5000000000000000000"),
	}

	leaf2 := []interface{}{
		smt.SolAddress("0x1111111111111111111111111111111111111111"),
		smt.SolNumber("2500000000000000000"),
	}

	leaf3 := []interface{}{
		smt.SolAddress("0x1111111111111111111111111111111111111111"),
		smt.SolNumber("5000000000000000000"),
	}

	leaf4 := []interface{}{
		smt.SolAddress("0x1111111111111111111111111111111111111111"),
		smt.SolNumber("2500000000000000000"),
	}
	leaf5 := []interface{}{
		smt.SolAddress("0x1111111111111111111111111111111111111111"),
		smt.SolNumber("2500000000000000000"),
	}

	leaves := [][]interface{}{
		leaf1,
		leaf2,
		leaf3,
		leaf4,
		leaf5,
	}

	tree, err := smt.Of(
		leaves,
		[]string{
			smt.SOL_ADDRESS,
			smt.SOL_UINT256,
		})

	if err != nil {
		fmt.Println("Of ERR", err)
	}

	root := hexutil.Encode(tree.GetRoot())
	fmt.Println("Merkle Root: ", root)

	proof, err := tree.GetProof(leaf1)
	strProof := make([]string, len(proof))
	if err != nil {
		fmt.Println("GetProof ERR", err)
	}
	for _, v := range proof {
		strProof = append(strProof, hexutil.Encode(v))
	}
	fmt.Println("02 proof: ", strProof)
}
