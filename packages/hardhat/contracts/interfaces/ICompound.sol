// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


interface ICompound {
    function markets(address cToken)
        external
        view
        returns (bool isListed, uint256 collateralFactorMantissa);
}


interface ICompoundToken is IERC20 {
    function underlying() external view returns (address);

    function exchangeRateStored() external view returns (uint256);

    function mint(uint256 mintAmount) external returns (uint256);

    function redeem(uint256 redeemTokens) external returns (uint256);
}


interface ICompoundEther is IERC20 {
    function mint() external payable;

    function redeem(uint256 redeemTokens) external returns (uint256);
}
