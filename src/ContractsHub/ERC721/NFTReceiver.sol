// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import "@openzeppelin/contracts/utils/Address.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";


contract testWallet is IERC721Receiver {

    function transferTokens(
        address contractaddress,
        address recipient,
        uint256 tokenID
    ) public {
        IERC721(contractaddress).transferFrom(
            address(this),
            recipient,
            tokenID
        );
    }

     function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure returns (bytes4){
        return IERC721Receiver.onERC721Received.selector;
    }

    fallback() external payable {}

    receive() external payable {}
}
