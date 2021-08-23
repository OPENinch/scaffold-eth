// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IBdai is IERC20 {
    function join(uint256) external;

    function exit(uint256) external;
}
