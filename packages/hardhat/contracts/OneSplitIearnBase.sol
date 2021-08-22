// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IIearn.sol";

contract OneSplitIearnBase {
    function _yTokens() internal pure returns(IIearn[13] memory) {
        return [
            IIearn(0x16de59092dAE5CcF4A1E6439D611fd0653f0Bd01),
            IIearn(0x04Aa51bbcB46541455cCF1B8bef2ebc5d3787EC9),
            IIearn(0x73a052500105205d34Daf004eAb301916DA8190f),
            IIearn(0x83f798e925BcD4017Eb265844FDDAbb448f1707D),
            IIearn(0xd6aD7a6750A7593E092a9B218d66C0A814a3436e),
            IIearn(0xF61718057901F84C4eEC4339EF8f0D86D2B45600),
            IIearn(0x04bC0Ab673d88aE9dbC9DA2380cB6B79C4BCa9aE),
            IIearn(0xC2cB1040220768554cf699b0d863A3cd4324ce32),
            IIearn(0xE6354ed5bC4b393a5Aad09f21c46E101e692d447),
            IIearn(0x26EA744E5B887E5205727f55dFBE8685e3b21951),
            IIearn(0x99d1Fa417f94dcD62BfE781a1213c092a47041Bc),
            IIearn(0x9777d7E2b60bB01759D0E2f8be2095df444cb07E),
            IIearn(0x1bE5d71F2dA660BFdee8012dDc58D024448A0A59)
        ];
    }
}
