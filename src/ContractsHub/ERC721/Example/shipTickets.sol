// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ShipTickets is ERC721 {
    struct Configure {
        uint32 start;
        uint32 amount;
        uint32 minted;
    }

    address public owner;
    address public miner;
    string baseurl;
    mapping(uint256 => Configure) shipTickets;

    error NotOwnerAuthorized();
    error NotNFTCallercontract();
    error NotMineAuthorized();

    constructor(
        string memory name,
        string memory symbol,
        string memory _baseurl,
        address _miner
    ) ERC721(name, symbol) {
        owner = msg.sender;
        baseurl = _baseurl;
        miner = _miner;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwnerAuthorized();
        _;
    }

    modifier onlyMiner() {
        if (msg.sender != miner) revert NotMineAuthorized();
        _;
    }

    function updateOwner(address newowner) external onlyOwner {
        require(newowner != address(0), "Invalid Owner");
        owner = newowner;
    }

    function updateMiner(address newminer) external onlyOwner {
        require(newminer != address(0), "Invalid miner");
        miner = newminer;
    }

    function updateBaseURL(string memory _baseurl) external onlyOwner {
        require(bytes(_baseurl).length != 0, "Invalid baseurl");
        baseurl = _baseurl;
    }

    function initialize(
        uint32 goldstart,
        uint32 goldamount,
        uint32 silverstart,
        uint32 silveramount,
        uint32 copperstart,
        uint32 copperamount
    ) external onlyOwner {
        if (goldamount != 0) {
            delete shipTickets[0];
            shipTickets[0] = Configure({
                start: goldstart,
                amount: goldamount,
                minted: 0
            });
        }

        if (silveramount != 0) {
            delete shipTickets[1];
            shipTickets[1] = Configure({
                start: silverstart,
                amount: silveramount,
                minted: 0
            });
        }

        if (copperamount != 0) {
            delete shipTickets[2];
            shipTickets[2] = Configure({
                start: copperstart,
                amount: copperamount,
                minted: 0
            });
        }
    }

    function airDrop(
        uint256 shiptype,
        address receiver,
        uint32 amount
    ) external onlyMiner {
        Configure storage config = shipTickets[shiptype];
        require(config.amount >= config.minted + amount, "Not enough NFT left");
        uint32 minted = config.minted;
        config.minted += amount;
        for (uint256 i = 0; i < amount; i++) {
            _mint(receiver, minted + i);
        }
    }

    function burn(uint256 tokenId) external {
        _burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override(ERC721)
        returns (string memory)
    {
        _requireOwned(tokenId);
        return
            bytes(baseurl).length != 0
                ? string(abi.encodePacked(baseurl, _toString(tokenId), ".json"))
                : "";
    }

    function _toString(uint256 value)
        internal
        pure
        virtual
        returns (string memory str)
    {
        assembly {
            // The maximum value of a uint256 contains 78 digits (1 byte per digit), but
            // we allocate 0xa0 bytes to keep the free memory pointer 32-byte word aligned.
            // We will need 1 word for the trailing zeros padding, 1 word for the length,
            // and 3 words for a maximum of 78 digits. Total: 5 * 0x20 = 0xa0.
            let m := add(mload(0x40), 0xa0)
            // Update the free memory pointer to allocate.
            mstore(0x40, m)
            // Assign the `str` to the end.
            str := sub(m, 0x20)
            // Zeroize the slot after the string.
            mstore(str, 0)

            // Cache the end of the memory to calculate the length later.
            let end := str

            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            // prettier-ignore
            for { let temp := value } 1 {} {
                str := sub(str, 1)
                // Write the character to the pointer.
                // The ASCII index of the '0' character is 48.
                mstore8(str, add(48, mod(temp, 10)))
                // Keep dividing `temp` until zero.
                temp := div(temp, 10)
                // prettier-ignore
                if iszero(temp) { break }
            }

            let length := sub(end, str)
            // Move the pointer 32 bytes leftwards to make room for the length.
            str := sub(str, 0x20)
            // Store the length.
            mstore(str, length)
        }
    }
}
