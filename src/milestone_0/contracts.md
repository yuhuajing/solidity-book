# 合约类型
## 库函数
## 接口合约
## 抽象合约
## 合约继承
## 代理合约
## 可升级合约


## 抽象合约和接口
### 抽象合约
合约通过<kbd>abstract</kbd>关键字修饰，内部包含至少一个为实现具体功能的函数方法（没有{}）。为实现的函数方法需要加上 <kbd>virtual</kbd>关键字，支持后续继承合约的<kbd>override</kbd>重写功能。

抽象合约用于实现暂未考量确定的函数方法。
```solidity
abstract contract InsertionSort{
    function insertionSort(uint[] memory a) public pure virtual returns(uint[] memory);
}
```

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

### require 前置判断
通过 <kbd>require</kbd>关键字修饰，进行条件判断,gas花销和描述异常的字符串的长度正相关，条件不满足时就会抛出异常，输出异常字符串。
```solidity

function transferOwner1(uint256 tokenId, address newOwner) public {
    require(_owners[tokenId] == msg.sender,"error")
    _
}
```

### assert 后置判断
通过 <kbd>assert</kbd>关键字修饰，但是无法抛出具体的异常信息
```solidity
    function transferOwner3(uint256 tokenId, address newOwner) public {
        assert(_owners[tokenId] == msg.sender);
        _owners[tokenId] = newOwner;
    }
```

### error 抛出
通过 <kbd>error</kbd>关键字修饰，通过 revert触发 error事件
```solidity
error TransferNotOwner(); // 自定义error
function transferOwner1(uint256 tokenId, address newOwner) public {
    if(_owners[tokenId] != msg.sender){
        revert TransferNotOwner();
    }
     _owners[tokenId] = newOwner;
}
```



## 库合约
通过 <kbd>library</kbd>关键字修饰，将常用的合约函数抽象成库合约，减少solidity合约代码的冗余，减少冗余代码的gas花销。
1. 库合约不能接收token
2. 库合约不能被继承或继承别的合约
3. 不能存在状态变量
4. library的使用分为两种： 通过Using A for B,此时B拥有A的所有内部函数 或者 直接通过 library 的名称调用内部函数
   常见的库合约：https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/utils
```solidity
library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}

contract StateToStateContract {
    //using Address for address;
    function isSC(address _addr)public view returns (bool){
         return Address.isContract(_addr);
        //return _addr.isContract();
    }
}
```

## import 导入合约包
import 导包在声明版本号后，在合约代码前
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Address} from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/utils/Address.sol";

contract StateToStateContract {
    using Address for address;
    function isSC(address _addr)public view returns (bool){
       //  return Address.isContract(_addr);
        return _addr.isContract();
    }
}
```
import导包的三种方式：
1. 导入本地文件
>import {Yeye} from './Yeye.sol';
2. 从网页导入
> import {Address} from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/utils/Address.sol";
3. 通过npm 本地包导入
> import {addrCheck}from "@openzeppelin-contracts/4a9cc8b4918ef3736229a5cc5a310bdc17bf759f/contracts/utils/Address.sol";


## 创建合约
### 通过CREATE创建合约
合约地址通过hash(sender,nonce),因为nonce递增，因此同样账户无法部署同样的合约账户

外部代码通过<kbd>CREATE/CREATE2</kbd>关键字创建合约，合约内部通过 <kbd>new</kbd>关键字创建合约(默认为<kbd>CREATE</kbd>)。
```solidity
Contract x = new Contract{value: _value}(params)
```
<kbd>value</kbd>表示创建新合约时转入的token 数量，需要合约包含 payable的构造函数，用于接收Token

<kbd>params</kbd>表示创建合约时传入的构造函数参数，通过<kbd>CREATE2</kbd>创建的合约支持新建合约时传入构造函数参数,将传参构造进initCode传参

```solidity
contract Pair{
    address public tokenA;
    address public tokenB;
    constructor(address token0,address token1)payable{
        tokenA = token0;
        tokenB=token1;
    }
}

