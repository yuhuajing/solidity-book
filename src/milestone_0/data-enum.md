# ENUM
- 枚举 <kbd>enum</kbd> 作为用户自定义的变量集合，用于定义有限的多种状态
  - 由于 `enum` 有限，后续除非重新部署合约，否则无法新增状态
  - `enum` 适用于确定的有限状态，否则使用 `动态数组` 更适合后续扩展
- <kbd>enum</kbd>内部的变量从 `0 index` 开始, `default: 0`
```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract enumExamples {
    enum ActionChoices {
        GoLeft,
        GoRight,
        GoStraight,
        SitStill
    }
    ActionChoices choice;
    ActionChoices constant defaultChoice = ActionChoices.GoStraight;

    function setGoStraight() public {
        choice = ActionChoices.GoStraight;
    }

    function setChoice(ActionChoices _choice) public {
        choice = _choice;
    }

    // Since enum types are not part of the ABI, the signature of "getChoice"
    // will automatically be changed to "getChoice() returns (uint8)"
    // for all matters external to Solidity.
    function getChoice() public view returns (ActionChoices) {
        return choice;
    }

    function getDefaultChoice() public pure returns (uint256) {
        return uint256(defaultChoice);
    }

    function getLargestValue() public pure returns (ActionChoices) {
        return type(ActionChoices).max;
    }

    function getSmallestValue() public pure returns (ActionChoices) {
        return type(ActionChoices).min;
    }
}
```
