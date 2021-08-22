// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ICompound {
    function markets(address cToken)
        external
        view
        returns (bool isListed, uint256 collateralFactorMantissa);
}
