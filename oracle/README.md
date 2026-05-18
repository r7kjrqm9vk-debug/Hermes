# HERMES Dark Bridge Oracle

Monitors Inco ConfidentialVault deposits and relays proofs to RISE Bridge.

## Setup

1. Install dependencies:
```bash
npm install
```

2. Create `.env`:
```bash
cp .env.example .env
# Edit .env with your ORACLE_PRIVATE_KEY
```

3. Run locally:
```bash
npm start
```

## Deploy to Railway

1. Install Railway CLI:
```bash
npm i -g @railway/cli
```

2. Login:
```bash
railway login
```

3. Deploy:
```bash
railway up
```

4. Set environment variables in Railway dashboard:
- `ORACLE_PRIVATE_KEY`
- `INCO_VAULT` (optional, uses default)
- `RISE_BRIDGE` (optional, uses default)

## How it works

1. Listens for `Deposited` events on Inco Vault
2. Generates proof hash from (user, amount, txHash)
3. Calls `submitProof()` on RISE Bridge contract
4. RISE Bridge unlocks funds for user

## Status

Oracle address will be displayed on startup.
