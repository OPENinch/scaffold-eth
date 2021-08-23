// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IBalancerPool.sol";
import "./libraries/BalancerLib.sol";

contract BalancerHelper {
    using SafeMath for uint256;

    function getReturns(
        IBalancerPool pool,
        IERC20 fromToken,
        IERC20 destToken,
        uint256[] calldata amounts
    )
        external
        view
        returns(uint256[] memory rets)
    {
        uint256 swapFee = pool.getSwapFee();
        uint256 fromBalance = pool.getBalance(fromToken);
        uint256 destBalance = pool.getBalance(destToken);
        uint256 fromWeight = pool.getDenormalizedWeight(fromToken);
        uint256 destWeight = pool.getDenormalizedWeight(destToken);

        rets = new uint256[](amounts.length);
        for (uint i = 0; i < amounts.length && amounts[i] * 2 <= fromBalance; i++) {
            rets[i] = BalancerLib.calcOutGivenIn(
                fromBalance,
                fromWeight,
                destBalance,
                destWeight,
                amounts[i],
                swapFee
            );
        }
    }
}
