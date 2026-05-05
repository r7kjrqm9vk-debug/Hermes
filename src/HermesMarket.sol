// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title HermesMarket
/// @notice Permissionless market registry on RISE Chain
/// @dev Demonstrates native orderbook interaction pattern via MarketCore

contract HermesMarket {
    
    struct Market {
        address creator;
        string baseAsset;
        string quoteAsset;
        uint256 createdAt;
        bool active;
    }

    mapping(uint256 => Market) public markets;
    mapping(address => uint256[]) public creatorMarkets;
    uint256 public marketCount;

    event MarketCreated(
        uint256 indexed marketId,
        address indexed creator,
        string baseAsset,
        string quoteAsset
    );

    event MarketDeactivated(uint256 indexed marketId);

    /// @notice Crea un nuovo mercato permissionless
    function createMarket(
        string calldata baseAsset,
        string calldata quoteAsset
    ) external returns (uint256 marketId) {
        marketId = marketCount++;
        
        markets[marketId] = Market({
            creator: msg.sender,
            baseAsset: baseAsset,
            quoteAsset: quoteAsset,
            createdAt: block.timestamp,
            active: true
        });

        creatorMarkets[msg.sender].push(marketId);
        
        emit MarketCreated(marketId, msg.sender, baseAsset, quoteAsset);
    }

    /// @notice Disattiva un mercato — solo il creator
    function deactivateMarket(uint256 marketId) external {
        require(markets[marketId].creator == msg.sender, "HermesMarket: not creator");
        markets[marketId].active = false;
        emit MarketDeactivated(marketId);
    }

    /// @notice Ritorna tutti i market id di un creator
    function getCreatorMarkets(address creator) 
        external view returns (uint256[] memory) 
    {
        return creatorMarkets[creator];
    }
}
