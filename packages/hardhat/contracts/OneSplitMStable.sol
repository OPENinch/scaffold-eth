// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IChai.sol";
import "./libraries/UniversalERC20.sol";
import "./libraries/DisableFlags.sol";
import "./OneSplitBaseWrap.sol";

abstract contract OneSplitMStable is OneSplitBaseWrap {
    using SafeMath for uint256;
    using DisableFlags for uint256;

    using UniversalERC20 for IERC20;

/*TODO: why does this _swap function not work like the others?
 * what is point in remapping _swap to point into a different function
 * rather than the method shown here
 */
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

        if (flags.check(FLAG_DISABLE_ALL_WRAP_SOURCES) == flags.check(FLAG_DISABLE_MSTABLE_MUSD)) {
            if (fromToken == IERC20(musd)) {
                if (destToken == usdc || destToken == dai || destToken == usdt || destToken == tusd) {
                    (,,, uint256 result) = musd_helper.getRedeemValidity(fromToken, amount, destToken);
                    musd.redeem(
                        destToken,
                        result
                    );
                }
                else {
                    (,,, uint256 result) = musd_helper.getRedeemValidity(fromToken, amount, dai);
                    musd.redeem(
                        dai,
                        result
                    );
                    super._swap(
                        dai,
                        destToken,
                        dai.balanceOf(address(this)),
                        distribution,
                        flags
                    );
                }
                return;
            }

            if (destToken == IERC20(musd)) {
                if (fromToken == usdc || fromToken == dai || fromToken == usdt || fromToken == tusd) {
                    fromToken.universalApprove(address(musd), amount);
                    musd.swap(
                        fromToken,
                        destToken,
                        amount,
                        address(this)
                    );
                }
                else {
                    super._swap(
                        fromToken,
                        dai,
                        amount,
                        distribution,
                        flags
                    );
                    musd.swap(
                        dai,
                        destToken,
                        dai.balanceOf(address(this)),
                        address(this)
                    );
                }
                return;
            }
        }

        return super._swap(
            fromToken,
            destToken,
            amount,
            distribution,
            flags
        );
    }
}
