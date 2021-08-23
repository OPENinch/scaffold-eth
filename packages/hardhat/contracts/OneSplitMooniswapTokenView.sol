// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IMooniswap.sol";
import "./libraries/UniversalERC20.sol";
import "./libraries/DisableFlags.sol";
import "./OneSplitViewWrapBase.sol";
import "./OneSplitMooniswapTokenBase.sol";

abstract contract OneSplitMooniswapTokenView is OneSplitViewWrapBase, OneSplitMooniswapTokenBase {
    using SafeMath for uint256;
    using DisableFlags for uint256;
    using UniversalERC20 for IERC20;

    function getExpectedReturnWithGas(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 parts,
        uint256 flags,
        uint256 destTokenEthPriceTimesGasPrice
    ) virtual override
        public
        view
        returns (
            uint256 returnAmount,
            uint256,
            uint256[] memory distribution
        )
    {
        if (fromToken.eq(toToken)) {
            return (amount, 0, new uint256[](DEXES_COUNT));
        }


        if (!flags.check(FLAG_DISABLE_MOONISWAP_POOL_TOKEN)) {
            bool isPoolTokenFrom = mooniswapRegistry.isPool(address(fromToken));
            bool isPoolTokenTo = mooniswapRegistry.isPool(address(toToken));

            if (isPoolTokenFrom && isPoolTokenTo) {
                (
                    uint256 returnETHAmount,
                    uint256[] memory poolTokenFromDistribution
                ) = _getExpectedReturnFromMooniswapPoolToken(
                    fromToken,
                    ETH_ADDRESS,
                    amount,
                    parts,
                    FLAG_DISABLE_MOONISWAP_POOL_TOKEN
                );

                (
                    uint256 returnPoolTokenToAmount,
                    uint256[] memory poolTokenToDistribution
                ) = _getExpectedReturnToMooniswapPoolToken(
                    ETH_ADDRESS,
                    toToken,
                    returnETHAmount,
                    parts,
                    FLAG_DISABLE_MOONISWAP_POOL_TOKEN
                );

                for (uint i = 0; i < poolTokenToDistribution.length; i++) {
                    poolTokenFromDistribution[i] |= poolTokenToDistribution[i] << 128;
                }

                return (returnPoolTokenToAmount, 0, poolTokenFromDistribution);
            }

            if (isPoolTokenFrom) {
                (returnAmount, distribution) = _getExpectedReturnFromMooniswapPoolToken(
                    fromToken,
                    toToken,
                    amount,
                    parts,
                    FLAG_DISABLE_MOONISWAP_POOL_TOKEN
                );
                return (returnAmount, 0, distribution);
            }

            if (isPoolTokenTo) {
                (returnAmount, distribution) = _getExpectedReturnToMooniswapPoolToken(
                    fromToken,
                    toToken,
                    amount,
                    parts,
                    FLAG_DISABLE_MOONISWAP_POOL_TOKEN
                );
                return (returnAmount, 0, distribution);
            }
        }

        return super.getExpectedReturnWithGas(
            fromToken,
            toToken,
            amount,
            parts,
            flags,
            destTokenEthPriceTimesGasPrice
        );
    }

    function _getExpectedReturnFromMooniswapPoolToken(
        IERC20 poolToken,
        IERC20 toToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    )
        private
        view
        returns(
            uint256 returnAmount,
            uint256[] memory distribution
        )
    {
        distribution = new uint256[](DEXES_COUNT);

        PoolDetails memory details = _getPoolDetails(IMooniswap(address(poolToken)));

        for (uint i = 0; i < 2; i++) {

            uint256 exchangeAmount = amount
                 * (details.tokens[i].reserve)
                 / (details.totalSupply);

            if (toToken.eq(details.tokens[i].token)) {
                returnAmount = returnAmount + (exchangeAmount);
                continue;
            }

            (uint256 ret, ,uint256[] memory dist) = super.getExpectedReturnWithGas(
                details.tokens[i].token,
                toToken,
                exchangeAmount,
                parts,
                flags,
                0
            );

            returnAmount = returnAmount + (ret);
            for (uint j = 0; j < distribution.length; j++) {
                distribution[j] |= dist[j] << (i * 8);
            }
        }

        return (returnAmount, distribution);
    }

    function _getExpectedReturnToMooniswapPoolToken(
        IERC20 fromToken,
        IERC20 poolToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    )
        private
        view
        returns(
            uint256 returnAmount,
            uint256[] memory distribution
        )
    {
        distribution = new uint256[](DEXES_COUNT);

        PoolDetails memory details = _getPoolDetails(IMooniswap(address(poolToken)));

        // will overwritten to liquidity amounts
        uint256[2] memory amounts;
        amounts[0] = amount / (2);
        amounts[1] = amount - (amounts[0]);
        uint256[] memory dist = new uint256[](distribution.length);
        for (uint i = 0; i < 2; i++) {

            if (fromToken.eq(details.tokens[i].token)) {
                continue;
            }

            (amounts[i], ,dist) = super.getExpectedReturnWithGas(
                fromToken,
                details.tokens[i].token,
                amounts[i],
                parts,
                flags,
                0
            );

            for (uint j = 0; j < distribution.length; j++) {
                distribution[j] |= dist[j] << (i * 8);
            }
        }

        returnAmount = uint256(0);
        for (uint i = 0; i < 2; i++) {
            returnAmount = Math.min(
                returnAmount,
                details.totalSupply * (amounts[i]) / (details.tokens[i].reserve)
            );
        }

        return (
            returnAmount,
            distribution
        );
    }
}

