# AddressToBytes
- 通过内存和内联编码存储数据，减少gas消耗
  - 内存存储，高位存储位置，低位存储具体数据
- `bytesAddress = new bytes(20);`
  - 内存分配从低位开始
  - 分配的空间存储数据 `size`, 具体数据在低位存储

Solidity Examples
```solidity
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title AddressBytesUtils
 * @dev This library provides utility functions to convert between `address` and `bytes`.
 */
library AddressBytes {
    error InvalidBytesLength(bytes bytesAddress);

    /**
     * @dev Converts a bytes address to an address type.
     * @param bytesAddress The bytes representation of an address
     * @return addr The converted address
     */
    function toAddress(bytes memory bytesAddress) internal pure returns (address addr) {
        if (bytesAddress.length != 20) revert InvalidBytesLength(bytesAddress);

        assembly {
            addr := mload(add(bytesAddress, 20))
        }
    }

    /**
     * @dev Converts an address to bytes.
     * @param addr The address to be converted
     * @return bytesAddress The bytes representation of the address
     */
    function toBytes(address addr) internal pure returns (bytes memory bytesAddress) {
        bytesAddress = new bytes(20);
        // we can test if using a single 32 byte variable that is the address with the length together and using one mstore would be slightly cheaper.
        assembly {
            mstore(add(bytesAddress, 20), addr) //160 bit
            mstore(bytesAddress, 20)
        }
    }
}

```