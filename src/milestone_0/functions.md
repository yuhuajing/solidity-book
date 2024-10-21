# 合约函数
## 构造函数
- 合约字节码由三部分组成：
  - `<init code> <runtime code> <constructor parameters>`
  - 构造函数代码编码在 init code进行判断
    - 合约部署时是否支持接收NaticeToken
    - 构造函数中输入的参数是否合法
  - 构造函数的参数编码到字节码最后
    - 初始化合约参数，后续不能修改
  - 修饰符： payable
    - 使用payable修饰，表示合约在部署时允许接收NativeToken
    - 没有payable修饰符，表明不支持接收NativeToken
    - 因此，不适用payable修饰的InitCode要长一些，进行NativeToken的判断
  - Immutable修饰的参数必须在构造函数中初始化
  - 继承函数时，也需要继承函数的构造函数
    - 按照继承顺序，继承父合约的全部状态变量
    - 按照继承顺序，继承父合约的修饰器
    - 后继承的函数会重写之前继承的函数，因此不能菱形继承（函数互相重写依赖）
    - 父合约中private修饰的状态变量无法更新
    - 父合约中private修饰的函数量无法调用
    - 继承时需要初始化父函数的构造函数
    - 继承时，只能在自己的构造函数中初始化父合约的Immutable参数
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract contractOne {
  address public owner; //slot 0
  uint256 qty; //slot 1
  uint256 private qwe; //slot 2

  constructor(address _owner) {
    owner = _owner;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "Not_Owner"); // 判断 slot0存储的值和当前发送者的地址是否一致
    _;
  }
}

contract modofierContract is
contractOne // 继承父合约的状态变量,private变量继承后无法更新状态值
{
  uint256 value; //slot 3
  address localowner; //slot 4

  constructor(address _owner) contractOne(_owner) {
    owner = _owner;
    qty = 2;
    value = 5;
    assembly {
      sstore(localowner.slot, 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2)
    }
  }

  function getValue(uint256 slot) external view returns (address addr) {
    assembly {
      addr := sload(slot)
    }
  }

  function changeOwner(address _newowner) public onlyOwner {
    owner = _newowner;
  }
}
```
## 函数修饰符
>function <function name> (<parameter types>) {internal|external|public|private} [pure|view|payable|virtual|override|Modifier] [returns (<return types>)]
### 函数修饰符
- internal：合约内部使用，不能通过abi直接调用，允许继承
- external：外部访问，可以通过abi直接调用，也可以在本合约内通过<kbd>this.func</kbd>调用，允许继承
- public：合约内部和外部使用的函数，可以通过abi直接调用，允许继承
- private:只供合约内部使用，不允许通过abi直接调用，无法继承使用。
- pure: 只读，函数只能读取局部变量
- view:只读，函数可以读取状态变量、局部变量、全局参数
- payable: payable修饰符表明函数支持接收NativeToken(msg.value!=0)
- virtual: 虚函数，表明函数允许重载修改内部逻辑。多用于接口合约。
- override: 重载函数，重新定义函数内部逻辑，但是函数selector必须保持一致(函数名称、函数参数类型和数量)
- Modifier: 修饰器，内部定义条件判断,允许继承
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract parentOne {
    uint256 public oneValue;

    function OneInternal() internal virtual {
        oneValue += 1;
    }

    function OneExternal() external virtual {
        oneValue += 2;
    }

    function OnePublic() public virtual {
        oneValue += 3;
    }

    function OnePrivate() private {
        oneValue += 4;
    }
}

contract functionsChecker is parentOne {
    function addOne() external {
        OneInternal();
    }

    // function addTwo() external {
    //     this.OneExternal();
    // }

    function addThree() external {
        super.OnePublic(); // super调用最近继承者合约的内部函数, +3
    }

    // function addFive() external {
    //     OnePublic(); //调用本合约的函数，+ 5
    // }

    function OnePublic() public virtual override {
        //重写函数，修改函数逻辑
        oneValue += 5;
    }

    //receive() external payable {}
}
```
## 函数修饰器
- modifier修饰符用于判断合约方法的执行前置条件，将函数内部的语句放置在modifier函数的‘-’中执行判断
- 允许继承
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract modofier {
  address owner; //slot 0
  modifier onlyOwner() {
    require(msg.sender == owner, "Not_Owner"); // 判断 slot0存储的值和当前发送者的地址是否一致
    _;
  }
}

