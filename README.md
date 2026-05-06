# HERMES Protocol

> Performant private DeFi — market making on RISE Chain with confidential vaults on Inco Lightning.

## Overview

HERMES is a multi-chain DeFi protocol that combines:
- **High-performance market making** on RISE Chain (1ms latency, parallel EVM)
- **Confidential vaults** on Inco Lightning (encrypted balances via TEE)
- **On-chain activity tracking** via HermesTracker

The core insight: RISE provides the speed, Inco provides the privacy. Together they enable a new primitive — a market maker where liquidity positions are confidential.

## Architecture


┌─────────────────────────────────────────┐
│           HERMES Protocol               │
├─────────────┬───────────────────────────┤
│ RISE Chain  │ HermesMarket + Tracker    │
│             │ Permissionless markets    │
│             │ Native orderbook pattern  │
├─────────────┼───────────────────────────┤
│ Inco/Base   │ ConfidentialVault         │
│ Sepolia     │ Encrypted balances (TEE)  │
│             │ Private liquidity mgmt    │
└─────────────┴───────────────────────────┘


## Deployed Contracts

### RISE Testnet
| Contract | Address |
|---|---|
| Counter | `0x95237d9B46Fc528B3adc87B4173d9898f4665824` |
| HermesMarket | `0x4e0385b56AfA1FA2DBdf3f3b8A09ccEBFe2E75c4` |
| HermesTracker | `0x584A7eE5421b1066929f3e63D045bA66a0186b86` |

### Inco Lightning (Base Sepolia)
| Contract | Address |
|---|---|
| Counter | `0x3aF51122a39b876fD2752C5b588B6A5C45A7492d` |
| ConfidentialVault | `0x772a1A3942fBbdEb06826966CDA3476394f93399` |

### Fhenix CoFHE (Sepolia)
| Contract | Address |
|---|---|
| Counter | `0x990e8Db53f77E6A3eD84889339a442fA04920392` |

## Contracts

### HermesMarket
Permissionless market registry on RISE Chain. Any address can create a market pair and track its activity. Designed to interact with RISE MarketCore native orderbook.

### ConfidentialVault
Privacy-preserving vault built on Inco Lightning TEE. Balances are encrypted — only the depositor can read their own position. Total vault liquidity is public, individual positions are not.

### HermesTracker
On-chain activity logger for the HERMES ecosystem. Records actions, volumes, and market activity with full auditability.

## Why RISE + Inco?

Traditional DeFi has a front-running problem: every order, position, and balance is public before execution. HERMES addresses this by separating concerns:

- **Execution layer** (RISE): ultra-fast, native orderbook, parallel EVM
- **Privacy layer** (Inco): encrypted state, TEE-verified computation

A liquidity provider using HERMES can maintain a private vault position on Inco while executing orders at RISE speeds — without ever exposing their strategy on-chain.

## Stack
- Solidity `^0.8.24`
- Foundry 1.6.0
- Inco Lightning SDK `@inco/lightning`
- RISE Chain Testnet
- Fhenix CoFHE (Sepolia)

## Author
Built by `0xE8e8272b7574F5248eDDF28aAf882dB89474af6c` as part of the HERMES multi-chain DeFi experiment.
