# 创建合约
合约通过关键字 [CREATE](https://www.evm.codes/?fork=cancun#f0)，[CREATE2](https://www.evm.codes/?fork=cancun#f5),`new` 创建
## CREATE
- 新合约地址 `address = keccak256(rlp([sender_address,sender_nonce]))[12:]`
  - 同一条链上的账户地址 `nonce` 递增，因此账户在相同链上无法部署同样的合约账户 
  - 同样地址在不同链上，能过够通过相同 `nonce` 值部署相同地址的合约
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract FindSC {
  function contractAddressFrom(address _origin, uint256 _nonce)
  public
  pure
  returns (address)
  {
    bytes memory data;
    if (_nonce == 0x00)
      data = abi.encodePacked(
        bytes1(0xd6),
        bytes1(0x94),
        _origin,
        bytes1(0x80)
      );
    else if (_nonce <= 0x7f)
      data = abi.encodePacked(
        bytes1(0xd6),
        bytes1(0x94),
        _origin,
        uint8(_nonce)
      );
    else if (_nonce <= 0xff)
      data = abi.encodePacked(
        bytes1(0xd7),
        bytes1(0x94),
        _origin,
        bytes1(0x81),
        uint8(_nonce)
      );
    else if (_nonce <= 0xffff)
      data = abi.encodePacked(
        bytes1(0xd8),
        bytes1(0x94),
        _origin,
        bytes1(0x82),
        uint16(_nonce)
      );
    else if (_nonce <= 0xffffff)
      data = abi.encodePacked(
        bytes1(0xd9),
        bytes1(0x94),
        _origin,
        bytes1(0x83),
        uint24(_nonce)
      );
    else
      data = abi.encodePacked(
        bytes1(0xda),
        bytes1(0x94),
        _origin,
        bytes1(0x84),
        uint32(_nonce)
      );
    return address(uint160(uint256(keccak256(data))));
  }
}
```
## CREATE2
> `creation_code = memory[offset:offset+size]`
> 
> `address = keccak256(0xff + sender_address + salt + keccak256(creation_code))[12:]`
- 通过自定义的 `salt` 和 `合约代码` 替换递增的 `nonce` 值
  - `合约代码` 一般选择合约的 [creationCode](./contracts-creationcodes.md)
  - `creationCode` 包含完整的合约代码 `initCode + runtimeCode`，在构造函数发生任何变化后,也会造成合约地址的变化
- 在相同链上通过相同的 `salt` 和 `合约代码`，就可以实现同地址合约的提前使用
## New
- 新合约地址：`Contract x = new Contract{value: _value，salt: salt}(params)`
- `new` 关键字创建新的合约地址
  - `value` 表明创建合约是是否转账,构造函数需要使用 `payable` 修饰
  - `salt` 表明当前新建地址是否采用 `CREATE2` 关键字
  - `constructor parameters` 表明新建合约时传递的初始化参数
## Solidity Contracts
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// This is the older way of doing it using assembly
contract CreateNewContract {
    event Create2Created(address addr, bytes32 salt);
    event CreateCreated(address addr);

    // 1. Deploy the contract by CREATE
    function Create(address _owner, uint256 _num) external payable {
        bytes memory bytecode = getBytecode(_owner, _num);
        _create(bytecode, "");
    }

    // 2. Deploy the contract by CREATE2
    function Create2(
        address _owner,
        uint256 _num,
        bytes32 salt
    ) external payable {
        bytes memory bytecode = getBytecode(_owner, _num);
        _create(bytecode, salt);
    }

    function _create(bytes memory bytecode, bytes32 salt) internal {
        address addr;
        if (keccak256(abi.encode(salt)) == keccak256("")) {
            /*
        NOTE: How to call create
        create(v, p, n)
        create new contract with code at memory p to p + n
        and send v wei
        and return the new address
        */
            assembly {
                addr := create(
                    callvalue(), // wei sent with current call
                    // Actual code starts after skipping the first 32 bytes
                    add(bytecode, 0x20),
                    mload(bytecode) // Load the size of code contained in the first 32 bytes
                )

                if iszero(extcodesize(addr)) {
                    revert(0, 0)
                }
            }
            emit CreateCreated(addr);
        } else {
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
                    salt // Salt from function arguments
                )

                if iszero(extcodesize(addr)) {
                    revert(0, 0)
                }
            }
            emit Create2Created(addr, salt);
        }
    }

    // 3. Deploy the create contract by new
    function NewCreate(address _owner, uint256 _num)
        public
        payable
        returns (address)
    {
        return address(new targetContract{value: msg.value}(_owner, _num));
    }

    // 4. Deploy the create2 contract by new
    function NewCreate2(
        address _owner,
        uint256 _num,
        bytes32 salt
    ) public payable returns (address) {
        // This syntax is a newer way to invoke create2 without assembly, you just need to pass salt
        // https://docs.soliditylang.org/en/latest/control-structures.html#salted-contract-creations-create2
        return
            address(
                new targetContract{salt: salt, value: msg.value}(_owner, _num)
            );
    }

    // Get bytecode of contract to be deployed
    // NOTE: _owner and _num are arguments of the targetContract's constructor
    function getBytecode(address _owner, uint256 _num)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory bytecode = type(targetContract).creationCode;
        return abi.encodePacked(bytecode, abi.encode(_owner, _num));
    }

    // Compute the address of the contract to be deployed
    // NOTE: _salt is a random number used to create an address
    function getAddress(
        address _owner,
        uint256 _num,
        bytes32 salt
    ) external view returns (address) {
        bytes memory _bytecode = type(targetContract).creationCode;
        bytes memory bytecode = abi.encodePacked(
            _bytecode,
            abi.encode(_owner, _num)
        );
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                salt,
                keccak256(bytecode)
            )
        );

        // NOTE: cast last 20 bytes of hash to address
        return address(uint160(uint256(hash)));
    }
}

contract targetContract {
    address public owner;
    uint256 public num;

    constructor(address _owner, uint256 _num) payable {
        owner = _owner;
        num = _num;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
```
