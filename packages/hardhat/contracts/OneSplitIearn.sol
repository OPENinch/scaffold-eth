// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IIearn.sol";
import "./libraries/UniversalERC20.sol";
import "./libraries/DisableFlags.sol";
import "./OneSplitBaseWrap.sol";
import "./OneSplitIearnBase.sol";

abstract contract OneSplitIearn is OneSplitBaseWrap, OneSplitIearnBase {
    using DisableFlags for uint256;
    using UniversalERC20 for IERC20;

    function _swap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256 flags
    ) virtual override internal {
        _iearnSwap(
            fromToken,
            destToken,
            amount,
            distribution,
            flags
        );
    }

    function _iearnSwap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256 flags
    ) private {
        if (fromToken == destToken) {
            return;
        }

        if (flags.check(FLAG_DISABLE_ALL_WRAP_SOURCES) == flags.check(FLAG_DISABLE_IEARN)) {
            IIearn[13] memory yTokens = _yTokens();

            for (uint i = 0; i < yTokens.length; i++) {
                if (fromToken == IERC20(yTokens[i])) {
                    IERC20 underlying = yTokens[i].token();
                    yTokens[i].withdraw(amount);
                    _iearnSwap(underlying, destToken, underlying.balanceOf(address(this)), distribution, flags);
                    return;
                }
            }

            for (uint i = 0; i < yTokens.length; i++) {
                if (destToken == IERC20(yTokens[i])) {
                    IERC20 underlying = yTokens[i].token();
                    super._swap(fromToken, underlying, amount, distribution, flags);

                    uint256 underlyingBalance = underlying.balanceOf(address(this));
                    underlying.universalApprove(address(yTokens[i]), underlyingBalance);
                    yTokens[i].deposit(underlyingBalance);
                    return;
                }
            }
        }

        return super._swap(fromToken, destToken, amount, distribution, flags);
    }
}
