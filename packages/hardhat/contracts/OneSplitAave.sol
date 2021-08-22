// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IAaveToken.sol";
import "./libraries/DisableFlags.sol";
import "./libraries/UniversalERC20.sol";
import "./OneSplitBaseWrap.sol";

abstract contract OneSplitAave is OneSplitBaseWrap {
    using DisableFlags for uint256;
    using UniversalERC20 for IERC20;

    function _swap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256 flags
    ) virtual override internal {
        _aaveSwap(
            fromToken,
            destToken,
            amount,
            distribution,
            flags
        );
    }

    function _aaveSwap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256 flags
    ) private {
        if (fromToken == destToken) {
            return;
        }

        if (flags.check(FLAG_DISABLE_ALL_WRAP_SOURCES) == flags.check(FLAG_DISABLE_AAVE)) {
            IERC20 underlying = aaveRegistry.tokenByAToken(IAaveToken(address(fromToken)));
            if (underlying != IERC20(address(0))) {
                IAaveToken(address(fromToken)).redeem(amount);

                return _aaveSwap(
                    underlying,
                    destToken,
                    amount,
                    distribution,
                    flags
                );
            }

            underlying = aaveRegistry.tokenByAToken(IAaveToken(address(destToken)));
            if (underlying != IERC20(address(0))) {
                super._swap(
                    fromToken,
                    underlying,
                    amount,
                    distribution,
                    flags
                );

                uint256 underlyingAmount = underlying.universalBalanceOf(address(this));

                underlying.universalApprove(aave.core(), underlyingAmount);
                aave.deposit{value: (underlying.isETH() ? underlyingAmount : 0)}(
                    underlying.isETH() ? ETH_ADDRESS : underlying,
                    underlyingAmount,
                    1101
                );
                return;
            }
        }

        return super._swap(
            fromToken,
            destToken,
            amount,
            distribution,
            flags
        );
    }
}
