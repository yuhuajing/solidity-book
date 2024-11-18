# Common mistakes
## Div before Mul
Solidity只有整数，不支持小数运算,默认的整数乘除向下取整。
```text
**// Wrong way:**
If principal = 3000,
interest = principal / 3333 * 10000
interest = 3000 / 3333 * 10000
interest = 0 * 10000 (rounding down in division)
interest = 0

// **Correct Calculation:**
If principal = 3000,
interest = principal * 10000 / 3333
interest = 3000 * 10000 / 3333
interest = 30000000 / 3333 interest approx 9000
```
[Fixed point ABDK](https://github.com/abdk-consulting/abdk-libraries-solidity/blob/master/README.md)
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "https://github.com/abdk-consulting/abdk-libraries-solidity/blob/master/ABDKMath64x64.sol";

contract MathPaper {
    // k, N 都是整数
    function func1(uint256 k, uint256 N) public pure returns (uint64) {
        uint256 numerator = k + N + 1;
        uint256 denominator = N + 1;
        return log2(numerator) - log2(denominator);
    }

    function func3(uint256 dt, uint256 e) public pure returns (uint256) {
        if (dt < e) {
            return 100;
        }
        uint256 exp = Math.ceilDiv((dt - e) * 100, e); //0.2==>20
        uint256 dominator = power(100, exp);
        return 1000000  / dominator;
    }


    function power(uint256 base, uint256 exp) public pure returns (uint256) {
        // Represent base as a fixed-point number.
        int128 baseFixed = ABDKMath64x64.fromUInt(base);

        // Calculate ln(base)
        int128 lnBase = ABDKMath64x64.ln(baseFixed);

        // Represent exp as a fixed-point number.
        int128 expFixed = ABDKMath64x64.divu(exp, 100);

        // Calculate ln(base) * exp
        int128 product = ABDKMath64x64.mul(lnBase, expFixed);

        // Calculate e^(ln(base) * exp)
        int128 result = ABDKMath64x64.exp(product);

        // Multiply by 10^5 to keep 5 decimal places
        result = ABDKMath64x64.mul(result, ABDKMath64x64.fromUInt(10**2));

        // Convert the fixed-point result to a uint and return it.
        return ABDKMath64x64.toUInt(result);
    }

    function log2(uint256 base) public pure returns (uint64) {
        // Represent base as a fixed-point number.
        int128 baseFixed = ABDKMath64x64.fromUInt(base);
        // Calculate ln(base)
        int128 lnBase = ABDKMath64x64.log_2(baseFixed) * 1e4;
        uint64 t = ABDKMath64x64.toUInt(lnBase);
        return t;
    }

}
```
## Not following check-effects-interaction
1. `check-effects-interaction` 模式将合约交互放在条件校验、数据更新之后，防止重入攻击。
2. 合约交互包含 外部合约的 `call|delegateCall|staticCall` 调用、`Native Token` 转账
3. 合约交互操作应该放在整个函数的最后，确保无法正常执行重入攻击（即使重入，数据也是已经更新后的数值）

重入攻击的示例：
```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// DO NOT USE
contract BadBank {
    mapping(address => uint256) public balances;

    constructor() payable {
        require(msg.value == 10 ether, "deposit 10 eth");
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        // should be after the check and effects
        (bool ok, ) = msg.sender.call{value: balances[msg.sender]}("");
        require(ok, "transfer failed");
        // shoule be the first
        balances[msg.sender] = 0;
    }
}

contract attack {
    function deposit(BadBank bank) external payable {
        bank.deposit{value: msg.value}();
        bank.withdraw();
    }

    receive() external payable {
        if (msg.sender.balance >= 1 ether) {
            BadBank(msg.sender).withdraw();
        }
    }
}
```
## Transfer Native Token by 'transfer' or 'send'
1. `transfer or send` 转账模式 
   1. 为了避免重入攻击，只传递有限的 gas，让调用的合约不能执行过多的合约逻辑
   2. 默认调用时传递 `2300 gas`,其中 `transfer` 执行失败会 `revert`，`send` 不会 `revert` 但是会返回待处理的 `boolean`
2. `sload` 字节码在升级后的gas 花销分为： `non-warm-2100, warm-100`
    1. 升级后如果仍然传递默认的 `2300gas`，也无法容忍 对方合约中 `fallback|receiver` 存在读取地址的行为
```solidity
// in the bank receiver() function, recors the deposit behavior
   receive() external payable {
      balances[msg.sender] += msg.value;
   }
// In the call contract, the deposit transfer function will fail, because only passing 2300 gas could not support the record behavior
contract attack {
   function transfer(BadBank bank) external payable {
      payable(address(bank)).transfer(msg.value);
   }
}
```
3. 在 `check-effects-interation` 模式中使用 [call](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol) 进行安全转账，处理 call 调用返回的 (bool success, bytes data)
```solidity
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert Errors.InsufficientBalance(address(this).balance, amount);
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert Errors.FailedCall();
        }
    }
```
## misusing of `tx.origin` and `msg.sender`
1. `tx.origin` 指的是当前交易的签名者，初始构造者，在整个交易的生命周期中不会发生变化
2. `msg.sender` 指的是当前 `EVM` 环境中的交易发起方，会随着 EVM 环境的话变化而返回不同的地址

## Not using safeTransfer in ERC20
1. ERC20代币存在两套不同的转账函数
    1. 有些代币的转账函数不存在返回值，比如 USDT的转账
    2. 有些代币的转账函数存在返回值，比如标准的ERC20合约
2. 针对不同的转账标准， safeTransfer 可以处理全部情况
    1. 在外部调用存在 revert 的情况下，直接 revert
    2. 外部调用不存在返回值的情况下，如果被调用者不是一个合约地址的话，直接 revert报错
    3. 外部调用不存在返回值的情况下，如果被调用者是一个合法合约地址的话，交易成功
    4. 外部调用存在返回值的情况下，如果返回值不是 1（true），直接 revert报错
```solidity
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            let success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            // bubble errors
            if iszero(success) {
                let ptr := mload(0x40)
                returndatacopy(ptr, 0, returndatasize())
                revert(ptr, returndatasize())
            }
            returnSize := returndatasize()
            returnValue := mload(0)
        }

        if (returnSize == 0 ? address(token).code.length == 0 : returnValue != 1) {
            revert SafeERC20FailedOperation(address(token));
        }
    }
```
### No need safeMath in solidity ^0.8.0+
### Invalid access control or Uninitialized functions in the logic contract
### 使用确定的循环问题
### 使用确定的solidity 版本
## Preference
https://www.rareskills.io/post/solidity-beginner-mistakes
