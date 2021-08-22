// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IBdai.sol";

contract OneSplitBdaiBase {
    IBdai internal constant bdai = IBdai(0x6a4FFAafa8DD400676Df8076AD6c724867b0e2e8);
    IERC20 internal constant btu = IERC20(0xb683D83a532e2Cb7DFa5275eED3698436371cc9f);
}
