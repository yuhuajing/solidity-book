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
## [函数选择器](https://www.rareskills.io/post/function-selector)
- solidity在opcode层通过`bytes4(keccak256(abi.encodePacked(functionName)))`计算函数选择器
- 因此，solidity支持同名不同参数的函数
- 函数之间可以通过合约|抽象合约|接口合约直接调用
- 函数通过 selector 调用
  - abi.encodePacked
  - abi.encodeWithSelector
  - abi.encodeWithSignature
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract SelectorTest {
  uint256 public x;
  event Sig(bytes4 sig);

  function foo(uint256 num) public {
    emit Sig(msg.sig); //this.foo.selector
    x += num;
  }

  function func(uint256 num) external {
    x += num;
  }

  function func(uint256 num, bool flag) external {
    if (flag) {
      x += num;
    }
  }

  function getSelectorOfFoo() external pure returns (bytes4) {
    return this.foo.selector; // 0xc2985578
  }
}

contract CallFoo {
  event Sig(bytes4 sig);

  function callFooLowLevel(SelectorTest _contract, uint256 num) external {
    //  _contract.foo(num);
    // bytes4 fooSelector = 0xc2985578;
    emit Sig(msg.sig); // this.callFooLowLevel.selector
    bytes4 fooSelector = SelectorTest.foo.selector;
    (bool ok, ) = address(_contract).call(
      abi.encodePacked(fooSelector, num)
    );
    // | (bool ok, ) = address(_contract).call(abi.encodeWithSelector(fooSelector, num));| (bool ok, ) = address(_contract).call(abi.encodeWithSignature("foo(uint256)", num));
    require(ok, "call failed");
  }
}
```
### selector
- 选择器和函数名、函数参数类型相关，和函数&参数的修饰符无关
- 计算选择器时，函数参数之间无空格
- Internal|Private函数不允许外部调用
- 使用4个字节的函数选择器降低 msg.data 的size(函数名称可以无限长，选择器就时4bytes)
- 函数选择器不会和fallback()进行匹配，只有在全部的功能函数没匹配上的时候，才会调用fallback()函数
```solidity
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract FunctionSignatureTest {
    function foo() external {}

    function point(uint256 x, uint256 y) external {}

    function setName(string memory name) external {}

    function testSignatures() external pure returns (bool) {
        // NOTE: Casting to bytes4 takes the first 4 bytes
        // and removes the rest

        assert(
            bytes4(keccak256(abi.encodePacked("foo()"))) == this.foo.selector
        );
        assert(
            bytes4(keccak256("point(uint256,uint256)")) == this.point.selector
        );
        assert(bytes4(keccak256("setName(string)")) == this.setName.selector);

        return true;
    }
}
```
### Tools
[函数在线计算选择器](https://www.evm-function-selector.click/)
[函数选择器数据库](https://www.4byte.directory/)
