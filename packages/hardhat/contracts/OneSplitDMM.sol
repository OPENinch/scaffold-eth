// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IDMM.sol";
import "./libraries/UniversalERC20.sol";
import "./libraries/DisableFlags.sol";
import "./OneSplitBaseWrap.sol";
import "./OneSplitDMMBase.sol";

abstract contract OneSplitDMM is OneSplitBaseWrap, OneSplitDMMBase {
    using DisableFlags for uint256;
    using UniversalERC20 for IERC20;

    function _swap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256 flags
    ) virtual override internal {
        _dmmSwap(
            fromToken,
            destToken,
            amount,
            distribution,
            flags
        );
    }

    function _dmmSwap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256 flags
    ) private {
        if (fromToken == destToken) {
            return;
        }

        if (flags.check(FLAG_DISABLE_ALL_WRAP_SOURCES) == flags.check(FLAG_DISABLE_DMM)) {
            IERC20 underlying = _getDMMUnderlyingToken(fromToken);
            if (underlying != IERC20(address(0))) {
                IDMM(address(fromToken)).redeem(amount);
                uint256 balance = underlying.universalBalanceOf(address(this));
                if (underlying == weth) {
                    weth.withdraw(balance);
                }
                _dmmSwap(
                    (underlying == weth) ? ETH_ADDRESS : underlying,
                    destToken,
                    balance,
                    distribution,
                    flags
                );
            }

            underlying = _getDMMUnderlyingToken(destToken);
            if (underlying != IERC20(address(0))) {
                super._swap(
                    fromToken,
                    (underlying == weth) ? ETH_ADDRESS : underlying,
                    amount,
                    distribution,
                    flags
                );

                uint256 underlyingAmount = ((underlying == weth) ? ETH_ADDRESS : underlying).universalBalanceOf(address(this));
                if (underlying == weth) {
                    weth.deposit{value: underlyingAmount};
                }

                underlying.universalApprove(address(destToken), underlyingAmount);
                IDMM(address(destToken)).mint(underlyingAmount);
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
