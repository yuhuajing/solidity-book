// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract batchtrans is Ownable {
    constructor(address[] memory tokens, uint256[] memory units) payable {
        supportToken(tokens, units, true);
    }

    receive() external payable {}

    address private beneficiary = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    uint256 nativeTokenUnit = 10**10;
    uint256 beforeNativeToken;
    uint256 beforToken;
    uint256 private denominators = 10000;
    uint256 private taxFee = 100;
    bool private feeSwitch;

    mapping(address => bool) supporttoken;
    mapping(address => uint256) tokenunit;
    mapping(address => uint256) wlts;

    error Unsupportedtoken();

    function setSupportToken(
        address[] memory tokens,
        uint256[] memory units,
        bool status
    ) external onlyOwner {
        supportToken(tokens, units, status);
    }

    function supportToken(
        address[] memory tokens,
        uint256[] memory units,
        bool status
    ) private {
        uint256 len = tokens.length;
        require(len == units.length, "Mismatched");
        address token;
        uint256 unit;
        for (uint256 index = 0; index < len; index++) {
            token = tokens[index];
            unit = units[index];
            supporttoken[token] = status;
            tokenunit[token] = 10**unit;
        }
    }

    function batchTransfer(address[] calldata addresses, uint256 amount)
    external
    payable
    {
        _beforeTokenTransfer(address(0));
        uint256 len = addresses.length;
        require(len != 0, "please enter the acceptance address");
        address receiver;
        for (uint256 i = 0; i < len; i++) {
            receiver = addresses[i];
            require(address(receiver) != address(0), "invalid address");
            tokenTransfer(address(0), receiver, amount * nativeTokenUnit);
        }
        tokenFee(address(0), amount * nativeTokenUnit);
        _afterTokenTransfer(address(0));
    }

    function batchTransfer(
        address[] calldata addresses,
        uint256[] calldata amounts
    ) external payable {
        _beforeTokenTransfer(address(0));
        uint256 addrLen = addresses.length;
        {
            require(addrLen != 0, "please enter the acceptance address");
            require(addrLen == amounts.length, "mismatched array");
        }
        address receiver;
        uint256 amount;
        uint256 totalamount;
        for (uint256 i = 0; i < addrLen; i++) {
            receiver = addresses[i];
            amount = amounts[i];
            totalamount += amount;
            tokenTransfer(address(0), receiver, amount * nativeTokenUnit);
        }
        tokenFee(address(0), totalamount * nativeTokenUnit);
        _afterTokenTransfer(address(0));
    }

    function batchTransferToken(
        address token,
        address[] calldata addresses,
        uint256 amount
    ) external payable {
        _beforeTokenTransfer(token);
        uint256 len = addresses.length;
        require(len != 0, "please enter the acceptance address");
        address receiver;
        uint256 unit = tokenunit[token];
        for (uint256 i = 0; i < len; i++) {
            receiver = addresses[i];
            tokenTransfer(token, receiver, amount * unit);
        }
        tokenFee(token, amount * unit);
        _afterTokenTransfer(token);
    }

    function batchTransferToken(
        address token,
        address[] calldata addresses,
        uint256[] calldata amounts
    ) external payable {
        _beforeTokenTransfer(token);
        uint256 addrLen = addresses.length;
        {
            require(addrLen != 0, "please enter the acceptance address");
            require(addrLen == amounts.length, "mismatched");
        }
        address receiver;
        uint256 amount;
        uint256 totalamount;
        uint256 unit = tokenunit[token];
        for (uint256 i = 0; i < addrLen; i++) {
            receiver = addresses[i];
            amount = amounts[i];
            totalamount += amount;
            tokenTransfer(token, receiver, amount * unit);
        }
        tokenFee(token, totalamount * unit);
        _afterTokenTransfer(token);
    }

    function tokenTransfer(
        address token,
        address receiver,
        uint256 amount
    ) private {
        if (token == address(0)) {
            Address.sendValue(payable(receiver), amount);
        } else {
            IERC20(token).transferFrom(_msgSender(), receiver, amount);
        }
    }

    function tokenFee(address token, uint256 amount) private {
        address sender = _msgSender();
        uint256 ts = block.timestamp;
        if (feeSwitch && wlts[sender] < ts) {
            uint256 payTaxFee = (amount * taxFee) / denominator();
            if (token == address(0)) {
                Address.sendValue(payable(beneficiary), payTaxFee);
            } else {
                IERC20(token).transferFrom(
                    _msgSender(),
                    beneficiary,
                    payTaxFee
                );
            }
        }
    }

    function withdraw() external onlyOwner {
        Address.sendValue(payable(beneficiary), address(this).balance);
    }

    function withdrawToken(address token) external onlyOwner {
        uint256 amount = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(beneficiary, amount);
    }

    function setWlts(address wl, uint256 _ts) public onlyOwner {
        uint256 ts = block.timestamp;
        wlts[wl] = ts + _ts;
    }

    function setTaxFee(uint256 fee) public onlyOwner {
        require(fee != 0, "TaxFee_Need_More_Than_0");
        require(fee < denominators, "TaxFee_Need_Lee_Than_Denominator");
        taxFee = fee;
    }

    function setFeeSwitch(bool _switch) public onlyOwner {
        feeSwitch = _switch;
    }

    function setDominatoe(uint256 _denominators) public onlyOwner {
        require(_denominators != 0, "TaxFee_Need_More_Than_0");
        denominators = _denominators;
    }

    function denominator() public view returns (uint256) {
        return denominators;
    }

    function _beforeTokenTransfer(address token) internal virtual {
        if (token == address(0)) {
            beforeNativeToken = address(this).balance - msg.value;
        } else {
            if (!supporttoken[token]) {
                revert Unsupportedtoken();
            }
            beforToken = IERC20(token).balanceOf(address(this));
        }
    }

    function _afterTokenTransfer(address token) internal virtual {
        if (token == address(0)) {
            require(
                beforeNativeToken <= address(this).balance,
                "Post condition error"
            );
        } else {
            require(
                beforToken <= IERC20(token).balanceOf(address(this)),
                "Post condition error"
            );
        }
    }

    function updateNativeTokenUnit(uint256 _unit) external onlyOwner {
        nativeTokenUnit = _unit;
    }

    function updateTokenUnit(address token, uint256 _unit) external onlyOwner {
        if (!supporttoken[token]) {
            revert Unsupportedtoken();
        }
        tokenunit[token] = _unit;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function setBeneficiary(address _beneficiary) external onlyOwner {
        beneficiary = _beneficiary;
    }

    function renounceOwnership() public view override onlyOwner {
        revert("Closed_Interface");
    }
}
