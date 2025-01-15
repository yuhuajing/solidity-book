# MultiCall
- 当前合约执行执行 `multiCall`

Solidity Examples
```solidity

    error MulticallFailed();

    enum callType {
        delegatecall,
        call
    }

    function multicall(bytes[] calldata data, callType calltype)
        public
        payable
        returns (bytes[] memory results)
    {
        results = new bytes[](data.length);
        bool success;
        bytes memory result;
        for (uint256 i = 0; i < data.length; ++i) {
            if (calltype == callType.delegatecall) {
                // slither-disable-next-line calls-loop,delegatecall-loop
                (success, result) = address(this).delegatecall(data[i]);
            } else if (calltype == callType.call) {
                // slither-disable-next-line calls-loop,delegatecall-loop
                (success, result) = address(this).call{
                    value: msg.value / data.length
                }(data[i]);
            }

            if (!success) {
                if (result.length == 0) revert MulticallFailed();
                assembly {
                    revert(add(32, result), mload(result))
                }
            }

            results[i] = result;
        }
    }
```