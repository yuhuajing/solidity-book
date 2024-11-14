// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import {SafeTransferLib} from "solmate/src/utils/SafeTransferLib.sol";
import "solmate/src/tokens/ERC20.sol";

interface INFTMinter {
    function mint(uint64, address) external returns (bool);
}

contract Launchpad is ReentrancyGuard {
    using ECDSA for bytes32;
    mapping(uint64 => bool) private ridvalue;

    function _validateSignature(
        uint32 payTokenIndex,
        uint32 expireTime,
        address sender,
        address signer,
        uint64[4] calldata num64,
        bytes calldata signature
    ) internal {
        uint64 rid = num64[0];
        require((!ridvalue[rid]), "Duplicated signature");
        require(
            matchSigner(
                signer,
                getCosignDigest(payTokenIndex, sender, num64),
                signature
            ),
            "Invalid signature"
        );
        ridvalue[rid] = true;
    }

    /**
     * @dev Returns data hash for the given minter, qty and timestamp.
     */
    function getCosignDigest(
        uint32 payTokenIndex,
        address sender,
        uint64[4] memory num64
    ) private view returns (bytes32) {
        bytes32 hash = keccak256(
            abi.encodePacked(sender, payTokenIndex, _chainID(), num64)
        );
        return toEthSignedMessageHash(hash);
    }

    function toEthSignedMessageHash(bytes32 hash)
    internal
    pure
    returns (bytes32 message)
    {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, "\x19Ethereum Signed Message:\n32")
            mstore(0x1c, hash)
            message := keccak256(0x00, 0x3c)
        }
    }

    function matchSigner(
        address signer,
        bytes32 hash,
        bytes memory signature
    ) private view returns (bool) {
        return SignatureChecker.isValidSignatureNow(signer, hash, signature);
    }

    /**
     * @dev Returns chain id.
     */
    function _chainID() public view returns (uint32) {
        uint32 chainID;
        assembly {
            chainID := chainid()
        }
        return chainID;
    }
}
