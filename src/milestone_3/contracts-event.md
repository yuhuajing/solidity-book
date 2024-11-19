# event事件
`Event` 事件是<kbd>EVM</kbd>上日志的抽象，具有两大特点：
1. `emit` 触发事件，可以直接过滤、订阅事件
2. 经济友好，通过 `Event` 存储数据，每次存储大概花销 `2000gas`
```solidity
event Transfer(address indexed from, address indexed to, uint256 value);
```
事件<kbd>Transfer</kbd>内部参数表示需要记录在链上的变量类型和参数名称
  - 通过 `indexed` 关键字，单独将事件参数作为一个 `topic` 进行存储和索引
  - 一个 `Event` 最多拥有三个 `indexed` 数据
  - 没有 `indexed` 关键字修饰的参数作为 `data` 变量存储在 `data` 域中，作为参数解析
## Golang 解析 event事件
```golang
func ParseLogFromReceipet(contract, txhash string) {
    receipet, err := client.TransactionReceipt(context.Background(), common.HexToHash(txhash))
    if err != nil {
       log.Fatalf("Error in get TransactionReceipt: %s", err)
    }
    if receipet.Status == 0 {
       fmt.Printf("Tx has failed\n")
       return
    }
    logs := receipet.Logs
    ParseLogs(logs, contract)
}

func ParseLogs(logs []*types.Log, contract string) bool {
    for _, logData := range logs {
       if logData.Address != common.HexToAddress(contract) {
          continue
       }
       Sender := common.HexToAddress(logData.Topics[1].Hex())
       types, _ := strconv.ParseInt(hexutil.Encode(logData.Topics[2].Bytes())[2:], 16, 64)
       uuid, _ := strconv.ParseInt(hexutil.Encode(logData.Topics[3].Bytes())[2:], 16, 64)
       fmt.Printf("Contract: %s, Sender: %s, types: %d, uuid: %d\n", contract, Sender, types, uuid)
       return true
    }
    return false
}
```
## [event topic过滤](https://github.com/ethereum/go-ethereum/blob/master/interfaces.go#L181)
同时过滤topic1 + topic2 的 logs
```golang
for startBlockHeight < latestblockNum {
		toblock := startBlockHeight + 10000
		if toblock > latestblockNum {
			toblock = latestblockNum
		}
		query := ethereum.FilterQuery{
			FromBlock: big.NewInt(startBlockHeight),
			ToBlock:   big.NewInt(toblock),
			Addresses: []common.Address{common.HexToAddress(contract)},
			Topics:    [][]common.Hash{{common.HexToHash("topic1"), common.HexToHash("topic2")}},
		}
		logs, err := mainnetLPClient.FilterLogs(context.Background(), query)
		if err != nil {
			fmt.Printf("Error in filter logs: error:%v", err)
			return
		}
}
```
