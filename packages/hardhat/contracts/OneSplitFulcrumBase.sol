// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IFulcrumToken.sol";
import "./libraries/UniversalERC20.sol";

contract OneSplitFulcrumBase {
    using UniversalERC20 for IERC20;

    function _isFulcrumToken(IERC20 token) internal view returns(IERC20) {
        if (token.isETH()) {
            return IERC20(address(0));
        }

        (bool success, bytes memory data) = address(token).staticcall{gas: 5000}(abi.encodeWithSignature(
            "name()"
        ));
        if (!success) {
            return IERC20(address(0));
        }

        bool foundBZX = false;
        for (uint i = 0; i + 6 < data.length; i++) {
            if (data[i + 0] == "F" &&
                data[i + 1] == "u" &&
                data[i + 2] == "l" &&
                data[i + 3] == "c" &&
                data[i + 4] == "r" &&
                data[i + 5] == "u" &&
                data[i + 6] == "m")
            {
                foundBZX = true;
                break;
            }
        }
        if (!foundBZX) {
            return IERC20(address(0));
        }

        (success, data) = address(token).staticcall{gas: 5000}(abi.encodeWithSelector(
            IFulcrumToken(address(token)).loanTokenAddress.selector
        ));
        if (!success) {
            return IERC20(address(0));
        }

        return abi.decode(data, (IERC20));
    }
}
