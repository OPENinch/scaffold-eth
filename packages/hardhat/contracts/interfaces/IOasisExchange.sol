// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


interface IOasisExchange {
    function getBuyAmount(IERC20 buyGem, IERC20 payGem, uint256 payAmt)
        external
        view
        returns (uint256 fillAmt);

    function sellAllAmount(IERC20 payGem, uint256 payAmt, IERC20 buyGem, uint256 minFillAmount)
        external
        returns (uint256 fillAmt);
}
