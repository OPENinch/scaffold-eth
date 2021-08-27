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
        const decimal = to[2];
        
        await console.log('Swap: 1', from[1]);
        await console.log('returnAmount:', res.returnAmount.toString() / decimal, to[1]);
        await console.log('\n---------------------------------\n')

        return res;
    }

    from = Tokens.eth;
    dexes = Flags.FLAG_ANY; /* To select specific dex(es) use syntax: dexes = FLAG_DISABLE_ALL - FLAG_DISABLE_<dex>; */
    return_values = [];
    //console.log('\n---------------------------------\n')

    it(('getting DEX return values..').toString(), () => {
        for (var coin = 0; coin < list.length; coin++) {  
            if (list[coin] != from) {
                const to = list[coin];

                testDexReturn(from,to).then(result => {
                    return_values[coin] = result.returnAmount; 
                })
            }
        }
    });
    

    iterations = 0;
    second = 0;
    threshold = 0;

    for (var coin = 0; coin < list.length; coin++) {
        iterations++;

        it(('should work with ANY ' + from[1] + ' => ' + list[coin][1]).toString(), () => {
            /* THIS IS A SHITY WORKAROUND */
            for (var coins = 0; coins <= iterations; coins++) {
                if (coins == second) {
                    threshold = list[second][3];
                }
            }
            second++;
            /* END SHITTY WORKAROUND */

            // It can get here too fast, resulting in 'failed' tests that should have passed
            expect(return_values[coin]).to.be.bignumber.above(threshold.toString());
        });
    }
});
