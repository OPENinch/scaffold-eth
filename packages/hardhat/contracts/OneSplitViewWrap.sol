// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./OneSplitConsts.sol";
import "./OneSplitViewWrapBase.sol";
import "./OneSplitMStableView.sol";
import "./OneSplitChaiView.sol";
import "./OneSplitBdaiView.sol";
import "./OneSplitAaveView.sol";
import "./OneSplitFulcrumView.sol";
import "./OneSplitCompoundView.sol";
import "./OneSplitIearnView.sol";
import "./OneSplitIdleView.sol";
import "./OneSplitWethView.sol";
import "./OneSplitDMMView.sol";

contract OneSplitViewWrap is
    OneSplitViewWrapBase,
    OneSplitMStableView,
    OneSplitChaiView,
    OneSplitBdaiView,
    OneSplitAaveView,
    OneSplitFulcrumView,
    OneSplitCompoundView,
    OneSplitIearnView,
    OneSplitIdleView,
    OneSplitWethView,
    OneSplitDMMView
{
    IOneSplitView public oneSplitView;

    constructor(IOneSplitView _oneSplit) {
        oneSplitView = _oneSplit;
    }

    function getExpectedReturn(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    ) virtual override
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
    ) virtual override(OneSplitAaveView, 
               OneSplitBdaiView, 
               OneSplitChaiView, 
               OneSplitCompoundView, 
               OneSplitDMMView, 
               OneSplitFulcrumView, 
               OneSplitIdleView, 
               OneSplitIearnView, 
               OneSplitMStableView,
               OneSplitViewWrapBase, 
               OneSplitWethView) //TODO: this feels wrong
        public
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

        return super.getExpectedReturnWithGas(
            fromToken,
            destToken,
            amount,
            parts,
            flags,
            destTokenEthPriceTimesGasPrice
        );
    }

    function _getExpectedReturnRespectingGasFloor(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags,
        uint256 destTokenEthPriceTimesGasPrice
    ) override
        internal
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
}
