// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {euint256, ebool, e} from "@inco/lightning/Lib.sol";

contract ConfidentialVault {
    using e for *;

    // Balance cifrato per ogni utente — invisibile on-chain
    mapping(address => euint256) private _balances;
    
    // Total deposits visibile (trasparenza del vault, privacy dell'utente)
    uint256 public totalDeposits;

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user);

    /// @notice Deposita ETH nel vault — il balance rimane privato
    function deposit() external payable {
        require(msg.value > 0, "ConfidentialVault: zero deposit");
        
        euint256 current = _balances[msg.sender];
        euint256 added = msg.value.asEuint256();
        euint256 newBalance = current.add(added);
        
        _balances[msg.sender] = newBalance;
        newBalance.allow(msg.sender);
        newBalance.allowThis();
        
        totalDeposits += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    /// @notice Ritorna il balance cifrato — solo il proprietario può decriptarlo
    function myBalance() external view returns (euint256) {
        return _balances[msg.sender];
    }

    /// @notice Withdraw parziale con amount cifrato
    function withdraw(bytes memory amountInput) external {
        euint256 amount = amountInput.newEuint256(msg.sender);
        
        ebool sufficient = _balances[msg.sender].ge(amount);
        euint256 withdrawn = sufficient.select(amount, uint256(0).asEuint256());
        
        _balances[msg.sender] = _balances[msg.sender].sub(withdrawn);
        _balances[msg.sender].allow(msg.sender);
        _balances[msg.sender].allowThis();
        
        emit Withdrawn(msg.sender);
    }
}
