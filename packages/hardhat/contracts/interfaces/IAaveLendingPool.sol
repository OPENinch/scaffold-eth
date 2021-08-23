// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IAaveLendingPool {
    function core() external view returns (address);

    function deposit(IERC20 token, uint256 amount, uint16 refCode) external payable;
}
