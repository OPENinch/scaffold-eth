// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./libraries/UniversalERC20.sol";
import "./libraries/DisableFlags.sol";
import "./OneSplitBaseWrap.sol";
import "./OneSplitMooniswapTokenBase.sol";

abstract contract OneSplitMooniswapToken is OneSplitBaseWrap, OneSplitMooniswapTokenBase {
    using SafeMath for uint256;
    using DisableFlags for uint256;

    using UniversalERC20 for IERC20;

    function _swap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256 flags
    ) virtual override internal {
        if (fromToken.eq(toToken)) {
            return;
        }

        if (!flags.check(FLAG_DISABLE_MOONISWAP_POOL_TOKEN)) {
            bool isPoolTokenFrom = mooniswapRegistry.isPool(address(fromToken));
            bool isPoolTokenTo = mooniswapRegistry.isPool(address(toToken));

            if (isPoolTokenFrom && isPoolTokenTo) {
                uint256[] memory dist = new uint256[](distribution.length);
                for (uint i = 0; i < distribution.length; i++) {
                    dist[i] = distribution[i] & ((1 << 128) - 1);
                }

                uint256 ethBalanceBefore = ETH_ADDRESS.universalBalanceOf(address(this));

                _swapFromMooniswapToken(
                    fromToken,
                    ETH_ADDRESS,
                    amount,
                    dist,
                    FLAG_DISABLE_MOONISWAP_POOL_TOKEN
                );

                for (uint i = 0; i < distribution.length; i++) {
                    dist[i] = distribution[i] >> 128;
                }

                uint256 ethBalanceAfter = ETH_ADDRESS.universalBalanceOf(address(this));

                return _swapToMooniswapToken(
                    ETH_ADDRESS,
                    toToken,
                    ethBalanceAfter - (ethBalanceBefore),
                    dist,
                    FLAG_DISABLE_MOONISWAP_POOL_TOKEN
                );
            }

            if (isPoolTokenFrom) {
                return _swapFromMooniswapToken(
                    fromToken,
                    toToken,
                    amount,
                    distribution,
                    FLAG_DISABLE_MOONISWAP_POOL_TOKEN
                );
            }

            if (isPoolTokenTo) {
                return _swapToMooniswapToken(
                    fromToken,
                    toToken,
                    amount,
                    distribution,
                    FLAG_DISABLE_MOONISWAP_POOL_TOKEN
                );
            }
        }

        return super._swap(
            fromToken,
            toToken,
            amount,
            distribution,
            flags
        );
    }

    function _swapFromMooniswapToken(
        IERC20 poolToken,
        IERC20 toToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256 flags
    ) private {
        IERC20[2] memory tokens = [
            IMooniswap(address(poolToken)).tokens(0),
            IMooniswap(address(poolToken)).tokens(1)
        ];

        IMooniswap(address(poolToken)).withdraw(
            amount,
            new uint256[](0)
        );

        uint256[] memory dist = new uint256[](distribution.length);
        for (uint i = 0; i < 2; i++) {

            if (toToken.eq(tokens[i])) {
                continue;
            }

            for (uint j = 0; j < distribution.length; j++) {
                dist[j] = (distribution[j] >> (i * 8)) & 0xFF;
            }

            super._swap(
                tokens[i],
                toToken,
                tokens[i].universalBalanceOf(address(this)),
                dist,
                flags
            );
        }
    }

    function _swapToMooniswapToken(
        IERC20 fromToken,
        IERC20 poolToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256 flags
    ) private {
        IERC20[2] memory tokens = [
            IMooniswap(address(poolToken)).tokens(0),
            IMooniswap(address(poolToken)).tokens(1)
        ];

        // will overwritten to liquidity amounts
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = amount / (2);
        amounts[1] = amount - (amounts[0]);
        uint256[] memory dist = new uint256[](distribution.length);
        for (uint i = 0; i < 2; i++) {

            if (fromToken.eq(tokens[i])) {
                continue;
            }

            for (uint j = 0; j < distribution.length; j++) {
                dist[j] = (distribution[j] >> (i * 8)) & 0xFF;
            }

            super._swap(
                fromToken,
                tokens[i],
                amounts[i],
                dist,
                flags
            );

            amounts[i] = tokens[i].universalBalanceOf(address(this));
            tokens[i].universalApprove(address(poolToken), amounts[i]);
        }

        uint256 ethValue = (tokens[0].isETH() ? amounts[0] : 0) + (tokens[1].isETH() ? amounts[1] : 0);
        IMooniswap(address(poolToken)).deposit{value: ethValue}(
            amounts,
            new uint256[](2)
        );

        for (uint i = 0; i < 2; i++) {
            tokens[i].universalTransfer(
                msg.sender,
                tokens[i].universalBalanceOf(address(this))
            );
        }
    }
}