contract modofierContract is
modofier // 继承父合约的状态变量,private变量继承后无法更新状态值
{
  constructor() {
    address _addr = msg.sender;
    assembly {
      sstore(owner.slot, _addr)
    }
  }

  function getValue(uint256 slot) external view returns (address addr) {
    assembly {
      addr := sload(slot)
    }
  }

  function changeOwner(address _newowner) public onlyOwner {
    owner = _newowner;
  }
}
```
## 函数事件
Event事件是<kbd>EVM</kbd>上日志的抽象，具有两大特点：
1. 通过emit 触发事件，可以通过web3.js 和 ABI 订阅和监听事件
2. 经济友好，通过Event存储数据，每次存储大概花销2000gas，每个新的状态变量的存储需要20000+gas.
```solidity
event Transfer(address indexed from, address indexed to, uint256 value);
```
- 事件<kbd>Transfer</kbd>内部参数表示需要记录在链上的变量类型和参数名称。通过indexed关键字，将参数标记为检索时间的索引值，单独作为一个topic进行存储和索引。但是，一个Event 最多拥有三个indexed 数据。
- 没有indexed关键字修饰的参数作为data变量存储在data域中，作为参数解析。
- [topic过滤](https://github.com/ethereum/go-ethereum/blob/master/interfaces.go#L181)
## [函数转账](https://yuhuajing.github.io/ethernaut-book/01-Fallback/Fallback.html)
- `receive() external payable {}`
- `fallback()external payable{}`
- 或函数缺省情况(包括转账后没有receive()方法)
- receiver函数用于接收NativeToken(EOA直接转账)。
- fallback在sender调用不存在的合约函数时被触发,包含 receiver函数的缺省
  - <kbd>send</kbd>执行转账
    - 传递2300的gas
    - 转账返回 boolean
    - 转账 失败不会 revert 交易
    - 因此，需要判断转账结果
  - <kbd>transfer</kbd>
    - 传递2300的gas
    - 转账失败的话，整笔交易回滚
  - <kbd>call</kbd>的转账
    - 默认会发送 [63/64](https://www.rareskills.io/post/eip-150-and-the-63-64-rule-for-gas) gas
    - 返回bool 和data
    - bool表示转账是否成功
    - data返回执行调用的结果
    - 交易失败的话不会回滚。
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract receiver {
  constructor() {}

  event ReceiveReceived(address Sender, uint256 Value);
  event FallbackReceived(address Sender, uint256 Value);

  receive() external payable {
    emit ReceiveReceived(msg.sender, msg.value);
  }

  fallback() external payable {
    emit FallbackReceived(msg.sender, msg.value);
  }
}

contract payer {
  constructor() payable {}

  function sendValue(address payable recipient, uint256 amount) external {
    bool success = recipient.send(amount); //ReceiveReceived
    if (!success) {
      revert("Send Trans Failure");
    }
  }

  function transferValue(address payable recipient, uint256 amount) external {
    recipient.transfer(amount); //ReceiveReceived
  }

  function callSendValue(
    address payable recipient,
    uint256 amount,
    bytes memory _data
  ) external {
    (bool success, ) = recipient.call{value: amount}(_data); //ReceiveReceived
    if (!success) {
      revert("call_send_value_failure");
    }
  }
}
```
## 同名重载 overload
solidity支持同名函数，不同输入参数的重载函数，因为在opcode层通过keccak256编译后的selector不同，因此可以支持函数的重载。
```solidity
    function temperature(uint a,uint b)public pure returns (uint){
       return a>b?a:b; //输入参数不同，进行hash后的selector也不同，因此实现函数的重载
    }
    function temperature(uint8 a)public pure returns (uint8){
       return a;
    }
    function temperature(uint256 a)public pure returns (uint256){
       return a;
    }
```
## [函数调用](https://www.rareskills.io/post/delegatecall)



## 调用其他合约
### Call
1. 如果知道对方合约的源代码或者ABI的值的话，可以在本合约中写入想调用的合约代码，然后通过指定本合约内的想调用的合约名称和链上合约地址调用合约函数<kbd>_Name(_Address).func()</kbd>
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OtherContract {
    constructor()payable{}
    uint256 private _x = 0; 
    event receiveLog(uint amount, uint gas);
    event fallbackLog(uint amount, uint gas);
    receive()external payable{
        emit receiveLog(msg.value, gasleft());
    }
    fallback() external payable{
         emit fallbackLog(msg.value, gasleft());
    }

    function setX(uint256 x) external payable{
        _x = x;
    }

    function getX() external view returns(uint x){
        x = _x;
    }
}

contract CallOtherContract {
    constructor()payable{}
    function callsetX(address payable _addr,uint256 x) external payable{
        OtherContract(_addr).setX(x);
    }

    function callgetX(address payable _addr) external view returns(uint){
       return OtherContract(_addr).getX();
    }
}
```
2. 如果不清楚合约源码或ABI的情况下，可以通过call函数调用合约。
>_addr.call{value:,gas:}(abi.encodeWithSignature("函数签名", 逗号分隔的具体参数))
>例如：abi.encodeWithSignature("f(uint256,address)", _x, _addr)
> 如果调用不存在的函数，则会触发调用合约中的fallback函数
```solidity
contract CallOtherContract {
    constructor()payable{}
    // 定义Response事件，输出call返回的结果success和data
    event Response(bool success, bytes data);
    function callsetX(address payable _addr,uint256 x) external payable{
   (bool success, bytes memory data) = _addr.call{value: msg.value}(
        abi.encodeWithSignature("setX(uint256)", x)
    );

    emit Response(success, data);
    }

    function callgetX(address payable _addr) external payable returns(uint256) {
       (,bytes memory data) = _addr.call{value: msg.value}(abi.encodeWithSignature("getX()"));
       return abi.decode(data, (uint256));
    }
}
```

### delegateCall
1. 在执行Call的时候，合约B会把自己的状态复制到C执行，因此修改的是C的状态。C的context是B.

A -Call- > B -Call-> C

对于B，context是A，因此 msg.sender=A

对于C，contest是B，因此 msg.sender=B

2. 但是A用delegateCall通过B去调用C的合约代码时，B会将C的context复制执行一份到B，因此修改的是B的状态，B的context 是 A

A -Call- > B -DelegateCall-> C

3. delegatecall不支持传输token，不能指定value值。

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OtherContract {
    uint public num;
    address public owner;
    function setNum(uint _num) external {
        num = _num; 
        owner = msg.sender;
    }
}

contract CallOtherContract {
   uint public num;
    address public owner;

    function callsetX(address _addr,uint _num) external payable{
        (bool success, ) = _addr.call{value:msg.value,gas:23000}(
            abi.encodeWithSignature("setNum(uint256)", _num)
        );
    }

    function delegatecallsetX(address _addr,uint _num) external payable{
        (bool success, ) = _addr.delegatecall{gas:23000}(
            abi.encodeWithSignature("setNum(uint256)", _num)
        );
    }
}
```
