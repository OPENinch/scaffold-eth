// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IOneSplitView.sol";
import "./libraries/DisableFlags.sol";
import "./libraries/ChaiHelper.sol";
import "./libraries/UniversalERC20.sol";
import "./libraries/OneSplitCalculate.sol";
import "./OneSplitRoot.sol";
import "hardhat/console.sol";


contract OneSplitView is IOneSplitView, OneSplitRoot {
    using SafeMath for uint256;
    using DisableFlags for uint256;

    using UniversalERC20 for IERC20;

    using ChaiHelper for IChai;

    function getExpectedReturn(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags // See constants in IOneSplit.sol
    ) override
        public
        view
        returns(
            uint256 returnAmount,
            uint256[] memory distribution
        )
    {
        (returnAmount, , distribution) = getExpectedReturnWithGas(
            fromToken,
            destToken,
            amount,
            parts,
            flags,
            0
        );
    }

    function getExpectedReturnWithGas(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags, // See constants in IOneSplit.sol
        uint256 destTokenEthPriceTimesGasPrice
    ) override
        public
        view
        returns(
            uint256 returnAmount,
            uint256 estimateGasAmount,
            uint256[] memory distribution
        )
    {
        distribution = new uint256[](DEXES_COUNT);

        if (fromToken == destToken) {
            return (amount, 0, distribution);
        }

        function(IERC20,IERC20,uint256,uint256,uint256) view returns(uint256[] memory, uint256)[DEXES_COUNT] memory reserves = _getAllReserves(flags);

        int256[][] memory matrix = new int256[][](DEXES_COUNT);
        uint256[DEXES_COUNT] memory gases;
        bool atLeastOnePositive = false;
        for (uint i = 0; i < DEXES_COUNT; i++) {
            uint256[] memory rets;
            (rets, gases[i]) = reserves[i](fromToken, destToken, amount, parts, flags);

            // Prepend zero and sub gas
            int256 gas = int256(gases[i].mul(destTokenEthPriceTimesGasPrice).div(1e18));
            matrix[i] = new int256[](parts + 1);
            for (uint j = 0; j < rets.length; j++) {
                matrix[i][j + 1] = int256(rets[j]) - gas;
                atLeastOnePositive = atLeastOnePositive || (matrix[i][j + 1] > 0);
            }
        }

        if (!atLeastOnePositive) {
            for (uint i = 0; i < DEXES_COUNT; i++) {
                for (uint j = 1; j < parts + 1; j++) {
                    if (matrix[i][j] == 0) {
                        matrix[i][j] = VERY_NEGATIVE_VALUE;
                    }
                }
            }
        }

        (, distribution) = _findBestDistribution(parts, matrix);

        (returnAmount, estimateGasAmount) = _getReturnAndGasByDistribution(
            Args({
                fromToken: fromToken,
                destToken: destToken,
                amount: amount,
                parts: parts,
                flags: flags,
                destTokenEthPriceTimesGasPrice: destTokenEthPriceTimesGasPrice,
                distribution: distribution,
                matrix: matrix,
                gases: gases,
                reserves: reserves
            })
        );
        return (returnAmount, estimateGasAmount, distribution);
    }

    struct Args {
        IERC20 fromToken;
        IERC20 destToken;
        uint256 amount;
        uint256 parts;
        uint256 flags;
        uint256 destTokenEthPriceTimesGasPrice;
        uint256[] distribution;
        int256[][] matrix;
        uint256[DEXES_COUNT] gases;
        function(IERC20,IERC20,uint256,uint256,uint256) view returns(uint256[] memory, uint256)[DEXES_COUNT] reserves;
    }

    function _getReturnAndGasByDistribution(
        Args memory args
    ) internal view returns(uint256 returnAmount, uint256 estimateGasAmount) {
        bool[DEXES_COUNT] memory exact = [
            true,  // "Uniswap",
            false, // "Bancor",
            true,  // "Curve Compound",
            true,  // "Curve USDT",
            true,  // "Curve Y",
            true,  // "Curve Binance",
            true,  // "Curve Synthetix",
            true,  // "Uniswap Compound",
            true,  // "Uniswap CHAI",
            true,  // "Uniswap Aave",
            true,  // "Uniswap V2",
            true,  // "Uniswap V2 (ETH)",
            true,  // "Uniswap V2 (DAI)",
            true,  // "Uniswap V2 (USDC)",
            true,  // "Curve Pax",
            true,  // "Curve RenBTC",
            true,  // "Curve tBTC",
            false, // "Shell",
            true,  // "mStable",
            true,  // "Curve sBTC"
            true,  // "Balancer 1"
            true,  // "Balancer 2"
            true   // "Balancer 3"
        ];

        for (uint i = 0; i < DEXES_COUNT; i++) {
            if (args.distribution[i] > 0) {
                if (args.distribution[i] == args.parts || exact[i] || args.flags.check(FLAG_DISABLE_SPLIT_RECALCULATION)) {
                    estimateGasAmount = estimateGasAmount + (args.gases[i]);
                    int256 value = args.matrix[i][args.distribution[i]];
                    returnAmount = returnAmount.add(uint256(
                        int256(value == VERY_NEGATIVE_VALUE ? int256(0) : value) +
                        int256(args.gases[i].mul(args.destTokenEthPriceTimesGasPrice).div(1e18))
                    ));
                }
                else {
                    (uint256[] memory rets, uint256 gas) = args.reserves[i](args.fromToken, args.destToken, args.amount * args.distribution[i] / args.parts, 1, args.flags);
                    estimateGasAmount = estimateGasAmount + gas;
                    returnAmount = returnAmount + rets[0];
                }
            }
        }
    }

    function _getAllReserves(uint256 flags)
        internal
        //pure
        view
        returns(function(IERC20,IERC20,uint256,uint256,uint256) view returns(uint256[] memory, uint256)[DEXES_COUNT] memory)
    {
        bool invert = flags.check(FLAG_DISABLE_ALL_SPLIT_SOURCES);

        return [
            invert != flags.check(FLAG_DISABLE_UNISWAP_ALL | FLAG_DISABLE_UNISWAP)            ? Calculate._NoReturn : Calculate.Uniswap,
            invert != flags.check(FLAG_DISABLE_BANCOR)                                        ? Calculate._NoReturn : Calculate.Bancor,
            invert != flags.check(FLAG_DISABLE_CURVE_ALL | FLAG_DISABLE_CURVE_COMPOUND)       ? Calculate._NoReturn : Calculate.CurveCompound,
            invert != flags.check(FLAG_DISABLE_CURVE_ALL | FLAG_DISABLE_CURVE_USDT)           ? Calculate._NoReturn : Calculate.CurveUSDT,
            invert != flags.check(FLAG_DISABLE_CURVE_ALL | FLAG_DISABLE_CURVE_Y)              ? Calculate._NoReturn : Calculate.CurveY,
            invert != flags.check(FLAG_DISABLE_CURVE_ALL | FLAG_DISABLE_CURVE_BINANCE)        ? Calculate._NoReturn : Calculate.CurveBinance,
            invert != flags.check(FLAG_DISABLE_CURVE_ALL | FLAG_DISABLE_CURVE_SYNTHETIX)      ? Calculate._NoReturn : Calculate.CurveSynthetix,
            invert != flags.check(FLAG_DISABLE_UNISWAP_ALL | FLAG_DISABLE_UNISWAP_COMPOUND)   ? Calculate._NoReturn : Calculate.UniswapCompound,
            invert != flags.check(FLAG_DISABLE_UNISWAP_ALL | FLAG_DISABLE_UNISWAP_CHAI)       ? Calculate._NoReturn : Calculate.UniswapChai,
            invert != flags.check(FLAG_DISABLE_UNISWAP_ALL | FLAG_DISABLE_UNISWAP_AAVE)       ? Calculate._NoReturn : Calculate.UniswapAave,
            invert != flags.check(FLAG_DISABLE_UNISWAP_V2_ALL | FLAG_DISABLE_UNISWAP_V2)      ? Calculate._NoReturn : Calculate.UniswapV2,
            invert != flags.check(FLAG_DISABLE_UNISWAP_V2_ALL | FLAG_DISABLE_UNISWAP_V2_ETH)  ? Calculate._NoReturn : Calculate.UniswapV2ETH,
            invert != flags.check(FLAG_DISABLE_UNISWAP_V2_ALL | FLAG_DISABLE_UNISWAP_V2_DAI)  ? Calculate._NoReturn : Calculate.UniswapV2DAI,
            invert != flags.check(FLAG_DISABLE_UNISWAP_V2_ALL | FLAG_DISABLE_UNISWAP_V2_USDC) ? Calculate._NoReturn : Calculate.UniswapV2USDC,
            invert != flags.check(FLAG_DISABLE_CURVE_ALL | FLAG_DISABLE_CURVE_PAX)            ? Calculate._NoReturn : Calculate.CurvePAX,
            invert != flags.check(FLAG_DISABLE_CURVE_ALL | FLAG_DISABLE_CURVE_RENBTC)         ? Calculate._NoReturn : Calculate.CurveRenBTC,
            invert != flags.check(FLAG_DISABLE_CURVE_ALL | FLAG_DISABLE_CURVE_TBTC)           ? Calculate._NoReturn : Calculate.CurveTBTC,
            invert != flags.check(FLAG_DISABLE_SHELL)                                         ? Calculate._NoReturn : Calculate.Shell,
            invert != flags.check(FLAG_DISABLE_MSTABLE_MUSD)                                  ? Calculate._NoReturn : Calculate.MStableMUSD,
            invert != flags.check(FLAG_DISABLE_CURVE_ALL | FLAG_DISABLE_CURVE_SBTC)           ? Calculate._NoReturn : Calculate.CurveSBTC,
            invert != flags.check(FLAG_DISABLE_BALANCER_ALL | FLAG_DISABLE_BALANCER_1)        ? Calculate._NoReturn : Calculate.Balancer1,
            invert != flags.check(FLAG_DISABLE_BALANCER_ALL | FLAG_DISABLE_BALANCER_2)        ? Calculate._NoReturn : Calculate.Balancer2,
            invert != flags.check(FLAG_DISABLE_BALANCER_ALL | FLAG_DISABLE_BALANCER_3)        ? Calculate._NoReturn : Calculate.Balancer3
        ];
    }

    // View Helpers

    struct Balances {
        uint256 src;
        uint256 dst;
    }
}
