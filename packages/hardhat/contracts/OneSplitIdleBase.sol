// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IIdle.sol";

contract OneSplitIdleBase {
    function _idleTokens() internal pure returns(IIdle[8] memory) {
        // https://developers.idle.finance/contracts-and-codebase
        return [
            // V3
            IIdle(0x78751B12Da02728F467A44eAc40F5cbc16Bd7934),
            IIdle(0x12B98C621E8754Ae70d0fDbBC73D6208bC3e3cA6),
            IIdle(0x63D27B3DA94A9E871222CB0A32232674B02D2f2D),
            IIdle(0x1846bdfDB6A0f5c473dEc610144513bd071999fB),
            IIdle(0xcDdB1Bceb7a1979C6caa0229820707429dd3Ec6C),
            IIdle(0x42740698959761BAF1B06baa51EfBD88CB1D862B),
            // V2
            IIdle(0x10eC0D497824e342bCB0EDcE00959142aAa766dD),
            IIdle(0xeB66ACc3d011056B00ea521F8203580C2E5d3991)
        ];
    }
}
