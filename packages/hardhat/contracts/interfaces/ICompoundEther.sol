// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ICompoundEther is IERC20 {
    function mint() external payable;

    function redeem(uint256 redeemTokens) external returns (uint256);
}
