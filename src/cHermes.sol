// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title cHERMES - Collateralized HERMES
/// @notice ERC20 representation of Inco Vault deposits at 1:1000 ratio
/// @dev 1 ETH deposited = 1000 cHERMES minted
contract cHERMES is ERC20, Ownable {
    address public vault;

    event Minted(address indexed to, uint256 amount);
    event Burned(address indexed from, uint256 amount);

    constructor() ERC20("Collateralized HERMES", "cHERMES") Ownable(msg.sender) {}

    modifier onlyVault() {
        require(msg.sender == vault, "Only vault");
        _;
    }

    /// @notice Set vault address (one-time)
    function setVault(address _vault) external onlyOwner {
        require(vault == address(0), "Vault already set");
        vault = _vault;
    }

    /// @notice Mint cHERMES when user deposits to vault
    /// @dev 1 ETH = 1000 cHERMES (1:1000 ratio)
    function mint(address to, uint256 ethAmount) external onlyVault {
        uint256 cHermesAmount = ethAmount * 1000;
        _mint(to, cHermesAmount);
        emit Minted(to, cHermesAmount);
    }

    /// @notice Burn cHERMES when user withdraws from vault
    /// @dev Must burn 1000 cHERMES per 1 ETH withdrawn
    function burn(address from, uint256 ethAmount) external onlyVault {
        uint256 cHermesAmount = ethAmount * 1000;
        _burn(from, cHermesAmount);
        emit Burned(from, cHermesAmount);
    }

    /// @notice Convert cHERMES amount to ETH equivalent
    function toETH(uint256 cHermesAmount) public pure returns (uint256) {
        return cHermesAmount / 1000;
    }

    /// @notice Convert ETH amount to cHERMES equivalent
    function toCHERMES(uint256 ethAmount) public pure returns (uint256) {
        return ethAmount * 1000;
    }
}