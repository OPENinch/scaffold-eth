// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IPot {
    function dsr() external view returns (uint256);

    function chi() external view returns (uint256);

    function rho() external view returns (uint256);

    function drip() external returns (uint256);

    function join(uint256) external;

    function exit(uint256) external;
}

interface IChai is IERC20 {
    function POT() external view returns (IPot);

    function join(address dst, uint256 wad) external;

    function exit(address src, uint256 wad) external;
}
