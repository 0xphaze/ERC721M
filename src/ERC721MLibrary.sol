// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library UserDataOps {
    /* ------------- balance: [0, 20) ------------- */

    function balance(uint256 userData) internal pure returns (uint256) {
        return userData & 0xFFFFF;
    }

    function increaseBalance(uint256 userData, uint256 amount) internal pure returns (uint256) {
        unchecked {
            return userData + amount;
        }
    }

    function decreaseBalance(uint256 userData, uint256 amount) internal pure returns (uint256) {
        unchecked {
            return userData - amount;
        }
    }

    /* ------------- numMinted: [20, 40) ------------- */

    function numMinted(uint256 userData) internal pure returns (uint256) {
        return (userData >> 20) & 0xFFFFF;
    }

    function increaseNumMinted(uint256 userData, uint256 amount) internal pure returns (uint256) {
        unchecked {
            return userData + (amount << 20);
        }
    }

    // function numLocked(uint256 userData) internal pure returns (uint256) {
    //     return (userData >> 120) & 0xFF;
    // }

    // function increaseNumLocked(uint256 userData, uint256 amount) internal pure returns (uint256) {
    //     unchecked {
    //         return userData + (amount << 120);
    //     }
    // }

    // function decreaseNumLocked(uint256 userData, uint256 amount) internal pure returns (uint256) {
    //     unchecked {
    //         return userData - (amount << 120);
    //     }
    // }

    // function lockStart(uint256 userData) internal pure returns (uint256) {
    //     return (userData >> 40) & 0xFFFFFFFFFF;
    // }

    // function setLockStart(uint256 userData, uint256 timestamp) internal pure returns (uint256) {
    //     return (userData & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000FFFFFFFFFF) | (timestamp << 40);
    // }
}

library TokenDataOps {
    function copy(uint256 tokenData) internal pure returns (uint256) {
        return tokenData & ((uint256(1) << (160 + (((tokenData >> 160) & 1) << 1))) - 1);
    }

    /// ^ equivalent code:
    // function copy2(uint256 tokenData) internal pure returns (uint256) {
    //     uint256 copiedData = uint160(tokenData);
    //     if (isConsecutiveLocked(tokenData)) {
    //         copiedData = setConsecutiveLocked(copiedData);
    //         if (locked(tokenData)) copiedData = lock(copiedData);
    //     }
    //     return copiedData;
    // }

    /* ------------- owner: [0, 160) ------------- */

    function owner(uint256 tokenData, address warden) internal pure returns (address) {
        return locked(tokenData) ? warden : trueOwner(tokenData);
    }

    function setOwner(uint256 tokenData, address owner_) internal pure returns (uint256) {
        return (tokenData & 0xFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000000000000000000000) | uint160(owner_);
    }

    function trueOwner(uint256 tokenData) internal pure returns (address) {
        return address(uint160(tokenData));
    }

    /* ------------- consecutiveLock: [160, 161) ------------- */

    function isConsecutiveLocked(uint256 tokenData) internal pure returns (bool) {
        return ((tokenData >> 160) & uint256(1)) != 0;
    }

    function setConsecutiveLocked(uint256 tokenData) internal pure returns (uint256) {
        return tokenData | (uint256(1) << 160);
    }

    function unsetConsecutiveLocked(uint256 tokenData) internal pure returns (uint256) {
        return tokenData & ~(uint256(1) << 160);
    }

    /* ------------- locked: [161, 162) ------------- */

    function locked(uint256 tokenData) internal pure returns (bool) {
        return ((tokenData >> 161) & uint256(1)) != 0; // Note: this is not masked and can carry over when calling 'ownerOf'
    }

    function lock(uint256 tokenData) internal pure returns (uint256) {
        return tokenData | (uint256(1) << 161);
    }

    function unlock(uint256 tokenData) internal pure returns (uint256) {
        return tokenData & ~(uint256(1) << 161);
    }

    /* ------------- nextTokenDataSet: [162, 163) ------------- */

    function nextTokenDataSet(uint256 tokenData) internal pure returns (bool) {
        return ((tokenData >> 162) & uint256(1)) != 0;
    }

    function flagNextTokenDataSet(uint256 tokenData) internal pure returns (uint256) {
        return tokenData | (uint256(1) << 162); // nextTokenDatatSet flag (don't repeat the read/write)
    }

    // /* ------------- aux: [168, 256) ------------- */

    // function aux(uint256 tokenData) internal pure returns (uint256) {
    //     return (tokenData >> 168) & 0xFFFFFFFFFFFFFFFFFFFFFF;
    // }
}
