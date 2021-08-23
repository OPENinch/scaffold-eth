// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IMooniswap.sol";
import "./libraries/UniversalERC20.sol";

contract OneSplitMooniswapTokenBase {
    using SafeMath for uint256;
    using Math for uint256;
    using UniversalERC20 for IERC20;

    struct TokenInfo {
        IERC20 token;
        uint256 reserve;
    }

    struct PoolDetails {
        TokenInfo[2] tokens;
        uint256 totalSupply;
    }

    function _getPoolDetails(IMooniswap pool) internal view returns (PoolDetails memory details) {
        for (uint i = 0; i < 2; i++) {
            IERC20 token = pool.tokens(i);
            details.tokens[i] = TokenInfo({
                token: token,
                reserve: token.universalBalanceOf(address(pool))
            });
        }

        details.totalSupply = IERC20(address(pool)).totalSupply();
    }
}
