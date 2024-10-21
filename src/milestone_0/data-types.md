# Data Types

## 数据类型
Solidity EVM 在宽256bit深2^256的栈空间存储合约数据，数据类型分为定长数值类型和非定长的引用类型：
1. **数值类型**： boolean，整数型（uint8~uint256,int8~int256），address，bytes（bytes1~bytes32）--> 赋值时直接传递值
- bool 类型是二值变量， 取值 true|false，default：false 
  - 运算符包括： 
  - ！（非） 
  - && （与，短路规则，如果前者false，就不会执行后者） 
  - || （或，短路规则，如果前者true，就不会执行后者） 
  - == （判等） 
  - ！= （不等）
- uint/int整型,default: 0
  - 运算符包括： 
  - 比较运算符，返回bool (> < >= <= == !=)
  - 算数运算符（+ - * / % ** <<  >> ）
- 地址类型
  - address 类型，可以使用payable()修饰，用于接收NativeToken（触发receiver()函数或缺省函数fallback()）
数值类型合约示例：
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Static_variables {
    bool public boo = true;

    /*
    uint stands for unsigned integer, meaning non negative integers
    different sizes are available
        uint8   ranges from 0 to 2 ** 8 - 1
        uint16  ranges from 0 to 2 ** 16 - 1
        ...
        uint256 ranges from 0 to 2 ** 256 - 1
    */
    uint8 public u8 = 1;
    uint256 public u256 = 456;
    uint256 public u = 123; // uint is an alias for uint256

    /*
    Negative numbers are allowed for int types.
    Like uint, different ranges are available from int8 to int256
    
    int256 ranges from -2 ** 255 to 2 ** 255 - 1
    int128 ranges from -2 ** 127 to 2 ** 127 - 1
    */
    int8 public i8 = -1;
    int256 public i256 = 456;
    int256 public i = -123; // int is same as int256

    // minimum and maximum of uint
    uint256 public minUInt = type(uint256).min;
    uint256 public maxUInt = type(uint256).max;

    // minimum and maximum of int
    int256 public minInt = type(int256).min;
    int256 public maxInt = type(int256).max;

    address public addr = 0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c;

    /*
    In Solidity, the data type byte represent a sequence of bytes. 
    Solidity presents two type of bytes types :

     - fixed-sized byte arrays
     - dynamically-sized byte arrays.
     
     The term bytes in Solidity represents a dynamic array of bytes. 
     It’s a shorthand for byte[] .
    */
    bytes1 a = 0xb5; //  [10110101]
    bytes1 b = 0x56; //  [01010110]

    // Default values
    // Unassigned variables have a default value
    bool public defaultBoo; // false
    uint256 public defaultUint; // 0
    int256 public defaultInt; // 0
    address public defaultAddr; // 0x0000000000000000000000000000000000000000
    bytes1 public c; //0x00
}
```
2. **引用类型**：array[]数组，定长数组，struct结构体，mapping映射，bytes，赋值时传递地址。
- 动态数组拥有 push/pop 内置函数，分别在数组最后增加或删除一个元素
- array数组
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Dynamic_variables_array {
    // Several ways to initialize an array
    uint256[] public indeterminate_arr;
    uint256[] public indeterminate_init_arr = [1, 2, 3];
    // Fixed sized array, all elements initialize to 0
    uint256[10] public determinate_arr;

    function get(uint256 i) public view returns (uint256) {
        return indeterminate_arr[i];
    }

    // Solidity can return the entire array.
    // But this function should be avoided for
    // arrays that can grow indefinitely in length.
    function getArr() public view returns (uint256[] memory) {
        return indeterminate_arr;
    }

    function indeterminate_push(uint256 i) public {
        // Append to array
        // This will increase the array length by 1.
        indeterminate_arr.push(i);
        indeterminate_init_arr.push(i);
    }

    function determinate_push(uint256 index, uint256 i) public {
        // Append to array
        // This will increase the array length by 1.
        determinate_arr[index] = i;
    }

    function indeterminate_pop() public {
        // Remove last element from array
        // This will decrease the array length by 1
        indeterminate_arr.pop();
        indeterminate_init_arr.pop();
    }

    function getLength() public view returns (uint256) {
        return indeterminate_arr.length;
    }

    function remove_not_change_length(uint256 index) public {
        // Delete does not change the array length.
        // It resets the value at index to it's default value,
        // in this case 0
        delete indeterminate_arr[index];
        delete determinate_arr[index];
    }

    // Deleting an element creates a gap in the array.
    // One trick to keep the array compact is to
    // move the last element into the place to delete.
    function remove_change_length(uint256 index) public {
        // Move the last element into the place to delete
        indeterminate_arr[index] = indeterminate_arr[
            indeterminate_arr.length - 1
        ];
        // Remove the last element
        indeterminate_arr.pop();
    }

    function examples_new_determinate_arr() external pure {
        // create array in memory, only fixed size can be created
        uint256[] memory a = new uint256[](5);
        a[0] = 5;
    }
}
```
- mapping
  - mapping(key ==> value) public map0;
  - key 必须是默认的类型，不能使用自定义的类型
  - value 可以是任意类型，包含自定义的结构体数据结构
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Mapping {
    // Mapping from address to uint
    mapping(address => uint256) public myMap;
    // Mapping from nft address and user address to his nft id
    mapping(address => mapping(address => uint256)) public addressNFTIds;

    struct myStruct {
        address NFT;
        address Operator;
    }
    // Mapping from nft address and user address to his approvor

    mapping(address => myStruct) public addressApprovedInfo;

    function updateMapping(
        address nft,
        address operator,
        uint256 id
    ) public {
        myMap[msg.sender] = id;
        addressNFTIds[nft][msg.sender] = id;
        addressApprovedInfo[msg.sender] = myStruct(nft, operator);
    }
}
```
- 枚举 <kbd>enum</kbd> 作为变量集合，用于定义状态
  - <kbd>enum</kbd>内部的变量从0 index开始。 default: 0
  - Enum 校验比Index校验更节省gas
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract EnumExample {
  enum Status {
    Active,
    Inactive,
    Pending
  }
  Status public status; // default: Active

  constructor() {}

  function setStatus(Status _status) public {
    //require(uint256(_status) == 2);// 43673 gas cost
    require(status == Status.Pending); // 23817 gas cost,更节省 gas
    status = _status;
  }

  function getStatus() public view returns (Status) {
    return status;
  }
}
```
- bytes
  - 在声明时指定数组的长度，bytes比较特殊，是数组，但是不用加[]声明
  - bytes xxx; //动态数组
  - 字节数组`bytes`分为定长数值类型和不定长引用类型。定长数值数组（bytes1~bytes32）能通过index获取数据
  - <kbd>MiniSolidity</kbd>以字节的方式存储，32个字节64位，转为16进制为<kbd>0x4d696e69536f6c69646974790000000000000000000000000000000000000000</kbd>
  - <kbd>_byte</kbd>存储第一个字节<kbd>0x4d</kbd>
