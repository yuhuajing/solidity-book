// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import "erc721a/contracts/ERC721A.sol";

contract PrimeNavigator is ERC721A {
    address public owner;
    address public miner;
    address public nftcaller;
    uint256 public mintCap;
    string baseurl;
    bool allowobliterate;
    mapping(uint256 => bool) allowBurnId;

    error NotOwnerAuthorized();
    error NotNFTCallercontract();
    error NotMineAuthorized();

    constructor(
        string memory name,
        string memory symbol,
        string memory _baseurl,
        uint256 _mintCap,
        address _nftcaller,
        address _miner
    ) payable ERC721A(name, symbol) {
        owner = msg.sender;
        mintCap = _mintCap;
        nftcaller = _nftcaller;
        baseurl = _baseurl;
        miner = _miner;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwnerAuthorized();
        _;
    }
    modifier onlynftCaller() {
        if (msg.sender != nftcaller) revert NotNFTCallercontract();
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

    function totalMinted() public view returns (uint256) {
        return _nextTokenId();
    }

    function availMint() public view returns (uint256) {
        return mintCap - totalMinted();
    }

    function updateNFTCaller(address newcaller) external onlyOwner {
        require(newcaller != address(0), "Invalid Owner");
        nftcaller = newcaller;
    }

    function allowReconstructive(uint256 tokenId) external onlyOwner {
        allowBurnId[tokenId] = true;
    }

    function reconstructive(uint256 tokenId) external {
        require(allowBurnId[tokenId], "Not allow reconstructive");
        require(
            totalMinted() >= mintCap,
            "Forbid reconstructive with remaining NFT left"
        );
        _burn(tokenId);
        _mint(msg.sender, 1);
    }

    function allowObliterate() external onlyOwner {
        allowobliterate = true;
    }

    function obliterate(uint256 amount) external onlyOwner {
        require(allowobliterate, "Not allow burn");
        uint256 ncount = amount + totalMinted() >= mintCap
            ? mintCap
            : amount + totalMinted();

        uint256 pendingNFT = ncount - totalMinted();
        uint256 mintedNFT = totalMinted();
        _mint(msg.sender, pendingNFT);

        for (uint256 index = mintedNFT; index < ncount; index++) {
            _burn(index);
        }
    }

    function ownerMint(address[] memory receivers, uint256[] memory amounts)
        external
        onlyMiner
    {
        require(receivers.length == amounts.length, "Mismatched length");
        address receiver;
        uint256 amount;
        for (uint256 i = 0; i < receivers.length; i++) {
            receiver = receivers[i];
            amount = amounts[i];
            require(totalMinted() + amount <= mintCap, "Exceed mintcap");
            _mint(receiver, amount);
        }
    }

    function airdrop(address[] memory receivers, uint256[] memory amounts)
        external
        onlyMiner
    {
        require(receivers.length == amounts.length, "Mismatched length");

        address receiver;
        uint256 amount;
        for (uint256 i = 0; i < receivers.length; i++) {
            receiver = receivers[i];
            amount = amounts[i];
            require(totalMinted() + amount <= mintCap, "Exceed mintcap");
            _mint(receiver, amount);
        }
    }

    function _ownerMint(address receiver, uint256 amount) external onlyMiner {
        require(totalMinted() + amount <= mintCap, "Exceed mintcap");
        _mint(receiver, amount);
    }

    function burn(uint256 tokenId) external {
        _burn(tokenId);
    }

    function nftcallermint(address receiver, uint256 amount)
        external
        onlynftCaller
        returns (bool)
    {
        require(totalMinted() + amount <= mintCap, "Exceed mintcap");
        _mint(receiver, amount);
        return true;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();
        return
            bytes(baseurl).length != 0
                ? string(abi.encodePacked(baseurl, _toString(tokenId), ".json"))
                : "";
    }
}
