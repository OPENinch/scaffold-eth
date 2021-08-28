const { use, expect } = require("chai");
const { solidity } = require("ethereum-waffle");
const { ethers } = require("hardhat");
const assert = require('assert');
const { BN, expectRevert } = require('@openzeppelin/test-helpers');
const { createVerify } = require("crypto");
const { Flags, Tokens, ERC20_ABI } = require("./constants");

use(solidity);

const list = [Tokens.weth, Tokens.usdt, Tokens.tusd, Tokens.busd, Tokens.susd, Tokens.pax, Tokens.renbtc, Tokens.wbtc, Tokens.hbtc, Tokens.sbtc];

describe("Oracle Test", function () {
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

    async function testDexReturn(from, to) {
        
        res = await OneSplitWrap.getExpectedReturn(
            from[0], // From token
            to[0], // Dest token
            '1000000000000000000', // 1.0  // amount of from token
            10, // parts, higher = more granular, but effects gas usage (probably exponentially)
            dexes // flags
        );
        
        
        return res;
    }

    fromToken = Tokens.eth;
    dexes = Flags.FLAG_ANY; /* To select specific dex(es) use syntax: dexes = FLAG_DISABLE_ALL - FLAG_DISABLE_<dex>; */
    console.log('\n---------------------------------\n')
    
    list.map(async (toToken,idx) => {
        it(('should work with ANY ' + fromToken[1] + ' => ' + list[idx][1]).toString(), async function (){
            const {returnAmount} = await testDexReturn(fromToken,toToken);

            console.log('Swap: 1', fromToken[1]);
            console.log('returnAmount:', returnAmount.toString() / toToken[2], toToken[1]);
            console.log('assert: ' + returnAmount + ' > ' + list[idx][3]);
            console.log('\n---------------------------------\n');

            assert(returnAmount > parseInt(list[idx][3]), "errorMessage");
        });
    });
    
});
