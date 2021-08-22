// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


interface ISmartTokenConverter {
    function getReserveRatio(IERC20 token) external view returns (uint32);

    function connectorTokenCount() external view returns (uint256);

    function connectorTokens(uint256 i) external view returns (IERC20);
}
