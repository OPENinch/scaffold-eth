// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


interface IBancorFinder {
    function buildBancorPath(
        IERC20 fromToken,
        IERC20 destToken
    )
        external
        view
        returns(address[] memory path);
}
