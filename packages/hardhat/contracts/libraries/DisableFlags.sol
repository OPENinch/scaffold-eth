// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library DisableFlags {
    function check(uint256 flags, uint256 flag) internal pure returns(bool) { /// @dev  internal -> public
        return (flags & flag) != 0;
    }
}
