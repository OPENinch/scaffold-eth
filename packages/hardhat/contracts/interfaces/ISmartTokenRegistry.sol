// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


interface ISmartTokenRegistry {
    function isSmartToken(IERC20 token) external view returns (bool);
}
