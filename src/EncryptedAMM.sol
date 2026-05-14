// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@inco/lightning/Lib.sol";

contract EncryptedAMM {
    using e for *;

    struct Market {
        string question;
        uint256 resolutionTime;
        euint256 reserveYes;
        euint256 reserveNo;
        uint256 k;
        address creator;
        bool resolved;
        bool outcome;
        mapping(address => euint256) yesShares;
        mapping(address => euint256) noShares;
    }

    mapping(uint256 => Market) public markets;
    uint256 public marketCount;
    uint256 public constant FEE_BPS = 30;

    event MarketCreated(uint256 indexed marketId, string question, uint256 resolutionTime, address creator);
    event TradeExecuted(uint256 indexed marketId, address indexed trader, bool isYes);
    event MarketResolved(uint256 indexed marketId, bool outcome);

    function createMarket(string calldata question, uint256 resolutionTime, uint256 initialYes, uint256 initialNo) external payable returns (uint256) {
        require(msg.value == initialYes + initialNo, "Incorrect liquidity");
        require(initialYes > 0 && initialNo > 0, "Zero liquidity");
        require(resolutionTime > block.timestamp, "Invalid time");
        uint256 marketId = marketCount++;
        Market storage market = markets[marketId];
        market.question = question;
        market.resolutionTime = resolutionTime;
        market.creator = msg.sender;
        market.resolved = false;
        market.reserveYes = initialYes.asEuint256();
        market.reserveNo = initialNo.asEuint256();
        market.k = initialYes * initialNo;
        market.yesShares[msg.sender] = initialYes.asEuint256();
        market.noShares[msg.sender] = initialNo.asEuint256();
        market.yesShares[msg.sender].allow(msg.sender);
        market.noShares[msg.sender].allow(msg.sender);
        emit MarketCreated(marketId, question, resolutionTime, msg.sender);
        return marketId;
    }

    function buyYes(uint256 marketId, uint256 amountIn) external payable {
        require(msg.value == amountIn, "Incorrect payment");
        Market storage market = markets[marketId];
        require(!market.resolved, "Market resolved");
        require(block.timestamp < market.resolutionTime, "Market closed");
        uint256 amountAfterFee = amountIn - (amountIn * FEE_BPS / 10000);
        euint256 amountInEnc = amountAfterFee.asEuint256();
        market.reserveYes = market.reserveYes.add(amountInEnc);
        euint256 currentShares = market.yesShares[msg.sender];
        market.yesShares[msg.sender] = currentShares.add(amountInEnc);
        market.yesShares[msg.sender].allow(msg.sender);
        emit TradeExecuted(marketId, msg.sender, true);
    }

    function buyNo(uint256 marketId, uint256 amountIn) external payable {
        require(msg.value == amountIn, "Incorrect payment");
        Market storage market = markets[marketId];
        require(!market.resolved, "Market resolved");
        require(block.timestamp < market.resolutionTime, "Market closed");
        uint256 amountAfterFee = amountIn - (amountIn * FEE_BPS / 10000);
        euint256 amountInEnc = amountAfterFee.asEuint256();
        market.reserveNo = market.reserveNo.add(amountInEnc);
        euint256 currentShares = market.noShares[msg.sender];
        market.noShares[msg.sender] = currentShares.add(amountInEnc);
        market.noShares[msg.sender].allow(msg.sender);
        emit TradeExecuted(marketId, msg.sender, false);
    }

    function resolveMarket(uint256 marketId, bool outcome) external {
        Market storage market = markets[marketId];
        require(msg.sender == market.creator, "Only creator");
        require(block.timestamp >= market.resolutionTime, "Too early");
        require(!market.resolved, "Already resolved");
        market.resolved = true;
        market.outcome = outcome;
        emit MarketResolved(marketId, outcome);
    }

    function claimWinnings(uint256 marketId) external {
        Market storage market = markets[marketId];
        require(market.resolved, "Not resolved");
        euint256 shares = market.outcome ? market.yesShares[msg.sender] : market.noShares[msg.sender];
        if (market.outcome) {
            market.yesShares[msg.sender] = uint256(0).asEuint256();
        } else {
            market.noShares[msg.sender] = uint256(0).asEuint256();
        }
        payable(msg.sender).transfer(address(this).balance);
    }

    function getMarketInfo(uint256 marketId) external view returns (string memory question, uint256 resolutionTime, uint256 k, address creator, bool resolved, bool outcome) {
        Market storage market = markets[marketId];
        return (market.question, market.resolutionTime, market.k, market.creator, market.resolved, market.outcome);
    }

    receive() external payable {}
}
