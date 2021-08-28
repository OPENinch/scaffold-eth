const { use, expect } = require("chai");
const { solidity } = require("ethereum-waffle");
const { ethers } = require("hardhat");
const assert = require('assert');
const { BN, expectRevert } = require('@openzeppelin/test-helpers');
const { createVerify } = require("crypto");
const { Flags, Tokens, ERC20_ABI } = require("./constants");

use(solidity);

const list = [Tokens.weth, Tokens.usdt, Tokens.tusd, Tokens.busd, Tokens.susd, Tokens.pax, Tokens.renbtc, Tokens.wbtc, Tokens.hbtc, Tokens.sbtc];

describe("Swap Test", function () {
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

        await fundAccounts()
    });
    
    async function fundAccounts() {
        const accounts = await ethers.getSigners();
    
        const dai = await ethers.getContractAt(ERC20_ABI, Tokens.dai[0]);
        const weth = await ethers.getContractAt(ERC20_ABI, Tokens.weth[0]);
    
        await ethers.provider.send("hardhat_impersonateAccount", [
          "0x7641a5E890478Bea2bdC4CAFfF960AC4ae96886e",
        ]);
        const impersonatedAccountDAI = await ethers.provider.getSigner(
          "0x7641a5E890478Bea2bdC4CAFfF960AC4ae96886e"
        );
    
        const amountDai = ethers.utils.parseUnits("1000.0", 18);
        await dai
          .connect(impersonatedAccountDAI)
          .transfer(user1.address, amountDai);
        await dai
          .connect(impersonatedAccountDAI)
          .transfer(user2.address, amountDai);
    
        await ethers.provider.send("hardhat_impersonateAccount", [
          "0x6555e1CC97d3cbA6eAddebBCD7Ca51d75771e0B8",
        ]);
        const impersonatedAccountWETH = await ethers.provider.getSigner(
          "0x6555e1CC97d3cbA6eAddebBCD7Ca51d75771e0B8"
        );
    
        const amountWeth = ethers.utils.parseUnits("100.0", 18);
        await weth
          .connect(impersonatedAccountWETH)
          .transfer(user1.address, amountWeth);
        await weth
          .connect(impersonatedAccountWETH)
          .transfer(user2.address, amountWeth);
      }
});
