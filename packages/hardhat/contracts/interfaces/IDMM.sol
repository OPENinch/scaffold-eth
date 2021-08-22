// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


interface IDMMController {
    function getUnderlyingTokenForDmm(IERC20 token) external view returns(IERC20);
}


interface IDMM is IERC20 {
    function getCurrentExchangeRate() external view returns(uint256);
    function mint(uint256 underlyingAmount) external returns(uint256);
    function redeem(uint256 amount) external returns(uint256);
}
