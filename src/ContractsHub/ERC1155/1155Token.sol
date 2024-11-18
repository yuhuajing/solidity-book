// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract My1155Token is Ownable, ERC1155 {
    constructor() ERC1155("") Ownable(msg.sender) {}

    struct TokenInfo {
        uint256 tokenid;
        uint256 minted;
        uint256 totalamount;
        string name;
        string symbol;
        string url;
    }

    function uri(uint256 id)
        public
        view
        virtual
        override
        returns (string memory)
    {
        return tokenIDInfo[id].url;
    }

    mapping(uint256 => mapping(address => uint256)) public balance; // tokenid==> address=>amount
    mapping(uint256 => TokenInfo) tokenIDInfo; // tokenid

    function settokenIDInfo(
        uint256 tokenid,
        uint256 totalamount,
        string memory name,
        string memory symbol,
        string memory url //https://ipfs.io/ipfs/QmW948aN4Tjh4eLkAAo8os1AcM2FJjA46qtaEfFAnyNYzY
    ) external onlyOwner {
        require(
            tokenIDInfo[tokenid].totalamount == 0,
            "TokenID already Initialized"
        );
        TokenInfo memory tokeninfo = TokenInfo({
            tokenid: tokenid,
            minted: 0,
            totalamount: totalamount,
            name: name,
            symbol: symbol,
            url: url
        });
        tokenIDInfo[tokenid] = tokeninfo;
    }

    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public onlyOwner {
        require(tokenIDInfo[id].totalamount > 0, "TokenID not Initialized");
        require(
            tokenIDInfo[id].minted + amount <= tokenIDInfo[id].totalamount,
            "Not Enough TokenID left"
        );
        _mint(account, id, amount, data);
        tokenIDInfo[id].minted = amount;
    }

    function burn(
        address account,
        uint256 id,
        uint256 value
    ) public virtual {
        if (
            account != _msgSender() && !isApprovedForAll(account, _msgSender())
        ) {
            revert ERC1155MissingApprovalForAll(_msgSender(), account);
        }

        _burn(account, id, value);

        tokenIDInfo[id].minted -= value;
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _value,
        bytes memory _data
    ) public pure virtual override {
        revert("Transfer not supported for soul bound token.");
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) public virtual override {
        revert("Transfer not supported for soul bound token.");
    }

    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {
        revert("Transfer not supported for soul bound token.");
    }

    function isApprovedForAll(address account, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        revert("Transfer not supported for soul bound token.");
    }

    function updateTotalAmount(uint256 tokenid, uint256 totalamount)
        external
        onlyOwner
    {
        require(
            tokenIDInfo[tokenid].totalamount > 0,
            "TokenID not Initialized"
        );
        tokenIDInfo[tokenid].totalamount = totalamount;
        //  emit UpdateTokenid(tokenid, totalamount);
    }

    function updateURL(uint256 tokenid, string memory url) external onlyOwner {
        require(
            tokenIDInfo[tokenid].totalamount > 0,
            "TokenID not Initialized"
        );
        tokenIDInfo[tokenid].url = url;
        //emit UpdateUrl(tokenid, url);
    }

    function updateNameSymbol(
        uint256 tokenid,
        string memory name,
        string memory symbol
    ) external onlyOwner {
        require(
            tokenIDInfo[tokenid].totalamount > 0,
            "TokenID not Initialized"
        );
        tokenIDInfo[tokenid].name = name;
        tokenIDInfo[tokenid].symbol = symbol;
        //emit Updatenamesymbol(tokenid, name, symbol);
    }

    function geturl(uint256 tokenid) external view returns (string memory) {
        return tokenIDInfo[tokenid].url;
    }

    function getname(uint256 tokenid) external view returns (string memory) {
        return tokenIDInfo[tokenid].name;
    }

    function getsymbol(uint256 tokenid) external view returns (string memory) {
        return tokenIDInfo[tokenid].symbol;
    }

    function gettotalamount(uint256 tokenid) external view returns (uint256) {
        return tokenIDInfo[tokenid].totalamount;
    }

    function getminted(uint256 tokenid) external view returns (uint256) {
        return tokenIDInfo[tokenid].minted;
    }
}
