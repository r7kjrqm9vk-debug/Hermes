// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {euint128, ebool, InEuint128, FHE} from "@fhenixprotocol/cofhe-contracts/FHE.sol";

/// @title ConfidentialVaultFhenix
/// @notice Privacy-preserving vault using Fhenix FHE (zero trust — no hardware assumption)
/// @dev Balances encrypted via FHE. Decryption happens off-chain via cofhejs decryptForView.

contract ConfidentialVaultFhenix {

    mapping(address => euint128) private _balances;
    uint256 public totalDeposits;

    event Deposited(address indexed user, uint256 amount);

    /// @notice Deposit — encrypted amount via InEuint128
    function deposit(InEuint128 memory encryptedAmount) external payable {
        require(msg.value > 0, "ConfidentialVaultFhenix: zero deposit");
        euint128 amount = FHE.asEuint128(encryptedAmount);
        _balances[msg.sender] = FHE.add(_balances[msg.sender], amount);
        FHE.allowThis(_balances[msg.sender]);
        FHE.allow(_balances[msg.sender], msg.sender);
        totalDeposits += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    /// @notice Returns the encrypted balance handle — caller decrypts off-chain via cofhejs
    function myBalance() external view returns (euint128) {
        return _balances[msg.sender];
    }

    /// @notice Total vault deposits — public
    function getTotal() external view returns (uint256) {
        return totalDeposits;
    }
}
