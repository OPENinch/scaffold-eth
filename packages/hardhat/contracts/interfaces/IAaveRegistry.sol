// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IAaveToken.sol";

interface IAaveRegistry {
    function tokenByAToken(IAaveToken aToken) external view returns(IERC20);
    function aTokenByToken(IERC20 token) external view returns(IAaveToken);
}
