// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interfaces/ICompound.sol";
import "./OneSplitBase.sol";


abstract contract OneSplitWethView is OneSplitViewWrapBase {
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
        return _wethGetExpectedReturn(
            fromToken,
            destToken,
            amount,
            parts,
            flags,
            destTokenEthPriceTimesGasPrice
        );
    }

    function _wethGetExpectedReturn(
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

        if (flags.check(FLAG_DISABLE_ALL_WRAP_SOURCES) == flags.check(FLAG_DISABLE_WETH)) {
            if (fromToken == weth || fromToken == bancorEtherToken) {
                return super.getExpectedReturnWithGas(ETH_ADDRESS, destToken, amount, parts, flags, destTokenEthPriceTimesGasPrice);
            }

            if (destToken == weth || destToken == bancorEtherToken) {
                return super.getExpectedReturnWithGas(fromToken, ETH_ADDRESS, amount, parts, flags, destTokenEthPriceTimesGasPrice);
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


abstract contract OneSplitWeth is OneSplitBaseWrap {
    using DisableFlags for uint256;

    function _swap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256 flags
    ) virtual override internal {
        _wethSwap(
            fromToken,
            destToken,
            amount,
            distribution,
            flags
        );
    }

    function _wethSwap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256 flags
    ) private {
        if (fromToken == destToken) {
            return;
        }

        if (flags.check(FLAG_DISABLE_ALL_WRAP_SOURCES) == flags.check(FLAG_DISABLE_WETH)) {
            if (fromToken == weth) {
                weth.withdraw(weth.balanceOf(address(this)));
                super._swap(
                    ETH_ADDRESS,
                    destToken,
                    amount,
                    distribution,
                    flags
                );
                return;
            }

            if (fromToken == bancorEtherToken) {
                bancorEtherToken.withdraw(bancorEtherToken.balanceOf(address(this)));
                super._swap(
                    ETH_ADDRESS,
                    destToken,
                    amount,
                    distribution,
                    flags
                );
                return;
            }

            if (destToken == weth) {
                _wethSwap(
                    fromToken,
                    ETH_ADDRESS,
                    amount,
                    distribution,
                    flags
                );
                weth.deposit{value: (address(this).balance)}();
                return;
            }

            if (destToken == bancorEtherToken) {
                _wethSwap(
                    fromToken,
                    ETH_ADDRESS,
                    amount,
                    distribution,
                    flags
                );
                bancorEtherToken.deposit{value: (address(this).balance)}();
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
