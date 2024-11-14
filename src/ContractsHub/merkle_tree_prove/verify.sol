// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract WhitelistMerkle {
    function verifyOnlyOneArgByOZ(
        bytes32[] calldata proof,
        bytes32 root,
        address account
    ) external pure returns (bool) {
        return
            MerkleProof.verifyCalldata(
            proof,
            root,
            _leafOnlyOneArgByOz(account)
        );
    }

    function _leafOnlyOneArgByOz(address account)
    internal
    pure
    returns (bytes32)
    {
        return keccak256(bytes.concat(keccak256(abi.encode(account))));
    }

    function verifyWithMultiArgs(
        bytes32[] calldata proof,
        bytes32 root,
        address account,
        uint256 amount
    ) external pure returns (bool) {
        return
            MerkleProof.verifyCalldata(
            proof,
            root,
            _leafWithMultiArgs(account, amount)
        );
    }

    function multiProofVerifyWithMultiArgByOz(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32 root,
        address[] calldata accounts,
        uint256[] calldata amounts
    ) external pure returns (bool) {
        bytes32[] memory leaves = new bytes32[](accounts.length);
        for (uint256 i = 0; i < accounts.length; i++) {
            leaves[i] = _leafWithMultiArgs(accounts[i], amounts[i]);
        }
        return
            MerkleProof.multiProofVerifyCalldata(
            proof,
            proofFlags,
            root,
            leaves
        );
    }

    function _leafWithMultiArgs(address account, uint256 amount)
    internal
    pure
    returns (bytes32)
    {
        return keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
    }
}
