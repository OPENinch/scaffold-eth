// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


interface IDForceSwap {
    function getAmountByInput(IERC20 input, IERC20 output, uint256 amount) external view returns(uint256);
    function swap(IERC20 input, IERC20 output, uint256 amount) external;
}
