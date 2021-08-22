// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IAaveToken is IERC20 {
    function underlyingAssetAddress() external view returns (IERC20);

    function redeem(uint256 amount) external;
}
