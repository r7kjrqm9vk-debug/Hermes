// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title HermesTracker
/// @notice On-chain activity tracker for HERMES protocol
/// @dev Records market activity and vault metrics on RISE Chain

contract HermesTracker {

    struct ActivityRecord {
        address actor;
        string action;
        uint256 marketId;
        uint256 amount;
        uint256 timestamp;
    }

    ActivityRecord[] public records;
    mapping(address => uint256) public actorCount;
    mapping(uint256 => uint256) public marketActivity;
    
    uint256 public totalVolume;
    uint256 public totalActions;

    event ActivityRecorded(
        uint256 indexed recordId,
        address indexed actor,
        string action,
        uint256 marketId,
        uint256 amount
    );

    /// @notice Registra un'azione sul protocollo
    function record(
        string calldata action,
        uint256 marketId,
        uint256 amount
    ) external returns (uint256 recordId) {
        recordId = records.length;
        
        records.push(ActivityRecord({
            actor: msg.sender,
            action: action,
            marketId: marketId,
            amount: amount,
            timestamp: block.timestamp
        }));

        actorCount[msg.sender]++;
        marketActivity[marketId] += amount;
        totalVolume += amount;
        totalActions++;

        emit ActivityRecorded(recordId, msg.sender, action, marketId, amount);
    }

    /// @notice Ritorna il numero totale di records
    function recordCount() external view returns (uint256) {
        return records.length;
    }

    /// @notice Ritorna stats globali del protocollo
    function getStats() external view returns (
        uint256 _totalActions,
        uint256 _totalVolume,
        uint256 _uniqueActors
    ) {
        return (totalActions, totalVolume, 0);
    }
}
