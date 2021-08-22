// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IBalancerPool.sol";

// 0xA961672E8Db773be387e775bc4937C678F3ddF9a
interface IBalancerHelper {
    function getReturns(
        IBalancerPool pool,
        IERC20 fromToken,
        IERC20 destToken,
        uint256[] calldata amounts
    )
        external
        view
        returns(uint256[] memory rets);
}