```solidity
    // 固定长度的字节数组
    bytes32 public _byte32 = "MiniSolidity"; 
    bytes1 public _byte = _byte32[0]; 
```
- unicode, solidity(^0.7)的版本支持有效地 UTF-8 字符
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Unicode {
    string public constant natie = unicode"酱香拿铁";
    string public constant hell = unicode"Hello 😃";
}
```
3. 自定义类型
- Type xx is xxx
- 用户定义类型别名，通过 wrap/unwrap 包装和解包装
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// Code copied from optimism
// https://github.com/ethereum-optimism/optimism/blob/develop/packages/contracts-bedrock/src/dispute/lib/LibUDT.sol

type Duration is uint64;

type Timestamp is uint64;

type Clock is uint128;

library LibClock {
    function wrap(Duration _duration, Timestamp _timestamp)
        internal
        pure
        returns (Clock clock_)
    {
        assembly {
            // data | Duration | Timestamp
            // bit  | 0 ... 63 | 64 ... 127
            clock_ := or(shl(0x40, _duration), _timestamp)
        }
    }

    function duration(Clock _clock) internal pure returns (Duration duration_) {
        assembly {
            duration_ := shr(0x40, _clock)
        }
    }

    function timestamp(Clock _clock)
        internal
        pure
        returns (Timestamp timestamp_)
    {
        assembly {
            timestamp_ := shr(0xC0, shl(0xC0, _clock))
        }
    }

    function unwrap(Clock clock_)
        internal
        pure
        returns (Duration _duration, Timestamp _timestamp)
    {
        _duration = duration(clock_);
        _timestamp = timestamp(clock_);
    }
}

contract userDefinedValue {
    function wrap_uvdt() external view returns (Clock clock) {
        // Turn value type into user defined value type
        Duration d = Duration.wrap(1);
        Timestamp t = Timestamp.wrap(uint64(block.timestamp));
        // Turn user defined value type back into primitive value type
        // uint64 d_u64 = Duration.unwrap(d);
        // uint64 t_u54 = Timestamp.unwrap(t);
        clock = LibClock.wrap(d, t);
    }

    function unwrap_uvdt(Clock clock)
        external
        pure
        returns (Duration d, Timestamp t)
    {
        (d, t) = LibClock.unwrap(clock);
    }
}
```
## 参数修饰符
参数修饰符包括：public,private,immutable,constant
- public,自动生成 Getter 函数，表明函数在合约中可以通过abi查询
- private，参数无法通过abi直接查询，只能通过自定义的合约函数或sload(xx)通过slot 获得数据
- immutable，参数必须在构造函数中初始化，并且编码在字节码中，后续无法修改
- constant，参数在定义时，直接初始化，并且编码在字节码中，后续无法修改
- payable,用于修饰地址，表明允许该地址接收NativeToken
