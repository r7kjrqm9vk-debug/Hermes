// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IHermesToken {
    function mint(address to, uint256 amount) external;
}

/// @title HermesFaucet
/// @notice Drip 1000 HERMES every 24h per wallet — gasless via RISE Wallet SDK

contract HermesFaucet {
    IHermesToken public token;
    uint256 public constant DRIP_AMOUNT = 1000 * 10 ** 18;
    uint256 public constant COOLDOWN = 24 hours;

    mapping(address => uint256) public lastClaim;

    event Claimed(address indexed user, uint256 amount);

    constructor(address _token) {
        token = IHermesToken(_token);
    }

    function claim() external {
        require(
            block.timestamp >= lastClaim[msg.sender] + COOLDOWN,
            "HermesFaucet: wait 24h"
        );
        lastClaim[msg.sender] = block.timestamp;
        token.mint(msg.sender, DRIP_AMOUNT);
        emit Claimed(msg.sender, DRIP_AMOUNT);
    }

    function canClaim(address user) external view returns (bool) {
        return block.timestamp >= lastClaim[user] + COOLDOWN;
    }

    function nextClaimTime(address user) external view returns (uint256) {
        return lastClaim[user] + COOLDOWN;
    }
}
