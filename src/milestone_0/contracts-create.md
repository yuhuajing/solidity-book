
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
