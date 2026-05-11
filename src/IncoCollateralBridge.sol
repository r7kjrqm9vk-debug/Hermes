// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title IncoCollateralBridge
/// @notice Receives collateral proofs from Inco vault via oracle signature
/// @dev Tracks collateral amounts for Fhenix reputation gating
contract IncoCollateralBridge {
    address public oracle;
    mapping(address => uint256) public collateral; // Total collateral bridged per user
    mapping(bytes32 => bool) public usedSignatures;
    
    event CollateralBridged(address indexed user, uint256 amount);
    event OracleUpdated(address indexed newOracle);
    
    constructor(address _oracle) {
        require(_oracle != address(0), "Invalid oracle address");
        oracle = _oracle;
    }
    
    /// @notice Claim bridged collateral from Inco with oracle signature
    /// @param amount Amount bridged from Inco vault
    /// @param nonce Unique nonce from Inco bridge request
    /// @param signature Oracle signature proving bridge event
    function claimFromInco(
        uint128 amount,
        uint256 nonce,
        bytes calldata signature
    ) external {
        bytes32 messageHash = keccak256(abi.encodePacked(msg.sender, amount, nonce));
        bytes32 ethSignedHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
        
        require(!usedSignatures[ethSignedHash], "Signature already used");
        require(_recoverSigner(ethSignedHash, signature) == oracle, "Invalid oracle signature");
        
        usedSignatures[ethSignedHash] = true;
        collateral[msg.sender] += amount;
        
        emit CollateralBridged(msg.sender, amount);
    }
    
    /// @notice Check if user has sufficient collateral
    function hasCollateral(address user, uint256 minAmount) external view returns (bool) {
        return collateral[user] >= minAmount;
    }
    
    /// @notice Get reputation points based on bridged amount
    /// @dev 1 reputation point per 0.0001 ETH bridged (1e14 wei)
    function getReputationPoints(address user) external view returns (uint32) {
        uint256 points = collateral[user] / 1e14;
        return uint32(points > type(uint32).max ? type(uint32).max : points);
    }
    
    /// @dev Recover signer from signature
    function _recoverSigner(bytes32 hash, bytes memory sig) internal pure returns (address) {
        require(sig.length == 65, "Invalid signature length");
        
        bytes32 r;
        bytes32 s;
        uint8 v;
        
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        
        return ecrecover(hash, v, r, s);
    }
    
    /// @notice Update oracle address (only current oracle)
    function updateOracle(address newOracle) external {
        require(msg.sender == oracle, "Only oracle");
        require(newOracle != address(0), "Invalid address");
        oracle = newOracle;
        emit OracleUpdated(newOracle);
    }
}
