
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
