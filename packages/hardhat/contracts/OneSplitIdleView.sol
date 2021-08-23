// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./libraries/DisableFlags.sol";
import "./OneSplitViewWrapBase.sol";
import "./OneSplitIdleBase.sol";

abstract contract OneSplitIdleView is OneSplitViewWrapBase, OneSplitIdleBase {
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
        return _idleGetExpectedReturn(
            fromToken,
            destToken,
            amount,
            parts,
            flags,
            destTokenEthPriceTimesGasPrice
        );
    }

    function _idleGetExpectedReturn(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags,
        uint256 destTokenEthPriceTimesGasPrice
    )
        internal
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

        if (!flags.check(FLAG_DISABLE_ALL_WRAP_SOURCES) == !flags.check(FLAG_DISABLE_IDLE)) {
            IIdle[8] memory tokens = _idleTokens();

            for (uint i = 0; i < tokens.length; i++) {
                if (fromToken == IERC20(tokens[i])) {
                    (returnAmount, estimateGasAmount, distribution) = _idleGetExpectedReturn(
                        tokens[i].token(),
                        destToken,
                        amount * (tokens[i].tokenPrice()) / (1e18),
                        parts,
                        flags,
                        destTokenEthPriceTimesGasPrice
                    );
                    return (returnAmount, estimateGasAmount + 2_400_000, distribution);
                }
            }

            for (uint i = 0; i < tokens.length; i++) {
                if (destToken == IERC20(tokens[i])) {
                    uint256 _destTokenEthPriceTimesGasPrice = destTokenEthPriceTimesGasPrice;
                    uint256 _price = tokens[i].tokenPrice();
                    IERC20 token = tokens[i].token();
                    (returnAmount, estimateGasAmount, distribution) = super.getExpectedReturnWithGas(
                        fromToken,
                        token,
                        amount,
                        parts,
                        flags,
                        _destTokenEthPriceTimesGasPrice * (_price) / (1e18)
                    );
                    return (returnAmount * (1e18) / (_price), estimateGasAmount + 1_300_000, distribution);
                }
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
