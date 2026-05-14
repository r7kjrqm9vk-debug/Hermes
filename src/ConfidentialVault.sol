// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@inco/lightning/Lib.sol";

interface IcHERMES {
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
}

contract ConfidentialVault {
    using e for *;

    mapping(address => euint256) private _balances;
    mapping(address => euint256) private _lockedForBridge;
    
    uint256 public totalDeposits;
    uint256 public bridgeNonce;
    address public cHERMES;
    address public bridge;

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event DarkBridgeRequested(address indexed user, euint256 encryptedAmount, uint256 nonce);
    event BridgeClaimed(address indexed user, uint256 nonce);

    constructor(address _cHERMES, address _bridge) {
        cHERMES = _cHERMES;
        bridge = _bridge;
    }

    function deposit() external payable {
        require(msg.value > 0, "Zero deposit");
        euint256 currentBalance = _balances[msg.sender];
        euint256 depositAmount = msg.value.asEuint256();
        _balances[msg.sender] = currentBalance.add(depositAmount);
        _balances[msg.sender].allow(msg.sender);
        totalDeposits += msg.value;
        IcHERMES(cHERMES).mint(msg.sender, msg.value);
        emit Deposited(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        require(amount > 0, "Zero withdraw");
        euint256 withdrawAmount = amount.asEuint256();
        _balances[msg.sender] = _balances[msg.sender].sub(withdrawAmount);
        _balances[msg.sender].allow(msg.sender);
        totalDeposits -= amount;
        IcHERMES(cHERMES).burn(msg.sender, amount);
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        emit Withdrawn(msg.sender, amount);
    }

    function darkBridgeToRise(uint256 amount) external {
        require(amount >= 0.01 ether, "Minimum 0.01 ETH");
        euint256 bridgeAmountEnc = amount.asEuint256();
        euint256 currentLocked = _lockedForBridge[msg.sender];
        _lockedForBridge[msg.sender] = currentLocked.add(bridgeAmountEnc);
        _lockedForBridge[msg.sender].allow(msg.sender);
        euint256 lockAmount = amount.asEuint256();
        _balances[msg.sender] = _balances[msg.sender].sub(lockAmount);
        _balances[msg.sender].allow(msg.sender);
        emit DarkBridgeRequested(msg.sender, bridgeAmountEnc, bridgeNonce);
        bridgeNonce++;
    }

    function confirmBridgeClaim(address user, uint256 nonce) external {
        require(msg.sender == bridge, "Only bridge");
        emit BridgeClaimed(user, nonce);
    }

    function myBalance() external view returns (euint256) {
        return _balances[msg.sender];
    }

    function myLockedAmount() external view returns (euint256) {
        return _lockedForBridge[msg.sender];
    }

    receive() external payable {}
}
