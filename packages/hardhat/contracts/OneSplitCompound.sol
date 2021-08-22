// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interfaces/ICompound.sol";
import "./OneSplitBase.sol";


abstract contract OneSplitCompoundView is OneSplitViewWrapBase {
    using SafeMath for uint256;
    using DisableFlags for uint256;

    function getExpectedReturnWithGas(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags,
        uint256 destTokenEthPriceTimesGasPrice
    ) virtual override
        public
        view
        returns(
            uint256 returnAmount,
            uint256 estimateGasAmount,
            uint256[] memory distribution
        )
    {
        return _compoundGetExpectedReturn(
            fromToken,
            destToken,
            amount,
            parts,
            flags,
            destTokenEthPriceTimesGasPrice
        );
    }

    function _compoundGetExpectedReturn(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags,
        uint256 destTokenEthPriceTimesGasPrice
    )
        private
        view
        returns(
            uint256 returnAmount,
            uint256 estimateGasAmount,
            uint256[] memory distribution
        )
    {
        if (fromToken == destToken) {
            return (amount, 0, new uint256[](DEXES_COUNT));
        }

        if (flags.check(FLAG_DISABLE_ALL_WRAP_SOURCES) == flags.check(FLAG_DISABLE_COMPOUND)) {
            IERC20 underlying = compoundRegistry.tokenByCToken(ICompoundToken(address(fromToken)));
            if (underlying != IERC20(address(0))) {
                uint256 compoundRate = ICompoundToken(address(fromToken)).exchangeRateStored();
                (returnAmount, estimateGasAmount, distribution) = _compoundGetExpectedReturn(
                    underlying,
                    destToken,
                    amount * (compoundRate) / (1e18),
                    parts,
                    flags,
                    destTokenEthPriceTimesGasPrice
                );
                return (returnAmount, estimateGasAmount + 295_000, distribution);
            }

            underlying = compoundRegistry.tokenByCToken(ICompoundToken(address(destToken)));
            if (underlying != IERC20(address(0))) {
                uint256 _destTokenEthPriceTimesGasPrice = destTokenEthPriceTimesGasPrice;
                uint256 compoundRate = ICompoundToken(address(destToken)).exchangeRateStored();
                (returnAmount, estimateGasAmount, distribution) = super.getExpectedReturnWithGas(
                    fromToken,
                    underlying,
                    amount,
                    parts,
                    flags,
                    _destTokenEthPriceTimesGasPrice * (compoundRate) / (1e18)
                );
                return (returnAmount * (1e18) / (compoundRate), estimateGasAmount + 430_000, distribution);
            }
        }

        return super.getExpectedReturnWithGas(
            fromToken,
            destToken,
            amount,
            parts,
            flags,
            destTokenEthPriceTimesGasPrice
        );
    }
}


abstract contract OneSplitCompound is OneSplitBaseWrap {
    using DisableFlags for uint256;

    using UniversalERC20 for IERC20;

    function _swap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256 flags
    ) virtual override internal {
        _compoundSwap(
            fromToken,
            destToken,
            amount,
            distribution,
            flags
        );
    }

    function _compoundSwap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256 flags
    ) private {
        if (fromToken == destToken) {
            return;
        }

        if (flags.check(FLAG_DISABLE_ALL_WRAP_SOURCES) == flags.check(FLAG_DISABLE_COMPOUND)) {
            IERC20 underlying = compoundRegistry.tokenByCToken(ICompoundToken(address(fromToken)));
            if (underlying != IERC20(address(0))) {
                ICompoundToken(address(fromToken)).redeem(amount);
                uint256 underlyingAmount = underlying.universalBalanceOf(address(this));

                return _compoundSwap(
                    underlying,
                    destToken,
                    underlyingAmount,
                    distribution,
                    flags
                );
            }

            underlying = compoundRegistry.tokenByCToken(ICompoundToken(address(destToken)));
            if (underlying != IERC20(address(0))) {
                super._swap(
                    fromToken,
                    underlying,
                    amount,
                    distribution,
                    flags
                );

                uint256 underlyingAmount = underlying.universalBalanceOf(address(this));

                if (underlying.isETH()) {
                    cETH.mint{value: underlyingAmount}(); //TODO: this cant be right
                } else {
                    underlying.universalApprove(address(destToken), underlyingAmount);
                    ICompoundToken(address(destToken)).mint(underlyingAmount);
                }
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
