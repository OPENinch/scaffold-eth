// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IDMM.sol";
import "./libraries/UniversalERC20.sol";
import "./libraries/DisableFlags.sol";
import "./OneSplitViewWrapBase.sol";
import "./OneSplitDMMBase.sol";

abstract contract OneSplitDMMView is OneSplitViewWrapBase, OneSplitDMMBase {
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
        return _dmmGetExpectedReturn(
            fromToken,
            destToken,
            amount,
            parts,
            flags,
            destTokenEthPriceTimesGasPrice
        );
    }

    function _dmmGetExpectedReturn(
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

        if (flags.check(FLAG_DISABLE_ALL_WRAP_SOURCES) == flags.check(FLAG_DISABLE_DMM)) {
            IERC20 underlying = _getDMMUnderlyingToken(fromToken);
            if (underlying != IERC20(address(0))) {
                if (underlying == weth) {
                    underlying = ETH_ADDRESS;
                }
                IERC20 _fromToken = fromToken;
                (returnAmount, estimateGasAmount, distribution) = _dmmGetExpectedReturn(
                    underlying,
                    destToken,
                    amount * (_getDMMExchangeRate(IDMM(address(_fromToken)))) / (1e18),
                    parts,
                    flags,
                    destTokenEthPriceTimesGasPrice
                );
                return (returnAmount, estimateGasAmount + 295_000, distribution);
            }

            underlying = _getDMMUnderlyingToken(destToken);
            if (underlying != IERC20(address(0))) {
                if (underlying == weth) {
                    underlying = ETH_ADDRESS;
                }
                uint256 price = _getDMMExchangeRate(IDMM(address(destToken)));
                (returnAmount, estimateGasAmount, distribution) = super.getExpectedReturnWithGas(
                    fromToken,
                    underlying,
                    amount,
                    parts,
                    flags,
                    destTokenEthPriceTimesGasPrice * (price) / (1e18)
                );
                return (
                    returnAmount * (1e18) / (price),
                    estimateGasAmount + 430_000,
                    distribution
                );
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
