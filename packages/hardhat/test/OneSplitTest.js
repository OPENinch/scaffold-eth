const { use, expect } = require("chai");
const { solidity } = require("ethereum-waffle");
const { ethers } = require("hardhat");
const assert = require('assert');
const { BN, expectRevert } = require('@openzeppelin/test-helpers');

use(solidity);

const DISABLE_ALL = new BN('20000000', 16) + (new BN('40000000', 16));
const CURVE_SYNTHETIX = new BN('40000', 16);
const CURVE_COMPOUND = new BN('1000', 16);
const CURVE_ALL = new BN('200000000000', 16);
const KYBER_ALL = new BN('200000000000000', 16);
const MOONISWAP_ALL = new BN('8000000000000000', 16);
const BALANCER_ALL = new BN('1000000000000', 16);


const eth = ['0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE',      'ETH'];
const weth = ['0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2',     'WETH'];
const chai = ['0x06AF07097C9Eeb7fD685c692751D5C66dB49c215',     'CHAI'];
const dai = ['0x6B175474E89094C44Da98b954EedeAC495271d0F',      'DAI'];
const usdc = ['0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',     'USDC'];
const usdt = ['0xdAC17F958D2ee523a2206206994597C13D831ec7',     'USDT'];
const tusd = ['0x0000000000085d4780B73119b644AE5ecd22b376',     'TUSD'];
const busd = ['0x4Fabb145d64652a948d72533023f6E7A623C7C53',     'BUSD'];
const susd = ['0x57Ab1ec28D129707052df4dF418D58a2D46d5f51',     'SUSD'];
const pax = ['0x8E870D67F660D95d5be530380D0eC0bd388289E1',      'PAX'];
const renbtc = ['0xEB4C2781e4ebA804CE9a9803C67d0893436bB27D',   'RENBTC'];
const wbtc = ['0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599',     'WBTC'];
const tbtc = ['0x1bBE271d15Bb64dF0bc6CD28Df9Ff322F2eBD847',     'TBTC'];
const hbtc = ['0x0316EB71485b0Ab14103307bf65a021042c6d380',     'HBTC'];
const sbtc = ['0xfE18be6b3Bd88A2D2A7f928d00292E7a9963CfC6',     'SBTC'];

describe("OneSplit test", function () {
    this.timeout(200000);

    before(async () => {
        [user1, user2, ...addrs] = await ethers.getSigners();

        const OneSplitViewDeployment = await ethers.getContractFactory("OneSplitView");
        const OneSplitViewWrapDeployment = await ethers.getContractFactory('OneSplitViewWrap');
        const OneSplitDeployment = await ethers.getContractFactory('OneSplit');
        const OneSplitWrapDeployment = await ethers.getContractFactory('OneSplitWrap');

        OneSplitView = await OneSplitViewDeployment.deploy();
        OneSplitViewWrap = await OneSplitViewWrapDeployment.deploy(OneSplitView.address);
        OneSplit = await OneSplitDeployment.deploy(OneSplitViewWrap.address)
        OneSplitWrap = await OneSplitWrapDeployment.deploy(OneSplitViewWrap.address, OneSplit.address);
    });

    from = eth;
    to = susd;

    it(('should work with Curve ' + from[1] + ' => ' + to[1]).toString(), async function () {
        const res = await OneSplitWrap.getExpectedReturn(
            from[0], // From token
            to[0], // Dest token
            '1000000000000000000', // 1.0  // amount of from token
            10, // parts, higher = more granular, but effects gas usage (probably exponentially)
            DISABLE_ALL + (CURVE_ALL), // flag (enable only curve)
        );

        console.log('Swap: 1', from[1]);
        console.log('returnAmount:', res.returnAmount.toString() / 1e6, to[1]);
        // console.log('distribution:', res.distribution.map(a => a.toString()));
        // console.log('raw:', res.returnAmount.toString());
        expect(res.returnAmount).to.be.bignumber.above('390000000');
    });
});