contract Createpair{
    mapping(address=>mapping(address=>address)) public getpair;
    constructor()payable{}

    function newpair(address token0,address token1)public returns (address pairAddr){
        Pair pair = new Pair{value:1000}(token0,token1);
        pairAddr = address(pair);
        getpair[token0][token1]=pairAddr;
        getpair[token1][token0]=pairAddr;
    }
}
```
### 通过CREATE2创建合约
合约地址通过hash(0xff,sender,salt,runtime-bytecode),通过<kbd>0xff</kbd>常数值避免和 create的冲突。用<kbd>salt</kbd>值取代nonce，允许同样的账户用相同的合约代码可以部署出相同的合约地址。
```solidity
Contract x = new Contract{salt: _salt, value: _value}(params)
```
<kbd>CREATE2</kbd>关键字支持构造函数传参，如果传参的话，就合并进字节码

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Factory {
    // Returns the address of the newly deployed contract
    function deploy(
        address _owner,
        uint _foo,
        bytes32 _salt
    ) public payable returns (address) {
        // This syntax is a newer way to invoke create2 without assembly, you just need to pass salt
        // https://docs.soliditylang.org/en/latest/control-structures.html#salted-contract-creations-create2
        return address(new TestContract{salt: _salt}(_owner, _foo));
    }
}

// This is the older way of doing it using assembly
contract FactoryAssembly {
    event Deployed(address addr, uint salt);

    // 1. Get bytecode of contract to be deployed
    // NOTE: _owner and _foo are arguments of the TestContract's constructor
    function getBytecode(address _owner, uint _foo) public pure returns (bytes memory) {
        bytes memory bytecode = type(TestContract).creationCode;

        return abi.encodePacked(bytecode, abi.encode(_owner, _foo));
    }

    // 2. Compute the address of the contract to be deployed
    // NOTE: _salt is a random number used to create an address
    function getAddress(
        bytes memory bytecode,
        uint _salt
    ) public view returns (address) {
        bytes32 hash = keccak256(
            abi.encodePacked(bytes1(0xff), address(this), _salt, keccak256(bytecode))
        );

        // NOTE: cast last 20 bytes of hash to address
        return address(uint160(uint(hash)));
    }

    // 3. Deploy the contract
    // NOTE:
    // Check the event log Deployed which contains the address of the deployed TestContract.
    // The address in the log should equal the address computed from above.
    function deploy(bytes memory bytecode, uint _salt) public payable {
        address addr;

        /*
        NOTE: How to call create2

        create2(v, p, n, s)
        create new contract with code at memory p to p + n
        and send v wei
        and return the new address
        where new address = first 20 bytes of keccak256(0xff + address(this) + s + keccak256(mem[p…(p+n)))
              s = big-endian 256-bit value
        */
        assembly {
            addr := create2(
                callvalue(), // wei sent with current call
                // Actual code starts after skipping the first 32 bytes
                add(bytecode, 0x20),
                mload(bytecode), // Load the size of code contained in the first 32 bytes
                _salt // Salt from function arguments
            )

            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }

        emit Deployed(addr, _salt);
    }
}

contract TestContract {
    address public owner;
    uint public foo;

    constructor(address _owner, uint _foo) payable {
        owner = _owner;
        foo = _foo;
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
```
### selfdestruct 自毁关键字
自毁关键字会销毁当前合约代码，从状态树中删除合约代码，同时将合约余额转给关键字内部的地址。转账行为是不可控，任何合约内部执行<kbd>selfdestruct</kbd>后都会把余额转给内部提供的账户地址。
> selfdestruct(payable(address))
1. 注意自毁函数的调用权限设计
2. 自毁关键字会把余额无条件转给内部地址，因此需要注意潜在的余额攻击
3. 合约被销毁后，destruct就是把合约代码和状态全部从状态树中清掉了，后续在部署同样address的合约也只是一个全新的合约了，内部的状态变量从新开始，原本的无法查询了。但是与该账户的交互仍然可以进行[没有更新到状态树上的全新地址]，转账或调用内部函数(非查询类函数)，只是余额会被锁仓到该合约中，函数调用也只会返回0，不会进行实质操作。
```solidity

    function killself(address payable _addr)public {
        selfdestruct(_addr);
    }
```
