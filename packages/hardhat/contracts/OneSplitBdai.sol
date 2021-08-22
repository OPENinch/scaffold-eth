// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IBdai.sol";
import "./interfaces/IOneSplit.sol";
import "./libraries/DisableFlags.sol";
import "./libraries/UniversalERC20.sol";
import "./OneSplitBaseWrap.sol";
import "./OneSplitBdaiBase.sol";

abstract contract OneSplitBdai is OneSplitBaseWrap, OneSplitBdaiBase {
    using DisableFlags for uint256;
    using UniversalERC20 for IERC20;

    function _swap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256 flags
    ) virtual override internal {
        if (fromToken == destToken) {
            return;
        }

        if (flags.check(FLAG_DISABLE_ALL_WRAP_SOURCES) == flags.check(FLAG_DISABLE_BDAI)) {
            if (fromToken == IERC20(bdai)) {
                bdai.exit(amount);

                uint256 btuBalance = btu.balanceOf(address(this));
                if (btuBalance > 0) {
                    (,uint256[] memory btuDistribution) = this.getExpectedReturn(
                        btu,
                        destToken,
                        btuBalance,
                        1,
                        flags
                    );

                    _swap(
                        btu,
                        destToken,
                        btuBalance,
                        btuDistribution,
                        flags
                    );
                }

                return super._swap(
                    dai,
                    destToken,
                    amount,
                    distribution,
                    flags
                );
            }

            if (destToken == IERC20(bdai)) {
                super._swap(fromToken, dai, amount, distribution, flags);

                uint256 daiBalance = dai.balanceOf(address(this));
                dai.universalApprove(address(bdai), daiBalance);
                bdai.join(daiBalance);
                return;
            }
        }

        return super._swap(fromToken, destToken, amount, distribution, flags);
    }
}
