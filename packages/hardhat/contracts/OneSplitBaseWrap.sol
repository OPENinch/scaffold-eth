// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./OneSplitConsts.sol";

abstract contract OneSplitBaseWrap is OneSplitConsts {/*is One SplitRoot {*/ // removed IOneSplit,
    function _swap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256 flags // See constants in IOneSplit.sol
    ) virtual internal {
        if (fromToken == destToken) {
            return;
        }

        _swapFloor(
            fromToken,
            destToken,
            amount,
            distribution,
            flags
        );
    }

    function _swapFloor(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256 /*flags*/ // See constants in IOneSplit.sol
    ) virtual internal;
}
