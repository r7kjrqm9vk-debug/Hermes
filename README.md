# ⚡ HERMES Protocol

**Privacy-First Multi-Chain DeFi Protocol**  
*Encrypted Dark Pools with TEE (Inco) + FHE (Fhenix) + Zero-Gas Trading (RISE)*

---

## 🎯 Overview

HERMES is a privacy-preserving DeFi protocol enabling encrypted prediction markets and dark pool trading across multiple chains. Users can deposit collateral, trade with hidden positions, and maintain confidential balances using cutting-edge cryptographic techniques.

### Key Features

- 🔒 **Encrypted Positions** - Trade without revealing your holdings
- 🌐 **Multi-Chain** - Seamless cross-chain liquidity  
- ⚡ **Zero Gas** - Free transactions on RISE Chain
- 🎯 **Dark Pools** - Privacy-preserving AMM markets
- 🏆 **Encrypted Leaderboard** - Compete without exposing stats

---

## 📝 Deployed Contracts

### INCO (Base Sepolia) - ✅ FULLY TESTED

| Contract | Address | Status |
|----------|---------|--------|
| cHERMES Token | `0x3F2ce33a3c90ad2D9a5D05c76B9a60946fAbd700` | ✅ Working |
| ConfidentialVault | `0xdf4C7863Ae5FcDC015bE73732E3CFF4AC2cf47e9` | ✅ Working |
| EncryptedAMM | `0x4a0CE6FB0b10a6966eFF5A4c5c3734f0Bd9e256d` | ✅ Working |

**Verified Transactions:**
- [Deposit TX](https://sepolia.basescan.org/tx/0xafa1c732e993b9f1b37526284ff879c1bd8a32245db79878ddce8babc381fb99)
- [Market Created](https://sepolia.basescan.org/tx/0x1fba8276a3f54a14842ae39466d42978e200b7de863c8fc64d00822f5802e257)  
- [Trade Executed](https://sepolia.basescan.org/tx/0x57b470bb962482c99ceacc01175f8e0d8fea61146f9db1b133af59bf085daccc)

### FHENIX (Arbitrum Sepolia)

| Contract | Address | Status |
|----------|---------|--------|
| EncryptedLeaderboard | `0x6B9dDB6205D3C786c7A992a8943d1Edaa7b8A4E7` | ✅ Deployed |
| ReputationToken | `0x309c7017F6862537B96d89590759394a69FE3601` | ⚠️ Testnet FHE WIP |

### RISE Chain (Testnet)

| Contract | Address | Status |
|----------|---------|--------|
| HermesWallet | `0x6fEaaAdAa2itD5E76c81bcEcECcB73c248ac3207` | ✅ Working |
| IncoCollateralBridge | `0x0980cF9a9fB86761E33717a2e5A1c0678363d029` | ✅ Working |
| HermesMarket | `0x9E806D6CAbc238de24E3B9AAD065c1F339D278D8` | ✅ Working |

---

## 🚀 Live Demo

**Frontend:** [hermes-protocol.vercel.app](https://hermes-protocol.vercel.app)

---

## 🛠️ Tech Stack

- Solidity 0.8.24+
- Foundry - Smart contract development
- Inco Lightning - TEE privacy layer
- Fhenix CoFHE - FHE encryption  
- ethers.js - Frontend integration

---

## 📊 Metrics

| Metric | Value |
|--------|-------|
| **Chains** | 3 (RISE, Inco, Fhenix) |
| **Contracts** | 8 deployed |
| **Test TXs** | 10+ verified |
| **Privacy Stack** | TEE + FHE |

---

**HERMES Protocol** • Privacy-First DeFi • 2024
