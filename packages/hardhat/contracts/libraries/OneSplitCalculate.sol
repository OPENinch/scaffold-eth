// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IOneSplitView.sol";
import "../interfaces/ICurve.sol";
import "../OneSplitWethView.sol";
import "./UniversalERC20.sol";
import "./ChaiHelper.sol";

library Calculate {
    using UniversalERC20 for IERC20;
    using ChaiHelper for IChai;

    uint256 internal constant DEXES_COUNT = 23;
    IERC20 internal constant ETH_ADDRESS =
        IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    IERC20 internal constant ZERO_ADDRESS =
        IERC20(0x0000000000000000000000000000000000000000);

    IUniswapFactory internal constant uniswapFactory =
        IUniswapFactory(0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95);
    IBancorContractRegistry internal constant bancorContractRegistry =
        IBancorContractRegistry(0x52Ae12ABe5D8BD778BD5397F99cA900624CfADD4);
    IBancorNetworkPathFinder internal constant bancorNetworkPathFinder =
        IBancorNetworkPathFinder(0x6F0cD8C4f6F06eAB664C7E3031909452b4B72861);
    //IBancorConverterRegistry constant internal bancorConverterRegistry = IBancorConverterRegistry(0xf6E2D7F616B67E46D708e4410746E9AAb3a4C518);
    IBancorFinder internal constant bancorFinder =
        IBancorFinder(0x2B344e14dc2641D11D338C053C908c7A7D4c30B9);
    ICurve internal constant curveCompound =
        ICurve(0xA2B47E3D5c44877cca798226B7B8118F9BFb7A56);
    ICurve internal constant curveUSDT =
        ICurve(0x52EA46506B9CC5Ef470C5bf89f17Dc28bB35D85C);
    ICurve internal constant curveY =
        ICurve(0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51);
    ICurve internal constant curveBinance =
        ICurve(0x79a8C46DeA5aDa233ABaFFD40F3A0A2B1e5A4F27);
    ICurve internal constant curveSynthetix =
        ICurve(0xA5407eAE9Ba41422680e2e00537571bcC53efBfD);
    ICurve internal constant curvePAX =
        ICurve(0x06364f10B501e868329afBc005b3492902d6C763);
    ICurve internal constant curveRenBTC =
        ICurve(0x93054188d876f558f4a66B2EF1d97d16eDf0895B);
    ICurve internal constant curveTBTC =
        ICurve(0x9726e9314eF1b96E45f40056bEd61A088897313E);
    ICurve internal constant curveSBTC =
        ICurve(0x7fC77b5c7614E1533320Ea6DDc2Eb61fa00A9714);
    IShell internal constant shell =
        IShell(0xA8253a440Be331dC4a7395B73948cCa6F19Dc97D);
    IAaveLendingPool internal constant aave =
        IAaveLendingPool(0x398eC7346DcD622eDc5ae82352F02bE94C62d119);
    ICompound internal constant compound =
        ICompound(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);
    ICompoundEther internal constant cETH =
        ICompoundEther(0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5);
    IUniswapV2Factory internal constant uniswapV2 =
        IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    IMStable internal constant musd =
        IMStable(0xe2f2a5C287993345a840Db3B0845fbC70f5935a5);
    IMassetValidationHelper internal constant musd_helper =
        IMassetValidationHelper(0xaBcC93c3be238884cc3309C19Afd128fAfC16911);
    IBalancerRegistry internal constant balancerRegistry =
        IBalancerRegistry(0x65e67cbc342712DF67494ACEfc06fe951EE93982);
    ICurveCalculator internal constant curveCalculator =
        ICurveCalculator(0xc1DB00a8E5Ef7bfa476395cdbcc98235477cDE4E);
    ICurveRegistry internal constant curveRegistry =
        ICurveRegistry(0x7002B727Ef8F5571Cb5F9D70D13DBEEb4dFAe9d1);
    ICompoundRegistry internal constant compoundRegistry =
        ICompoundRegistry(0xF451Dbd7Ba14BFa7B1B78A766D3Ed438F79EE1D1);
    IAaveRegistry internal constant aaveRegistry =
        IAaveRegistry(0xEd8b133B7B88366E01Bb9E38305Ab11c26521494);
    IBalancerHelper internal constant balancerHelper =
        IBalancerHelper(0xA961672E8Db773be387e775bc4937C678F3ddF9a);

    IBancorEtherToken internal constant bancorEtherToken =
        IBancorEtherToken(0xc0829421C1d260BD3cB3E0F06cfE2D52db2cE315);
    IWETH internal constant weth =
        IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IChai internal constant chai =
        IChai(0x06AF07097C9Eeb7fD685c692751D5C66dB49c215);
    IERC20 internal constant dai =
        IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IERC20 internal constant usdc =
        IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20 internal constant usdt =
        IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    IERC20 internal constant tusd =
        IERC20(0x0000000000085d4780B73119b644AE5ecd22b376);
    IERC20 internal constant busd =
        IERC20(0x4Fabb145d64652a948d72533023f6E7A623C7C53);
    IERC20 internal constant susd =
        IERC20(0x57Ab1ec28D129707052df4dF418D58a2D46d5f51);
    IERC20 internal constant pax =
        IERC20(0x8E870D67F660D95d5be530380D0eC0bd388289E1);
    IERC20 internal constant renbtc =
        IERC20(0xEB4C2781e4ebA804CE9a9803C67d0893436bB27D);
    IERC20 internal constant wbtc =
        IERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
    IERC20 internal constant tbtc =
        IERC20(0x1bBE271d15Bb64dF0bc6CD28Df9Ff322F2eBD847);
    IERC20 internal constant hbtc =
        IERC20(0x0316EB71485b0Ab14103307bf65a021042c6d380);
    IERC20 internal constant sbtc =
        IERC20(0xfE18be6b3Bd88A2D2A7f928d00292E7a9963CfC6);

    function _linearInterpolation(uint256 value, uint256 parts)
        internal
        pure
        returns (uint256[] memory rets)
    {
        rets = new uint256[](parts);
        for (uint256 i = 0; i < parts; i++) {
            rets[i] = (value * (i + 1)) / (parts);
        }
    }

    function _Balancer(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 poolIndex
    ) internal view returns (uint256[] memory rets, uint256 gas) {
        address[] memory pools = balancerRegistry.getBestPoolsWithLimit(
            address(fromToken.isETH() ? weth : fromToken),
            address(destToken.isETH() ? weth : destToken),
            poolIndex + 1
        );
        if (poolIndex >= pools.length) {
            return (new uint256[](parts), 0);
        }

        rets = balancerHelper.getReturns(
            IBalancerPool(pools[poolIndex]),
            fromToken.isETH() ? weth : fromToken,
            destToken.isETH() ? weth : destToken,
            _linearInterpolation(amount, parts)
        );
        gas = 75_000 + (fromToken.isETH() || destToken.isETH() ? 0 : 65_000);
    }

    function Balancer1(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 /*flags*/
    ) internal view returns (uint256[] memory rets, uint256 gas) {
        return _Balancer(fromToken, destToken, amount, parts, 0);
    }

    function Balancer2(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 /*flags*/
    ) internal view returns (uint256[] memory rets, uint256 gas) {
        return _Balancer(fromToken, destToken, amount, parts, 1);
    }

    function Balancer3(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 /*flags*/
    ) internal view returns (uint256[] memory rets, uint256 gas) {
        return _Balancer(fromToken, destToken, amount, parts, 2);
    }

    function MStableMUSD(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 /*flags*/
    ) internal view returns (uint256[] memory rets, uint256 gas) {
        rets = new uint256[](parts);

        if (
            (fromToken != usdc &&
                fromToken != dai &&
                fromToken != usdt &&
                fromToken != tusd) ||
            (destToken != usdc &&
                destToken != dai &&
                destToken != usdt &&
                destToken != tusd)
        ) {
            return (rets, 0);
        }

        for (uint256 i = 1; i <= parts; i *= 2) {
            (bool success, bytes memory data) = address(musd).staticcall(
                abi.encodeWithSelector(
                    musd.getSwapOutput.selector,
                    fromToken,
                    destToken,
                    (amount * (parts / i)) / (parts)
                )
            );

            if (success && data.length > 0) {
                (, , uint256 maxRet) = abi.decode(
                    data,
                    (bool, string, uint256)
                );
                if (maxRet > 0) {
                    for (uint256 j = 0; j < parts / i; j++) {
                        rets[j] = (maxRet * (j + 1)) / (parts / (i));
                    }
                    break;
                }
            }
        }

        return (rets, 700_000);
    }

    function _getCurvePoolInfo(ICurve curve, bool haveUnderlying)
        internal
        view
        returns (
            uint256[8] memory balances,
            uint256[8] memory precisions,
            uint256[8] memory rates,
            uint256 amp,
            uint256 fee
        )
    {
        uint256[8] memory underlying_balances;
        uint256[8] memory decimals;
        uint256[8] memory underlying_decimals;

        (
            balances,
            underlying_balances,
            decimals,
            underlying_decimals,
            ,
            /*address lp_token*/
            amp,
            fee
        ) = curveRegistry.get_pool_info(address(curve));

        for (uint256 k = 0; k < 8 && balances[k] > 0; k++) {
            precisions[k] =
                10**(18 - (haveUnderlying ? underlying_decimals : decimals)[k]);
            if (haveUnderlying) {
                rates[k] = (underlying_balances[k] * 1e18) / (balances[k]);
            } else {
                rates[k] = 1e18;
            }
        }
    }

    function _CurveSelector(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        ICurve curve,
        bool haveUnderlying,
        IERC20[] memory tokens
    ) internal view returns (uint256[] memory rets) {
        rets = new uint256[](parts);

        uint256 i = 0;
        uint256 j = 0;
        for (uint256 t = 0; t < tokens.length; t++) {
            if (fromToken == tokens[t]) {
                i = uint256(t + 1);
            }
            if (destToken == tokens[t]) {
                j = uint256(t + 1);
            }
        }

        if (i == 0 || j == 0) {
            return rets;
        }

        bytes memory data = abi.encodePacked(
            uint256(haveUnderlying ? 1 : 0),
            uint256(i - 1),
            uint256(j - 1),
            _linearInterpolation100(amount, parts)
        );

        (
            uint256[8] memory balances,
            uint256[8] memory precisions,
            uint256[8] memory rates,
            uint256 amp,
            uint256 fee
        ) = _getCurvePoolInfo(curve, haveUnderlying);

        bool success;
        (success, data) = address(curveCalculator).staticcall(
            abi.encodePacked(
                abi.encodeWithSelector(
                    curveCalculator.get_dy.selector,
                    tokens.length,
                    balances,
                    amp,
                    fee,
                    rates,
                    precisions
                ),
                data
            )
        );

        if (!success || data.length == 0) {
            return rets;
        }

        uint256[100] memory dy = abi.decode(data, (uint256[100]));
        for (uint256 t = 0; t < parts; t++) {
            rets[t] = dy[t];
        }
    }

    function _linearInterpolation100(uint256 value, uint256 parts)
        internal
        pure
        returns (uint256[100] memory rets)
    {
        for (uint256 i = 0; i < parts; i++) {
            rets[i] = (value * (i + 1)) / (parts);
        }
    }

    function CurveCompound(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 /*flags*/
    ) internal view returns (uint256[] memory rets, uint256 gas) {
        IERC20[] memory tokens = new IERC20[](2);
        tokens[0] = dai;
        tokens[1] = usdc;
        return (
            _CurveSelector(
                fromToken,
                destToken,
                amount,
                parts,
                curveCompound,
                true,
                tokens
            ),
            720_000
        );
    }

    function CurveUSDT(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 /*flags*/
    ) internal view returns (uint256[] memory rets, uint256 gas) {
        IERC20[] memory tokens = new IERC20[](3);
        tokens[0] = dai;
        tokens[1] = usdc;
        tokens[2] = usdt;
        return (
            _CurveSelector(
                fromToken,
                destToken,
                amount,
                parts,
                curveUSDT,
                true,
                tokens
            ),
            720_000
        );
    }

    function CurveY(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 /*flags*/
    ) internal view returns (uint256[] memory rets, uint256 gas) {
        IERC20[] memory tokens = new IERC20[](4);
        tokens[0] = dai;
        tokens[1] = usdc;
        tokens[2] = usdt;
        tokens[3] = tusd;
        return (
            _CurveSelector(
                fromToken,
                destToken,
                amount,
                parts,
                curveY,
                true,
                tokens
            ),
            1_400_000
        );
    }

    function CurveBinance(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 /*flags*/
    ) internal view returns (uint256[] memory rets, uint256 gas) {
        IERC20[] memory tokens = new IERC20[](4);
        tokens[0] = dai;
        tokens[1] = usdc;
        tokens[2] = usdt;
        tokens[3] = busd;
        return (
            _CurveSelector(
                fromToken,
                destToken,
                amount,
                parts,
                curveBinance,
                true,
                tokens
            ),
            1_400_000
        );
    }

    function CurveSynthetix(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 /*flags*/
    ) internal view returns (uint256[] memory rets, uint256 gas) {
        IERC20[] memory tokens = new IERC20[](4);
        tokens[0] = dai;
        tokens[1] = usdc;
        tokens[2] = usdt;
        tokens[3] = susd;
        return (
            _CurveSelector(
                fromToken,
                destToken,
                amount,
                parts,
                curveSynthetix,
                true,
                tokens
            ),
            200_000
        );
    }

    function CurvePAX(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 /*flags*/
    ) internal view returns (uint256[] memory rets, uint256 gas) {
        IERC20[] memory tokens = new IERC20[](4);
        tokens[0] = dai;
        tokens[1] = usdc;
        tokens[2] = usdt;
        tokens[3] = pax;
        return (
            _CurveSelector(
                fromToken,
                destToken,
                amount,
                parts,
                curvePAX,
                true,
                tokens
            ),
            1_000_000
        );
    }

    function CurveRenBTC(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 /*flags*/
    ) internal view returns (uint256[] memory rets, uint256 gas) {
        IERC20[] memory tokens = new IERC20[](2);
        tokens[0] = renbtc;
        tokens[1] = wbtc;
        return (
            _CurveSelector(
                fromToken,
                destToken,
                amount,
                parts,
                curveRenBTC,
                false,
                tokens
            ),
            130_000
        );
    }

    function CurveTBTC(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 /*flags*/
    ) internal view returns (uint256[] memory rets, uint256 gas) {
        IERC20[] memory tokens = new IERC20[](3);
        tokens[0] = tbtc;
        tokens[1] = wbtc;
        tokens[2] = hbtc;
        return (
            _CurveSelector(
                fromToken,
                destToken,
                amount,
                parts,
                curveTBTC,
                false,
                tokens
            ),
            145_000
        );
    }

    function CurveSBTC(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 /*flags*/
    ) internal view returns (uint256[] memory rets, uint256 gas) {
        IERC20[] memory tokens = new IERC20[](3);
        tokens[0] = renbtc;
        tokens[1] = wbtc;
        tokens[2] = sbtc;
        return (
            _CurveSelector(
                fromToken,
                destToken,
                amount,
                parts,
                curveSBTC,
                false,
                tokens
            ),
            150_000
        );
    }

    function Shell(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 /*flags*/
    ) internal view returns (uint256[] memory rets, uint256 gas) {
        (bool success, bytes memory data) = address(shell).staticcall(
            abi.encodeWithSelector(
                shell.viewOriginTrade.selector,
                fromToken,
                destToken,
                amount
            )
        );

        if (!success || data.length == 0) {
            return (new uint256[](parts), 0);
        }

        uint256 maxRet = abi.decode(data, (uint256));
        return (_linearInterpolation(maxRet, parts), 300_000);
    }

    function _UniswapFormula(
        uint256 fromBalance,
        uint256 toBalance,
        uint256 amount
    ) internal pure returns (uint256) {
        if (amount == 0) {
            return 0;
        }
        return
            (amount * (toBalance) * (997)) /
            (fromBalance * (1000) + (amount * (997)));
    }

    function _Uniswap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256[] memory amounts,
        uint256 /*flags*/
    ) internal view returns (uint256[] memory rets, uint256 gas) {
        rets = amounts;

        if (!fromToken.isETH()) {
            IUniswapExchange fromExchange = uniswapFactory.getExchange(
                fromToken
            );
            if (fromExchange == IUniswapExchange(address(0))) {
                return (new uint256[](rets.length), 0);
            }

            uint256 fromTokenBalance = fromToken.universalBalanceOf(
                address(fromExchange)
            );
            uint256 fromEtherBalance = address(fromExchange).balance;

            for (uint256 i = 0; i < rets.length; i++) {
                rets[i] = _UniswapFormula(
                    fromTokenBalance,
                    fromEtherBalance,
                    rets[i]
                );
            }
        }

        if (!destToken.isETH()) {
            IUniswapExchange toExchange = uniswapFactory.getExchange(destToken);
            if (toExchange == IUniswapExchange(address(0))) {
                return (new uint256[](rets.length), 0);
            }

            uint256 toEtherBalance = address(toExchange).balance;
            uint256 toTokenBalance = destToken.universalBalanceOf(
                address(toExchange)
            );

            for (uint256 i = 0; i < rets.length; i++) {
                rets[i] = _UniswapFormula(
                    toEtherBalance,
                    toTokenBalance,
                    rets[i]
                );
            }
        }

        return (
            rets,
            fromToken.isETH() || destToken.isETH() ? 60_000 : 100_000
        );
    }

    function Uniswap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    ) internal view returns (uint256[] memory rets, uint256 gas) {
        return
            _Uniswap(
                fromToken,
                destToken,
                _linearInterpolation(amount, parts),
                flags
            );
    }

    function _UniswapWrapped(
        IERC20 fromToken,
        IERC20 midToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 midTokenPrice,
        uint256 flags,
        uint256 gas1,
        uint256 gas2
    ) internal view returns (uint256[] memory rets, uint256 gas) {
        if (!fromToken.isETH() && destToken.isETH()) {
            (rets, gas) = _Uniswap(
                midToken,
                destToken,
                _linearInterpolation(
                    (amount * (1e18)) / (midTokenPrice),
                    parts
                ),
                flags
            );
            return (rets, gas + gas1);
        } else if (fromToken.isETH() && !destToken.isETH()) {
            (rets, gas) = _Uniswap(
                fromToken,
                midToken,
                _linearInterpolation(amount, parts),
                flags
            );

            for (uint256 i = 0; i < parts; i++) {
                rets[i] = (rets[i] * (midTokenPrice)) / (1e18);
            }
            return (rets, gas + gas2);
        }

        return (new uint256[](parts), 0);
    }

    function UniswapCompound(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    ) internal view returns (uint256[] memory rets, uint256 gas) {
        IERC20 midPreToken;
        if (!fromToken.isETH() && destToken.isETH()) {
            midPreToken = fromToken;
        } else if (!destToken.isETH() && fromToken.isETH()) {
            midPreToken = destToken;
        }

        if (!midPreToken.isETH()) {
            ICompoundToken midToken = compoundRegistry.cTokenByToken(
                midPreToken
            );
            if (midToken != ICompoundToken(address(0))) {
                return
                    _UniswapWrapped(
                        fromToken,
                        midToken,
                        destToken,
                        amount,
                        parts,
                        midToken.exchangeRateStored(),
                        flags,
                        200_000,
                        200_000
                    );
            }
        }

        return (new uint256[](parts), 0);
    }

    function UniswapChai(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    ) internal view returns (uint256[] memory rets, uint256 gas) {
        if (
            (fromToken == dai && destToken.isETH()) ||
            (fromToken.isETH() && destToken == dai)
        ) {
            return
                _UniswapWrapped(
                    fromToken,
                    chai,
                    destToken,
                    amount,
                    parts,
                    chai.chaiPrice(),
                    flags,
                    180_000,
                    160_000
                );
        }

        return (new uint256[](parts), 0);
    }

    function UniswapAave(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    ) internal view returns (uint256[] memory rets, uint256 gas) {
        IERC20 midPreToken;
        if (!fromToken.isETH() && destToken.isETH()) {
            midPreToken = fromToken;
        } else if (!destToken.isETH() && fromToken.isETH()) {
            midPreToken = destToken;
        }

        if (!midPreToken.isETH()) {
            IAaveToken midToken = aaveRegistry.aTokenByToken(midPreToken);
            if (midToken != IAaveToken(address(0))) {
                return
                    _UniswapWrapped(
                        fromToken,
                        midToken,
                        destToken,
                        amount,
                        parts,
                        1e18,
                        flags,
                        310_000,
                        670_000
                    );
            }
        }

        return (new uint256[](parts), 0);
    }

    function Bancor(
        IERC20, /*fromToken*/
        IERC20, /*destToken*/
        uint256, /*amount*/
        uint256 parts,
        uint256 /*flags*/
    ) internal pure returns (uint256[] memory rets, uint256 gas) {
        return (new uint256[](parts), 0);
        // IBancorNetwork bancorNetwork = IBancorNetwork(bancorContractRegistry.addressOf("BancorNetwork"));

        // address[] memory path = bancorFinder.buildBancorPath(
        //     fromToken.isETH() ? bancorEtherToken : fromToken,
        //     destToken.isETH() ? bancorEtherToken : destToken
        // );

        // rets = _linearInterpolation(amount, parts);
        // for (uint i = 0; i < parts; i++) {
        //     (bool success, bytes memory data) = address(bancorNetwork).staticcall.gas(500000)(
        //         abi.encodeWithSelector(
        //             bancorNetwork.getReturnByPath.selector,
        //             path,
        //             rets[i]
        //         )
        //     );
        //     if (!success || data.length == 0) {
        //         for (; i < parts; i++) {
        //             rets[i] = 0;
        //         }
        //         break;
        //     } else {
        //         (uint256 ret,) = abi.decode(data, (uint256,uint256));
        //         rets[i] = ret;
        //     }
        // }

        // return (rets, path.length * (150_000));
    }

    function UniswapV2(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    ) internal view returns (uint256[] memory rets, uint256 gas) {
        return
            _UniswapV2(
                fromToken,
                destToken,
                _linearInterpolation(amount, parts),
                flags
            );
    }

    function UniswapV2ETH(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    ) internal view returns (uint256[] memory rets, uint256 gas) {
        if (
            fromToken.isETH() ||
            fromToken == weth ||
            destToken.isETH() ||
            destToken == weth
        ) {
            return (new uint256[](parts), 0);
        }

        return
            _UniswapV2OverMidToken(
                fromToken,
                weth,
                destToken,
                amount,
                parts,
                flags
            );
    }

    function UniswapV2DAI(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    ) internal view returns (uint256[] memory rets, uint256 gas) {
        if (fromToken == dai || destToken == dai) {
            return (new uint256[](parts), 0);
        }

        return
            _UniswapV2OverMidToken(
                fromToken,
                dai,
                destToken,
                amount,
                parts,
                flags
            );
    }

    function UniswapV2USDC(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    ) internal view returns (uint256[] memory rets, uint256 gas) {
        if (fromToken == usdc || destToken == usdc) {
            return (new uint256[](parts), 0);
        }

        return
            _UniswapV2OverMidToken(
                fromToken,
                usdc,
                destToken,
                amount,
                parts,
                flags
            );
    }

    function _UniswapV2(
        IERC20 fromToken,
        IERC20 destToken,
        uint256[] memory amounts,
        uint256 /*flags*/
    ) internal view returns (uint256[] memory rets, uint256 gas) {
        rets = new uint256[](amounts.length);

        IERC20 fromTokenReal = fromToken.isETH() ? weth : fromToken;
        IERC20 destTokenReal = destToken.isETH() ? weth : destToken;
        IUniswapV2Exchange exchange = uniswapV2.getPair(
            fromTokenReal,
            destTokenReal
        );
        if (exchange != IUniswapV2Exchange(address(0))) {
            uint256 fromTokenBalance = fromTokenReal.universalBalanceOf(
                address(exchange)
            );
            uint256 destTokenBalance = destTokenReal.universalBalanceOf(
                address(exchange)
            );
            for (uint256 i = 0; i < amounts.length; i++) {
                rets[i] = _UniswapFormula(
                    fromTokenBalance,
                    destTokenBalance,
                    amounts[i]
                );
            }
            return (rets, 50_000);
        }
    }

    function _UniswapV2OverMidToken(
        IERC20 fromToken,
        IERC20 midToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    ) internal view returns (uint256[] memory rets, uint256 gas) {
        rets = _linearInterpolation(amount, parts);

        uint256 gas1;
        uint256 gas2;
        (rets, gas1) = _UniswapV2(fromToken, midToken, rets, flags);
        (rets, gas2) = _UniswapV2(midToken, destToken, rets, flags);
        return (rets, gas1 + gas2);
    }

    function _NoReturn(
        IERC20, /*fromToken*/
        IERC20, /*destToken*/
        uint256, /*amount*/
        uint256 parts,
        uint256 /*flags*/
    ) internal view returns (uint256[] memory rets, uint256 gas) {
        this;
        return (new uint256[](parts), 0);
    }
}
