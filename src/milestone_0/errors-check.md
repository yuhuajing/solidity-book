# try-catch
## [异常捕获](https://www.rareskills.io/post/try-catch-solidity)


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
