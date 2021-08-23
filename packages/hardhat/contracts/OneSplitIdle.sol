// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IIdle.sol";
import "./libraries/UniversalERC20.sol";
import "./libraries/DisableFlags.sol";
import "./OneSplitBaseWrap.sol";
import "./OneSplitIdleBase.sol";

abstract contract OneSplitIdle is OneSplitBaseWrap, OneSplitIdleBase {
    using DisableFlags for uint256;
    using UniversalERC20 for IERC20;

    function _swap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256 flags
    ) virtual override internal {
        _idleSwap(
            fromToken,
            destToken,
            amount,
            distribution,
            flags
        );
    }

    function _idleSwap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256 flags
    ) internal {
        if (!flags.check(FLAG_DISABLE_ALL_WRAP_SOURCES) == !flags.check(FLAG_DISABLE_IDLE)) {
            IIdle[8] memory tokens = _idleTokens();

            for (uint i = 0; i < tokens.length; i++) {
                if (fromToken == IERC20(tokens[i])) {
                    IERC20 underlying = tokens[i].token();
                    uint256 minted = tokens[i].redeemIdleToken(amount, true, new uint256[](0));
                    _idleSwap(underlying, destToken, minted, distribution, flags);
                    return;
                }
            }

            for (uint i = 0; i < tokens.length; i++) {
                if (destToken == IERC20(tokens[i])) {
                    IERC20 underlying = tokens[i].token();
                    super._swap(fromToken, underlying, amount, distribution, flags);

                    uint256 underlyingBalance = underlying.balanceOf(address(this));
                    underlying.universalApprove(address(tokens[i]), underlyingBalance);
                    tokens[i].mintIdleToken(underlyingBalance, new uint256[](0));
                    return;
                }
            }
        }

        return super._swap(fromToken, destToken, amount, distribution, flags);
    }
}
