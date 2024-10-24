# User Defined Types
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
