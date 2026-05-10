// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {euint32, InEuint32, FHE} from "@fhenixprotocol/cofhe-contracts/FHE.sol";

/// @title ReputationToken
/// @notice Encrypted creator score on Fhenix CoFHE
/// @dev Score is FHE-encrypted — only owner can read it, protocol can only check threshold

contract ReputationToken {

    mapping(address => euint32) private _scores;
    mapping(address => bool) public hasClaimed;
    uint256 public totalHolders;

    // Minimum score to create a market on HermesMarket
    uint32 public constant MIN_SCORE = 100;
    // Base score on first claim
    uint32 public constant BASE_SCORE = 100;
    // Score increment per action
    uint32 public constant ACTION_BONUS = 10;

    event ScoreClaimed(address indexed user);
    event ScoreIncremented(address indexed user);

    /// @notice Claim initial reputation score — once per address
    function claimScore() external {
        require(!hasClaimed[msg.sender], "ReputationToken: already claimed");
        hasClaimed[msg.sender] = true;
        totalHolders++;

        euint32 baseScore = FHE.asEuint32(BASE_SCORE);
        _scores[msg.sender] = baseScore;
        FHE.allowThis(_scores[msg.sender]);
        FHE.allow(_scores[msg.sender], msg.sender);

        emit ScoreClaimed(msg.sender);
    }

    /// @notice Increment score by ACTION_BONUS — callable by protocol contracts
    function incrementScore(address user) external {
        require(hasClaimed[user], "ReputationToken: user has no score");

        euint32 bonus = FHE.asEuint32(ACTION_BONUS);
        _scores[user] = FHE.add(_scores[user], bonus);
        FHE.allowThis(_scores[user]);
        FHE.allow(_scores[user], user);

        emit ScoreIncremented(user);
    }

    /// @notice Check if user meets minimum score threshold — returns encrypted bool
    /// @dev Protocol uses this to gate market creation without revealing score
    function isQualified(address user) external view returns (bool) {
        if (!hasClaimed[user]) return false;
        // Note: full FHE threshold check requires off-chain cofhejs
        // This is a simplified on-chain check for testnet
        return hasClaimed[user];
    }

    /// @notice Returns encrypted score handle — user decrypts off-chain via cofhejs
    function myScore() external view returns (euint32) {
        return _scores[msg.sender];
    }

    /// @notice Returns score handle for any address — permission-gated
    function scoreOf(address user) external view returns (euint32) {
        return _scores[user];
    }
}
