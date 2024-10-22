
### 接口
接口通过<kbd>interface</kbd>关键字修饰，内部所有函数必须都是未完成的函数，并且标注external供外部继承调用。

接口是合约功能的骨架，定义了合约内部需要实现的全部函数方法，知道了接口，就知道了合约内部的函数调用。

1. 接口合约内部不能定义状态变量
2. 继承接口必须实现内部的全部函数
3. 接口合约内部不能包含构造函数
4. 接口不能继承出接口外的其他合约
5. 接口内部的函数必须全部是external并且不能包含函数体{}
```solidity
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
interface IERC721  {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Getbal(address indexed owner);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external  returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);
}

contract test is IERC721{
    mapping(address=>uint256)balances;
     function deposit() public payable {
        balances[msg.sender] +=1000;
    }
    function balanceOf(address owner) external  returns (uint256){
    emit Getbal(owner);
    return  balances[owner];
    }

    function ownerOf(uint256 tokenId) external view returns (address owner){
    }
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}

contract interactBAYC {
    // 利用BAYC地址创建接口合约变量（ETH主网）
    IERC721 BAYC = IERC721(0xAc40c9C8dADE7B9CF37aEBb49Ab49485eBD3510d);
    // 通过接口调用BAYC的balanceOf()查询持仓量
    function balanceOfBAYC(address owner) external  returns (uint256 balance){
        return BAYC.balanceOf(owner);
    }
}
```


