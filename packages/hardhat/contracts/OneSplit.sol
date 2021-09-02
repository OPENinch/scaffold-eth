// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IOneSplit.sol";
import "./libraries/DisableFlags.sol";
import "./libraries/UniversalERC20.sol";
import "./libraries/UniswapV2ExchangeLib.sol";
import "./OneSplitConsts.sol";

contract OneSplit is IOneSplit, OneSplitConsts {

    using SafeMath for uint256;
    using UniversalERC20 for IERC20;
    using UniswapV2ExchangeLib for IUniswapV2Exchange;

    IOneSplitView public oneSplitView;

    constructor(IOneSplitView _oneSplitView) {
        oneSplitView = _oneSplitView;
    }

    receive() external payable {
        // solium-disable-next-line security/no-tx-origin
        require(msg.sender != tx.origin);
    }

    function getExpectedReturn(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
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
        uint256 flags,
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
        return oneSplitView.getExpectedReturnWithGas(
            fromToken,
            destToken,
            amount,
            parts,
            flags,
            destTokenEthPriceTimesGasPrice
        );
    }

    function swap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] memory distribution,
        uint256 flags  // See constants in IOneSplit.sol
    ) override public payable returns(uint256 returnAmount) {
        if (fromToken == destToken) {
            return amount;
        }

        function(IERC20,IERC20,uint256,uint256)[DEXES_COUNT] memory reserves = [
            _swapOnUniswap,
            _swapOnBancor,
            _swapOnCurveCompound,
            _swapOnCurveUSDT,
            _swapOnCurveY,
            _swapOnCurveBinance,
            _swapOnCurveSynthetix,
            _swapOnUniswapCompound,
            _swapOnUniswapChai,
            _swapOnUniswapAave,
            _swapOnUniswapV2,
            _swapOnUniswapV2ETH,
            _swapOnUniswapV2DAI,
            _swapOnUniswapV2USDC,
            _swapOnCurvePAX,
            _swapOnCurveRenBTC,
            _swapOnCurveTBTC,
            _swapOnShell,
            _swapOnMStableMUSD,
            _swapOnCurveSBTC,
            _swapOnBalancer1,
            _swapOnBalancer2,
            _swapOnBalancer3
        ];

        require(distribution.length <= reserves.length, "OneSplit: Distribution array should not exceed reserves array size");

        uint256 parts = 0;
        uint256 lastNonZeroIndex = 0;
        for (uint i = 0; i < distribution.length; i++) {
            if (distribution[i] > 0) {
                parts = parts + (distribution[i]);
                lastNonZeroIndex = i;
            }
        }

        if (parts == 0) {
            if (fromToken.isETH()) {
                payable(msg.sender).transfer(msg.value);
                return msg.value;
            }
            return amount;
        }

        fromToken.universalTransferFrom(msg.sender, address(this), amount);
        uint256 remainingAmount = fromToken.universalBalanceOf(address(this));

        for (uint i = 0; i < distribution.length; i++) {
            if (distribution[i] == 0) {
                continue;
            }

            uint256 swapAmount = amount * (distribution[i]) / (parts);
            if (i == lastNonZeroIndex) {
                swapAmount = remainingAmount;
            }
            remainingAmount -= swapAmount;
            reserves[i](fromToken, destToken, swapAmount, flags);
        }

        returnAmount = destToken.universalBalanceOf(address(this));
        require(returnAmount >= minReturn, "OneSplit: Return amount was not enough");
        destToken.universalTransfer(msg.sender, returnAmount);
        fromToken.universalTransfer(msg.sender, fromToken.universalBalanceOf(address(this)));
    }

    // Swap helpers

    function _swapOnCurveCompound(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 /*flags*/
    ) internal {
        int128 i = (fromToken == dai ? int128(1) : int128(0)) + (fromToken == usdc ? int128(2) : int128(0));
        int128 j = (destToken == dai ? int128(1) : int128(0)) + (destToken == usdc ? int128(2) : int128(0));
        if (i == 0 || j == 0) {
            return;
        }

        fromToken.universalApprove(address(curveCompound), amount);
        curveCompound.exchange_underlying(i - 1, j - 1, amount, 0);
    }

    function _swapOnCurveUSDT(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 /*flags*/
    ) internal {
        int128 i = (fromToken == dai ? int128(1) : int128(0)) +
            (fromToken == usdc ? int128(2) : int128(0)) +
            (fromToken == usdt ? int128(3) : int128(0));
        int128 j = (destToken == dai ? int128(1) : int128(0)) +
            (destToken == usdc ? int128(2) : int128(0)) +
            (destToken == usdt ? int128(3) : int128(0));
        if (i == 0 || j == 0) {
            return;
        }

        fromToken.universalApprove(address(curveUSDT), amount);
        curveUSDT.exchange_underlying(i - 1, j - 1, amount, 0);
    }

    function _swapOnCurveY(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 /*flags*/
    ) internal {
        int128 i = (fromToken == dai ? int128(1) : int128(0)) +
            (fromToken == usdc ? int128(2) : int128(0)) +
            (fromToken == usdt ? int128(3) : int128(0)) +
            (fromToken == tusd ? int128(4) : int128(0));
        int128 j = (destToken == dai ? int128(1) : int128(0)) +
            (destToken == usdc ? int128(2) : int128(0)) +
            (destToken == usdt ? int128(3) : int128(0)) +
            (destToken == tusd ? int128(4) : int128(0));
        if (i == 0 || j == 0) {
            return;
        }

        fromToken.universalApprove(address(curveY), amount);
        curveY.exchange_underlying(i - 1, j - 1, amount, 0);
    }

    function _swapOnCurveBinance(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 /*flags*/
    ) internal {
        int128 i = (fromToken == dai ? int128(1) : int128(0)) +
            (fromToken == usdc ? int128(2) : int128(0)) +
            (fromToken == usdt ? int128(3) : int128(0)) +
            (fromToken == busd ? int128(4) : int128(0));
        int128 j = (destToken == dai ? int128(1) : int128(0)) +
            (destToken == usdc ? int128(2) : int128(0)) +
            (destToken == usdt ? int128(3) : int128(0)) +
            (destToken == busd ? int128(4) : int128(0));
        if (i == 0 || j == 0) {
            return;
        }

        fromToken.universalApprove(address(curveBinance), amount);
        curveBinance.exchange_underlying(i - 1, j - 1, amount, 0);
    }

    function _swapOnCurveSynthetix(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 /*flags*/
    ) internal {
        int128 i = (fromToken == dai ? int128(1) : int128(0)) +
            (fromToken == usdc ? int128(2) : int128(0)) +
            (fromToken == usdt ? int128(3) : int128(0)) +
            (fromToken == susd ? int128(4) : int128(0));
        int128 j = (destToken == dai ? int128(1) : int128(0)) +
            (destToken == usdc ? int128(2) : int128(0)) +
            (destToken == usdt ? int128(3) : int128(0)) +
            (destToken == susd ? int128(4) : int128(0));
        if (i == 0 || j == 0) {
            return;
        }

        fromToken.universalApprove(address(curveSynthetix), amount);
        curveSynthetix.exchange_underlying(i - 1, j - 1, amount, 0);
    }

    function _swapOnCurvePAX(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 /*flags*/
    ) internal {
        int128 i = (fromToken == dai ? int128(1) : int128(0)) +
            (fromToken == usdc ? int128(2) : int128(0)) +
            (fromToken == usdt ? int128(3) : int128(0)) +
            (fromToken == pax ? int128(4) : int128(0));
        int128 j = (destToken == dai ? int128(1) : int128(0)) +
            (destToken == usdc ? int128(2) : int128(0)) +
            (destToken == usdt ? int128(3) : int128(0)) +
            (destToken == pax ? int128(4) : int128(0));
        if (i == 0 || j == 0) {
            return;
        }

        fromToken.universalApprove(address(curvePAX), amount);
        curvePAX.exchange_underlying(i - 1, j - 1, amount, 0);
    }

    function _swapOnShell(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 /*flags*/
    ) internal {
        fromToken.universalApprove(address(shell), amount);
        shell.swapByOrigin(
            address(fromToken),
            address(destToken),
            amount,
            0,
            block.timestamp + 50
        );
    }

    function _swapOnMStableMUSD(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 /*flags*/
    ) internal {
        fromToken.universalApprove(address(musd), amount);
        musd.swap(
            fromToken,
            destToken,
            amount,
            address(this)
        );
    }

    function _swapOnCurveRenBTC(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 /*flags*/
    ) internal {
        int128 i = (fromToken == renbtc ? int128(1) : int128(0)) +
            (fromToken == wbtc ? int128(2) : int128(0));
        int128 j = (destToken == renbtc ? int128(1) : int128(0)) +
            (destToken == wbtc ? int128(2) : int128(0));
        if (i == 0 || j == 0) {
            return;
        }

        fromToken.universalApprove(address(curveRenBTC), amount);
        curveRenBTC.exchange(i - 1, j - 1, amount, 0);
    }

    function _swapOnCurveTBTC(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 /*flags*/
    ) internal {
        int128 i = (fromToken == tbtc ? int128(1) : int128(0)) +
            (fromToken == wbtc ? int128(2) : int128(0)) +
            (fromToken == hbtc ? int128(3) : int128(0));
        int128 j = (destToken == tbtc ? int128(1) : int128(0)) +
            (destToken == wbtc ? int128(2) : int128(0)) +
            (destToken == hbtc ? int128(3) : int128(0));
        if (i == 0 || j == 0) {
            return;
        }

        fromToken.universalApprove(address(curveTBTC), amount);
        curveTBTC.exchange(i - 1, j - 1, amount, 0);
    }

    function _swapOnCurveSBTC(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 /*flags*/
    ) internal {
        int128 i = (fromToken == renbtc ? int128(1) : int128(0)) +
            (fromToken == wbtc ? int128(2) : int128(0)) +
            (fromToken == sbtc ? int128(3) : int128(0));
        int128 j = (destToken == renbtc ? int128(1) : int128(0)) +
            (destToken == wbtc ? int128(2) : int128(0)) +
            (destToken == sbtc ? int128(3) : int128(0));
        if (i == 0 || j == 0) {
            return;
        }

        fromToken.universalApprove(address(curveSBTC), amount);
        curveSBTC.exchange(i - 1, j - 1, amount, 0);
    }

    function _swapOnUniswap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 /*flags*/
    ) internal {
        uint256 returnAmount = amount;

        if (!fromToken.isETH()) {
            IUniswapExchange fromExchange = uniswapFactory.getExchange(fromToken);
            if (fromExchange != IUniswapExchange(address(0))) {
                fromToken.universalApprove(address(fromExchange), returnAmount);
                returnAmount = fromExchange.tokenToEthSwapInput(returnAmount, 1, block.timestamp);
            }
        }

        if (!destToken.isETH()) {
            IUniswapExchange toExchange = uniswapFactory.getExchange(destToken);
            if (toExchange != IUniswapExchange(address(0))) {
                returnAmount = toExchange.ethToTokenSwapInput{value:returnAmount}(1, block.timestamp);
            }
        }
    }

    function _swapOnUniswapCompound(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 flags
    ) internal {
        if (!fromToken.isETH()) {
            ICompoundToken fromCompound = compoundRegistry.cTokenByToken(fromToken);
            fromToken.universalApprove(address(fromCompound), amount);
            fromCompound.mint(amount);
            _swapOnUniswap(IERC20(fromCompound), destToken, IERC20(fromCompound).universalBalanceOf(address(this)), flags);
            return;
        }

        if (!destToken.isETH()) {
            ICompoundToken toCompound = compoundRegistry.cTokenByToken(destToken);
            _swapOnUniswap(fromToken, IERC20(toCompound), amount, flags);
            toCompound.redeem(IERC20(toCompound).universalBalanceOf(address(this)));
            destToken.universalBalanceOf(address(this));
            return;
        }
    }

    function _swapOnUniswapChai(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 flags
    ) internal {
        if (fromToken == dai) {
            fromToken.universalApprove(address(chai), amount);
            chai.join(address(this), amount);
            _swapOnUniswap(IERC20(chai), destToken, IERC20(chai).universalBalanceOf(address(this)), flags);
            return;
        }

        if (destToken == dai) {
            _swapOnUniswap(fromToken, IERC20(chai), amount, flags);
            chai.exit(address(this), chai.balanceOf(address(this)));
            return;
        }
    }

    function _swapOnUniswapAave(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 flags
    ) internal {
        if (!fromToken.isETH()) {
            IAaveToken fromAave = aaveRegistry.aTokenByToken(fromToken);
            fromToken.universalApprove(aave.core(), amount);
            aave.deposit(fromToken, amount, 1101);
            _swapOnUniswap(IERC20(fromAave), destToken, IERC20(fromAave).universalBalanceOf(address(this)), flags);
            return;
        }

        if (!destToken.isETH()) {
            IAaveToken toAave = aaveRegistry.aTokenByToken(destToken);
            _swapOnUniswap(fromToken, IERC20(toAave), amount, flags);
            toAave.redeem(toAave.balanceOf(address(this)));
            return;
        }
    }
    
    function _swapOnBancor(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 /*flags*/
    ) internal {
        IBancorNetwork bancorNetwork = IBancorNetwork(bancorContractRegistry.addressOf("BancorNetwork"));
        address[] memory path = bancorNetworkPathFinder.generatePath(
            fromToken.isETH() ? bancorEtherToken : fromToken,
            destToken.isETH() ? bancorEtherToken : destToken
        );
        fromToken.universalApprove(address(bancorNetwork), amount);
        uint256 val = fromToken.isETH() ? amount : 0;
        bancorNetwork.convert{value: val}(path, amount, 1);
    }

    function _swapOnOasis(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 /*flags*/
    ) internal {
        if (fromToken.isETH()) {
            weth.deposit{value: amount}(); //TODO: this cant be right
        }

        IERC20 approveToken = fromToken.isETH() ? weth : fromToken;
        approveToken.universalApprove(address(oasisExchange), amount);
        oasisExchange.sellAllAmount(
            fromToken.isETH() ? weth : fromToken,
            amount,
            destToken.isETH() ? weth : destToken,
            1
        );

        if (destToken.isETH()) {
            weth.withdraw(weth.balanceOf(address(this)));
        }
    }

    function _swapOnUniswapV2Internal(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 /*flags*/
    ) internal returns(uint256 returnAmount) {
        if (fromToken.isETH()) {
            weth.deposit{value: amount}(); //TODO: this cant be right
        }

        IERC20 fromTokenReal = fromToken.isETH() ? weth : fromToken;
        IERC20 toTokenReal = destToken.isETH() ? weth : destToken;
        IUniswapV2Exchange exchange = uniswapV2.getPair(fromTokenReal, toTokenReal);
        bool needSync;
        bool needSkim;
        (returnAmount, needSync, needSkim) = exchange.getReturn(fromTokenReal, toTokenReal, amount);
        if (needSync) {
            exchange.sync();
        }
        else if (needSkim) {
            exchange.skim(0x68a17B587CAF4f9329f0e372e3A78D23A46De6b5);
        }

        fromTokenReal.universalTransfer(address(exchange), amount);
        if ((address(fromTokenReal)) < (address(toTokenReal))) { //TODO: removed uint256 conversion 
            exchange.swap(0, returnAmount, address(this), "");
        } else {
            exchange.swap(returnAmount, 0, address(this), "");
        }

        if (destToken.isETH()) {
            weth.withdraw(weth.balanceOf(address(this)));
        }
    }

    function _swapOnUniswapV2OverMid(
        IERC20 fromToken,
        IERC20 midToken,
        IERC20 destToken,
        uint256 amount,
        uint256 flags
    ) internal {
        _swapOnUniswapV2Internal(
            midToken,
            destToken,
            _swapOnUniswapV2Internal(
                fromToken,
                midToken,
                amount,
                flags
            ),
            flags
        );
    }

    function _swapOnUniswapV2(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 flags
    ) internal {
        _swapOnUniswapV2Internal(
            fromToken,
            destToken,
            amount,
            flags
        );
    }

    function _swapOnUniswapV2ETH(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 flags
    ) internal {
        _swapOnUniswapV2OverMid(
            fromToken,
            weth,
            destToken,
            amount,
            flags
        );
    }

    function _swapOnUniswapV2DAI(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 flags
    ) internal {
        _swapOnUniswapV2OverMid(
            fromToken,
            dai,
            destToken,
            amount,
            flags
        );
    }

    function _swapOnUniswapV2USDC(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 flags
    ) internal {
        _swapOnUniswapV2OverMid(
            fromToken,
            usdc,
            destToken,
            amount,
            flags
        );
    }

    function _swapOnBalancerX(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 /*flags*/,
        uint256 poolIndex
    ) internal {
        address[] memory pools = balancerRegistry.getBestPoolsWithLimit(
            address(fromToken.isETH() ? weth : fromToken),
            address(destToken.isETH() ? weth : destToken),
            poolIndex + 1
        );

        if (fromToken.isETH()) {
            weth.deposit{value: amount}(); //TODO: this cant be right
        }

        (fromToken.isETH() ? weth : fromToken).universalApprove(pools[poolIndex], amount);
        IBalancerPool(pools[poolIndex]).swapExactAmountIn(
            fromToken.isETH() ? weth : fromToken,
            amount,
            destToken.isETH() ? weth : destToken,
            0,
            uint256(0)
        );

        if (destToken.isETH()) {
            weth.withdraw(weth.balanceOf(address(this)));
        }
    }

    function _swapOnBalancer1(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 flags
    ) internal {
        _swapOnBalancerX(fromToken, destToken, amount, flags, 0);
    }

    function _swapOnBalancer2(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 flags
    ) internal {
        _swapOnBalancerX(fromToken, destToken, amount, flags, 1);
    }

    function _swapOnBalancer3(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 flags
    ) internal {
        _swapOnBalancerX(fromToken, destToken, amount, flags, 2);
    }
}
